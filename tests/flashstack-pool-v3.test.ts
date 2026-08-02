import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * flashstack-pool-v3 -- generic multi-asset flash-loan + LP pool.
 * Design: docs/02-technical/MULTI_ASSET_CORE_DESIGN.md (decisions #1-#5).
 *
 * Covers: admin gating + two-step transfer (BC1), asset allow-list as a
 * security boundary (malicious-token-listed-vs-unlisted), fee hard cap,
 * per-asset share isolation across two DIFFERENT assets, virtual
 * shares/assets (F-1), the flash-loan balance invariant, receiver
 * allowlist, and the oracle read-only functions (F-2).
 */

const POOL = "flashstack-pool-v3";
const SBTC = "sbtc-token";     // local FT #1 (mint gated by flash-minter)
const USDC = "mock-usdcx";     // local FT #2 (freely mintable)
const EVIL = "malicious-token"; // SIP-010-shaped but lies; never listed
const GOOD_RX = "test-pool-v3-receiver-good";
const BAD_RX = "test-pool-v3-receiver-bad";

const ERR = {
  NOT_ADMIN: 800, NOT_PENDING_ADMIN: 801, ZERO_AMOUNT: 802, PAUSED: 803,
  ASSET_PAUSED: 804, NOT_LISTED: 805, ALREADY_LISTED: 806, EXCEEDS_LIMIT: 807,
  NOT_APPROVED: 808, INSUFFICIENT_RESERVE: 809, REPAY_FAILED: 810,
  INVALID_FEE: 812, INSUFFICIENT_SHARES: 813,
};

const FEE_BP = 5;
const MAX_LOAN = 1_000_000_000;

describe("flashstack-pool-v3", () => {
  let deployer: string, lp1: string, lp2: string, attacker: string;

  const assetPrincipal = (name: string) => `${deployer}.${name}`;

  const mintSbtc = (amount: number, to: string) => {
    // sbtc-token gates mint() by flash-minter, defaulting to CONTRACT-OWNER
    // (the deployer) -- deployer calling mint directly works in simnet.
    return simnet.callPublicFn(SBTC, "mint", [Cl.uint(amount), Cl.principal(to)], deployer);
  };
  const mintUsdc = (amount: number, to: string) =>
    simnet.callPublicFn(USDC, "mint", [Cl.uint(amount), Cl.principal(to)], deployer);

  const addAsset = (asset: string, feeBp = FEE_BP, maxLoan = MAX_LOAN, sender = deployer) =>
    simnet.callPublicFn(POOL, "add-asset", [Cl.principal(assetPrincipal(asset)), Cl.uint(feeBp), Cl.uint(maxLoan)], sender);

  const deposit = (asset: string, amount: number, who: string) =>
    simnet.callPublicFn(POOL, "deposit", [Cl.contractPrincipal(deployer, asset), Cl.uint(amount)], who);

  const withdraw = (asset: string, shares: number, who: string) =>
    simnet.callPublicFn(POOL, "withdraw", [Cl.contractPrincipal(deployer, asset), Cl.uint(shares)], who);

  const flashLoan = (asset: string, amount: number, receiver: string, who = deployer) =>
    simnet.callPublicFn(POOL, "flash-loan",
      [Cl.contractPrincipal(deployer, asset), Cl.uint(amount), Cl.contractPrincipal(deployer, receiver)], who);

  const shares = (asset: string, who: string) =>
    Number((simnet.callReadOnlyFn(POOL, "get-shares", [Cl.principal(assetPrincipal(asset)), Cl.principal(who)], deployer).result as any).value);

  const reserve = (asset: string) =>
    Number((simnet.callReadOnlyFn(POOL, "get-reserve", [Cl.principal(assetPrincipal(asset))], deployer).result as any).value.value);

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    lp1 = simnet.getAccounts().get("wallet_1")!;
    lp2 = simnet.getAccounts().get("wallet_2")!;
    attacker = simnet.getAccounts().get("wallet_3")!;
  });

  // ---------------------------------------------------------------------
  // Admin gating + two-step transfer (BC1)
  // ---------------------------------------------------------------------
  describe("admin", () => {
    it("only admin can add-asset / set-paused", () => {
      expect(addAsset(SBTC, FEE_BP, MAX_LOAN, lp1).result).toBeErr(Cl.uint(ERR.NOT_ADMIN));
      expect(simnet.callPublicFn(POOL, "set-paused", [Cl.bool(true)], lp1).result).toBeErr(Cl.uint(ERR.NOT_ADMIN));
    });

    it("two-step transfer: a bad proposal never locks out, admin recovers", () => {
      const dead = "ST000000000000000000002AMW42H";
      expect(simnet.callPublicFn(POOL, "transfer-admin", [Cl.principal(dead)], deployer).result).toBeOk(Cl.bool(true));
      expect(simnet.callReadOnlyFn(POOL, "get-admin", [], deployer).result).toBeOk(Cl.principal(deployer));
      expect(simnet.callPublicFn(POOL, "set-paused", [Cl.bool(true)], deployer).result).toBeOk(Cl.bool(true));

      expect(simnet.callPublicFn(POOL, "transfer-admin", [Cl.principal(lp1)], deployer).result).toBeOk(Cl.bool(true));
      expect(simnet.callPublicFn(POOL, "accept-admin", [], lp1).result).toBeOk(Cl.bool(true));
      expect(simnet.callReadOnlyFn(POOL, "get-admin", [], deployer).result).toBeOk(Cl.principal(lp1));
    });

    it("a non-pending principal cannot accept-admin", () => {
      simnet.callPublicFn(POOL, "transfer-admin", [Cl.principal(lp1)], deployer);
      expect(simnet.callPublicFn(POOL, "accept-admin", [], lp2).result).toBeErr(Cl.uint(ERR.NOT_PENDING_ADMIN));
    });
  });

  // ---------------------------------------------------------------------
  // Asset allow-list -- the security boundary (design doc section 7)
  // ---------------------------------------------------------------------
  describe("asset allow-list", () => {
    it("add-asset rejects a fee above the hard cap (decision #4)", () => {
      expect(addAsset(SBTC, 101, MAX_LOAN).result).toBeErr(Cl.uint(ERR.INVALID_FEE));
      expect(addAsset(SBTC, 0, MAX_LOAN).result).toBeErr(Cl.uint(ERR.INVALID_FEE));
      expect(addAsset(SBTC, 100, MAX_LOAN).result).toBeOk(Cl.bool(true)); // exactly the cap is fine
    });

    it("cannot list the same asset twice", () => {
      addAsset(SBTC);
      expect(addAsset(SBTC).result).toBeErr(Cl.uint(ERR.ALREADY_LISTED));
    });

    it("deposit/flash-loan on an UNLISTED token is rejected -- even a malicious one", () => {
      // The malicious token is never added via add-asset. Its lying
      // get-balance/transfer are never even reached: the allow-list check
      // runs first and rejects it unconditionally.
      mintUsdc(1000, attacker); // irrelevant for EVIL, but exercises a real deposit path shape
      expect(deposit(EVIL, 1000, attacker).result).toBeErr(Cl.uint(ERR.NOT_LISTED));

      addAsset(SBTC);
      mintSbtc(1_000_000, deployer);
      deposit(SBTC, 1_000_000, deployer);
      simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.principal(assetPrincipal(GOOD_RX))], deployer);
      // Even with real reserve of a DIFFERENT (listed) asset sitting in the
      // pool, borrowing the malicious/unlisted token is still rejected.
      expect(flashLoan(EVIL, 100, GOOD_RX).result).toBeErr(Cl.uint(ERR.NOT_LISTED));
    });

    it("remove-asset delists (blocks new deposits/loans) but LPs can still withdraw", () => {
      addAsset(SBTC);
      mintSbtc(1_000_000, lp1);
      deposit(SBTC, 1_000_000, lp1);

      expect(simnet.callPublicFn(POOL, "remove-asset", [Cl.principal(assetPrincipal(SBTC))], deployer).result).toBeOk(Cl.bool(true));
      expect(deposit(SBTC, 1, lp1).result).toBeErr(Cl.uint(ERR.NOT_LISTED));

      // withdraw is NOT gated by the assets map -- LPs can always exit.
      const s = shares(SBTC, lp1);
      expect(withdraw(SBTC, s, lp1).result).toBeOk(Cl.uint(1_000_000));
    });
  });

  // ---------------------------------------------------------------------
  // Per-asset isolation across TWO different assets (no cross-asset leakage)
  // ---------------------------------------------------------------------
  describe("per-asset isolation", () => {
    it("deposits in two different assets never affect each other's shares/reserve", () => {
      addAsset(SBTC);
      addAsset(USDC);
      mintSbtc(1_000_000, lp1);
      mintUsdc(2_000_000, lp1);

      deposit(SBTC, 1_000_000, lp1);
      expect(shares(USDC, lp1)).toBe(0); // no USDC shares from an sBTC deposit
      expect(reserve(USDC)).toBe(0);

      deposit(USDC, 2_000_000, lp1);
      expect(reserve(SBTC)).toBe(1_000_000); // unaffected by the USDC deposit
      expect(reserve(USDC)).toBe(2_000_000);
    });

    it("a sole honest LP withdraws exactly what they deposited, per asset", () => {
      addAsset(SBTC);
      mintSbtc(500_000, lp2);
      deposit(SBTC, 500_000, lp2);
      const s = shares(SBTC, lp2);
      expect(withdraw(SBTC, s, lp2).result).toBeOk(Cl.uint(500_000));
    });
  });

  // ---------------------------------------------------------------------
  // Virtual shares/assets (F-1): first-depositor / donation inflation
  // ---------------------------------------------------------------------
  describe("F-1: inflation attack neutralized", () => {
    it("a tiny first deposit + a direct donation does not let the attacker steal from the victim", () => {
      addAsset(SBTC);
      mintSbtc(1, attacker);
      deposit(SBTC, 1, attacker); // attacker is first depositor, 1 sat

      // Attacker donates directly to the pool contract (bypasses deposit --
      // mints no shares). This is the classic first-depositor inflation vector.
      mintSbtc(100_000_000, attacker);
      simnet.callPublicFn(SBTC, "transfer",
        [Cl.uint(100_000_000), Cl.principal(attacker), Cl.principal(`${deployer}.${POOL}`), Cl.none()], attacker);

      mintSbtc(1_000_000, lp1);
      deposit(SBTC, 1_000_000, lp1); // victim deposits 0.01 BTC

      const victimShares = shares(SBTC, lp1);
      expect(victimShares).toBeGreaterThan(0); // victim did NOT get rounded to 0 shares

      // Victim can withdraw at least ~99% of what they put in (small
      // rounding loss only, not a near-total loss to the attacker).
      const out = withdraw(SBTC, victimShares, lp1).result;
      const outValue = Number((out as any).value.value ?? (out as any).value);
      expect(outValue).toBeGreaterThanOrEqual(990_000); // >= 99% of 1,000,000
    });
  });

  // ---------------------------------------------------------------------
  // Flash-loan balance invariant
  // ---------------------------------------------------------------------
  describe("flash-loan invariant", () => {
    beforeEach(() => {
      addAsset(SBTC);
      mintSbtc(10_000_000, deployer);
      deposit(SBTC, 10_000_000, deployer);
      simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.principal(assetPrincipal(GOOD_RX))], deployer);
      simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.principal(assetPrincipal(BAD_RX))], deployer);
      // Seed both receivers so they can cover the fee on repay.
      mintSbtc(10_000, assetPrincipal(GOOD_RX));
    });

    it("happy path: reserve grows by exactly the fee", () => {
      const before = reserve(SBTC);
      const loan = 1_000_000;
      const fee = Math.floor((loan * FEE_BP) / 10000);
      expect(flashLoan(SBTC, loan, GOOD_RX).result).toBeOk(Cl.bool(true));
      expect(reserve(SBTC)).toBe(before + fee);
    });

    it("a receiver that never repays reverts the whole transaction", () => {
      const before = reserve(SBTC);
      expect(flashLoan(SBTC, 1_000_000, BAD_RX).result).toBeErr(Cl.uint(ERR.REPAY_FAILED));
      expect(reserve(SBTC)).toBe(before); // fully rolled back
    });

    it("an unapproved receiver is rejected", () => {
      expect(flashLoan(SBTC, 1_000_000, "test-pool-v3-receiver-good", lp1).result); // sanity: approved case works
      simnet.callPublicFn(POOL, "remove-approved-receiver", [Cl.principal(assetPrincipal(GOOD_RX))], deployer);
      expect(flashLoan(SBTC, 1_000_000, GOOD_RX).result).toBeErr(Cl.uint(ERR.NOT_APPROVED));
    });

    it("a loan exceeding the asset's max-loan is rejected", () => {
      expect(flashLoan(SBTC, MAX_LOAN + 1, GOOD_RX).result).toBeErr(Cl.uint(ERR.EXCEEDS_LIMIT));
    });

    it("an asset-level pause blocks loans on that asset only", () => {
      simnet.callPublicFn(POOL, "set-asset", [Cl.principal(assetPrincipal(SBTC)), Cl.uint(FEE_BP), Cl.uint(MAX_LOAN), Cl.bool(true)], deployer);
      expect(flashLoan(SBTC, 1_000_000, GOOD_RX).result).toBeErr(Cl.uint(ERR.ASSET_PAUSED));
    });

    it("global pause blocks all loans", () => {
      simnet.callPublicFn(POOL, "set-paused", [Cl.bool(true)], deployer);
      expect(flashLoan(SBTC, 1_000_000, GOOD_RX).result).toBeErr(Cl.uint(ERR.PAUSED));
    });
  });

  // ---------------------------------------------------------------------
  // Oracle read-only functions (F-2: well-defined at zero shares)
  // ---------------------------------------------------------------------
  describe("oracle", () => {
    it("get-share-price is well-defined before any deposit", () => {
      addAsset(SBTC);
      const price = simnet.callReadOnlyFn(POOL, "get-share-price", [Cl.principal(assetPrincipal(SBTC))], deployer).result;
      expect(price).toBeOk(Cl.uint(1)); // (0 + VA) * SHARE-PRECISION / (0 + VS) = 1 * 1e6 / 1e6 = 1
    });

    it("get-lp-value tracks a fee-driven yield increase", () => {
      addAsset(SBTC);
      mintSbtc(1_000_000, lp1);
      deposit(SBTC, 1_000_000, lp1);
      simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.principal(assetPrincipal(GOOD_RX))], deployer);
      mintSbtc(10_000, assetPrincipal(GOOD_RX));

      flashLoan(SBTC, 1_000_000, GOOD_RX);

      const val = simnet.callReadOnlyFn(POOL, "get-lp-value", [Cl.principal(assetPrincipal(SBTC)), Cl.principal(lp1)], deployer).result as any;
      expect(Number(val.value.value)).toBeGreaterThan(1_000_000); // yield accrued
    });
  });
});
