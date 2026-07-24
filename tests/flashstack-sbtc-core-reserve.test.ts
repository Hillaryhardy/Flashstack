import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * Tests for the DEPLOYED sBTC reserve-model core: flashstack-sbtc-core
 * (mainnet SP20XD46...flashstack-sbtc-core), which holds canonical sBTC.
 * Contract under test is a localized copy — byte-identical logic, the sBTC
 * token and receiver-trait references pointed at local contracts for simnet.
 * Reserve is a SIP-010 balance (not native STX), so funding is done by minting
 * the local sBTC token.
 *
 * Error codes: 300 PAUSED · 301 ZERO-AMOUNT · 302 REPAY-FAILED
 * 303 INSUFFICIENT-RESERVE · 304 EXCEEDS-LIMIT · 306 NOT-APPROVED · 310 NOT-ADMIN
 */

const CORE = "flashstack-sbtc-core";
const GOOD = "test-sbtc-receiver-good";
const BAD = "test-sbtc-receiver-bad";

const RESERVE = 1_000_000; // 0.01 BTC seeded (sats)
const LOAN = 100_000; // borrowed (sats)
const FEE = 50; // 0.05% of 100,000 sats
const BUFFER = 10_000; // sBTC minted into the good receiver to cover the fee

describe("flashstack-sbtc-core (deployed reserve model, canonical sBTC)", () => {
  let deployer: string;
  let wallet1: string;

  const mint = (amount: number, to: string) =>
    simnet.callPublicFn("sbtc-token", "mint", [Cl.uint(amount), Cl.principal(to)], deployer);

  const reserveBalance = () => {
    const r = simnet.callReadOnlyFn(CORE, "get-reserve-balance", [], deployer).result;
    return Number((r as any).value.value); // (ok uint) -> uint -> bigint
  };

  const seedAndApprove = (receiver: string) => {
    mint(RESERVE, deployer);
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer);
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, receiver)], deployer);
  };

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    wallet1 = simnet.getAccounts().get("wallet_1")!;
  });

  // --- Admin gating ------------------------------------------------------
  it("deposit-reserve credits the sBTC reserve; non-admin is rejected", () => {
    mint(RESERVE, deployer);
    expect(simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer).result).toBeOk(Cl.bool(true));
    expect(reserveBalance()).toBe(RESERVE);
    expect(simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], wallet1).result).toBeErr(Cl.uint(310));
  });

  it("only the admin can whitelist a receiver", () => {
    expect(
      simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], wallet1).result
    ).toBeErr(Cl.uint(310));
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    expect(
      simnet.callReadOnlyFn(CORE, "is-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeOk(Cl.bool(true));
  });

  // --- The invariants ----------------------------------------------------
  it("happy path: an approved receiver repays, and the sBTC reserve grows by exactly the fee", () => {
    seedAndApprove(GOOD);
    mint(BUFFER, `${deployer}.${GOOD}`);
    const before = reserveBalance();

    const { result } = simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer);

    expect(result).toBeOk(Cl.bool(true));
    expect(reserveBalance()).toBe(before + FEE);
  });

  it("repay-or-revert: a receiver that keeps the sBTC reverts, and the reserve is untouched", () => {
    seedAndApprove(BAD);
    const before = reserveBalance();

    const { result } = simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, BAD)], deployer);

    expect(result).toBeErr(Cl.uint(302)); // ERR-REPAY-FAILED
    expect(reserveBalance()).toBe(before); // fully rolled back
  });

  // --- Guards ------------------------------------------------------------
  it("rejects an unapproved receiver (306)", () => {
    mint(RESERVE, deployer);
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(306));
  });

  it("rejects a loan above max-single-loan (304)", () => {
    seedAndApprove(GOOD);
    simnet.callPublicFn(CORE, "set-max-single-loan", [Cl.uint(BUFFER)], deployer); // cap below LOAN
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(304));
  });

  it("rejects a loan larger than the reserve (303)", () => {
    mint(LOAN, deployer);
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(LOAN)], deployer); // reserve = LOAN
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN * 2), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(303));
  });

  it("rejects loans while paused (300)", () => {
    seedAndApprove(GOOD);
    simnet.callPublicFn(CORE, "set-paused", [Cl.bool(true)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(300));
  });

  it("rejects a zero-amount loan (301)", () => {
    seedAndApprove(GOOD);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(0), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(301));
  });
});
