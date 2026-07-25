import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * Tests for the DEPLOYED sBTC LP pool: flashstack-sbtc-pool (aToken share math
 * in sats, with a built-in collateral oracle). Localized copy of the immutable
 * mainnet contract; sBTC token + trait refs localized for simnet.
 *
 * Error codes: 701 ZERO · 706 NOT-APPROVED · 709 INSUFFICIENT-SHARES
 * NOTE: inherits Finding F-1 (first-depositor inflation) from the STX pool.
 */

const POOL = "flashstack-sbtc-pool";
const GOOD = "test-sbtc-pool-receiver-good";
const PRECISION = 100_000_000; // 1e8 (sat precision)

const DEP = 1_000_000; // 0.01 BTC deposited (sats)
const FEE = 500; // 0.05% of a 1,000,000-sat flash loan
const BUFFER = 10_000; // sBTC minted into the receiver to cover the fee

describe("flashstack-sbtc-pool (deployed sBTC LP model + built-in oracle)", () => {
  let deployer: string;
  let wallet1: string;

  const mint = (amount: number, to: string) =>
    simnet.callPublicFn("sbtc-token", "mint", [Cl.uint(amount), Cl.principal(to)], deployer);
  const poolBalance = () => Number((simnet.callReadOnlyFn(POOL, "get-pool-balance", [], deployer).result as any).value.value);
  const shares = (who: string) => Number(simnet.callReadOnlyFn(POOL, "get-shares", [Cl.principal(who)], deployer).result.value);
  const lpValue = (who: string) => Number((simnet.callReadOnlyFn(POOL, "get-lp-value", [Cl.principal(who)], deployer).result as any).value.value);

  const deposit = (amount: number, who: string) => {
    mint(amount, who);
    return simnet.callPublicFn(POOL, "deposit", [Cl.uint(amount)], who);
  };

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    wallet1 = simnet.getAccounts().get("wallet_1")!;
  });

  // --- Share mechanics ---------------------------------------------------
  it("first deposit mints amount * SHARE-PRECISION shares", () => {
    expect(deposit(DEP, deployer).result).toBeOk(Cl.uint(DEP * PRECISION));
    expect(poolBalance()).toBe(DEP);
    expect(shares(deployer)).toBe(DEP * PRECISION);
  });

  it("a second depositor receives proportional shares", () => {
    deposit(DEP, deployer);
    deposit(DEP / 2, wallet1);
    expect(shares(wallet1)).toBe((DEP * PRECISION) / 2);
  });

  it("withdraw returns sBTC pro-rata to shares", () => {
    deposit(DEP, deployer);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(shares(deployer))], deployer).result).toBeOk(Cl.uint(DEP));
  });

  it("rejects withdrawing more than owned (709) and zero-amount ops (701)", () => {
    deposit(DEP, deployer);
    const s = shares(deployer);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(s + 1)], deployer).result).toBeErr(Cl.uint(709));
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(0)], deployer).result).toBeErr(Cl.uint(701));
    expect(simnet.callPublicFn(POOL, "deposit", [Cl.uint(0)], deployer).result).toBeErr(Cl.uint(701));
  });

  it("rejects an unapproved flash-loan receiver (706)", () => {
    deposit(DEP, deployer);
    expect(
      simnet.callPublicFn(POOL, "flash-loan", [Cl.uint(DEP), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(706));
  });

  // --- The economic promise: fees appreciate LP shares -------------------
  it("a flash-loan fee raises the LP's value by exactly the fee, realizable on withdrawal", () => {
    deposit(DEP, deployer);
    simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    mint(BUFFER, `${deployer}.${GOOD}`);
    expect(lpValue(deployer)).toBe(DEP);

    expect(
      simnet.callPublicFn(POOL, "flash-loan", [Cl.uint(DEP), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeOk(Cl.bool(true));

    expect(lpValue(deployer)).toBe(DEP + FEE);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(shares(deployer))], deployer).result).toBeOk(Cl.uint(DEP + FEE));
  });

  // --- Built-in oracle ---------------------------------------------------
  it("built-in oracle: share-price at launch equals SHARE-PRECISION", () => {
    expect(simnet.callReadOnlyFn(POOL, "get-share-price", [], deployer).result).toBeOk(Cl.uint(PRECISION));
  });

  it("built-in oracle: lp-value and collateral snapshot are healthy after a deposit", () => {
    deposit(DEP, deployer);
    expect(simnet.callReadOnlyFn(POOL, "get-lp-value", [Cl.principal(deployer)], deployer).result).toBeOk(Cl.uint(DEP));
    expect(simnet.callReadOnlyFn(POOL, "get-collateral-snapshot", [], deployer).result).toBeOk();
  });
});
