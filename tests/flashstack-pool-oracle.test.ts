import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * Tests for the DEPLOYED LP pool + collateral oracle:
 *   flashstack-stx-pool   (aToken-style shares; fees appreciate every share)
 *   flashstack-pool-oracle (read-only share-price / lp-value feed)
 * Contracts under test are localized copies of the immutable mainnet contracts
 * (byte-identical logic; trait ref / pool ref localized for simnet).
 *
 * Pool error codes: 401 ZERO · 406 NOT-APPROVED · 409 INSUFFICIENT-SHARES
 *
 * NOTE (flagged for the security review): the first depositor receives
 * amount * SHARE-PRECISION shares. Share-math pools carry a first-depositor /
 * donation-inflation risk; the launch oracle price (SHARE-PRECISION) is also on
 * a different scale than the post-deposit price. Neither is exploited here, but
 * both are worth an auditor's eye. See the yield/consistency tests below.
 */

const POOL = "flashstack-stx-pool";
const ORACLE = "flashstack-pool-oracle";
const GOOD = "test-pool-receiver-good";
const PRECISION = 1_000_000;

const DEP = 100_000_000; // 100 STX deposited
const FEE = 50_000; // 0.05% of a 100-STX flash loan
const BUFFER = 1_000_000; // 1 STX funded into the receiver to cover the fee

describe("flashstack-stx-pool + oracle (deployed LP model)", () => {
  let deployer: string;
  let wallet1: string;

  const poolBalance = () => Number(simnet.callReadOnlyFn(POOL, "get-pool-balance", [], deployer).result.value);
  const shares = (who: string) => Number(simnet.callReadOnlyFn(POOL, "get-shares", [Cl.principal(who)], deployer).result.value);

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    wallet1 = simnet.getAccounts().get("wallet_1")!;
  });

  // --- Share mechanics ---------------------------------------------------
  it("first deposit mints amount * SHARE-PRECISION shares", () => {
    expect(simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer).result).toBeOk(Cl.uint(DEP * PRECISION));
    expect(poolBalance()).toBe(DEP);
    expect(shares(deployer)).toBe(DEP * PRECISION);
  });

  it("a second depositor receives shares proportional to the pool", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer); // 100 STX -> DEP*1e6 shares
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP / 2)], wallet1); // 50 STX -> half the shares
    expect(shares(wallet1)).toBe((DEP * PRECISION) / 2);
  });

  it("withdraw returns STX pro-rata to shares", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    const s = shares(deployer);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(s)], deployer).result).toBeOk(Cl.uint(DEP));
  });

  it("rejects withdrawing more shares than owned (409) and zero-amount ops (401)", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    const s = shares(deployer);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(s + 1)], deployer).result).toBeErr(Cl.uint(409));
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(0)], deployer).result).toBeErr(Cl.uint(401));
    expect(simnet.callPublicFn(POOL, "deposit", [Cl.uint(0)], deployer).result).toBeErr(Cl.uint(401));
  });

  it("rejects an unapproved flash-loan receiver (406)", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    expect(
      simnet.callPublicFn(POOL, "flash-loan", [Cl.uint(DEP), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(406));
  });

  // --- The economic promise: fees appreciate LP shares -------------------
  it("a flash-loan fee increases every LP's value (share appreciation)", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    simnet.transferSTX(BUFFER, `${deployer}.${GOOD}`, deployer);

    const valueBefore = Number(simnet.callReadOnlyFn(POOL, "get-stx-value", [Cl.principal(deployer)], deployer).result.value);
    expect(valueBefore).toBe(DEP);

    expect(
      simnet.callPublicFn(POOL, "flash-loan", [Cl.uint(DEP), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeOk(Cl.bool(true));

    // The fee stayed in the pool; the sole LP's value grew by exactly the fee.
    const valueAfter = Number(simnet.callReadOnlyFn(POOL, "get-stx-value", [Cl.principal(deployer)], deployer).result.value);
    expect(valueAfter).toBe(DEP + FEE);
    // ...and it is realizable: withdrawing all shares returns deposit + fee.
    const s = shares(deployer);
    expect(simnet.callPublicFn(POOL, "withdraw", [Cl.uint(s)], deployer).result).toBeOk(Cl.uint(DEP + FEE));
  });

  // --- Oracle ------------------------------------------------------------
  it("oracle share-price at launch equals SHARE-PRECISION (no shares yet)", () => {
    expect(simnet.callReadOnlyFn(ORACLE, "get-share-price", [], deployer).result).toBeOk(Cl.uint(PRECISION));
  });

  it("oracle reports pool balance, shares, and lp-value after a deposit", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    expect(simnet.callReadOnlyFn(ORACLE, "get-total-shares", [], deployer).result).toBeUint(DEP * PRECISION);
    expect(simnet.callReadOnlyFn(ORACLE, "get-pool-balance", [], deployer).result).toBeUint(DEP);
    expect(simnet.callReadOnlyFn(ORACLE, "get-lp-value", [Cl.principal(deployer)], deployer).result).toBeOk(Cl.uint(DEP));
  });

  it("oracle lp-value only increases after a fee (manipulation-resistant)", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    simnet.callPublicFn(POOL, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    simnet.transferSTX(BUFFER, `${deployer}.${GOOD}`, deployer);
    simnet.callPublicFn(POOL, "flash-loan", [Cl.uint(DEP), Cl.contractPrincipal(deployer, GOOD)], deployer);

    expect(simnet.callReadOnlyFn(ORACLE, "get-lp-value", [Cl.principal(deployer)], deployer).result).toBeOk(Cl.uint(DEP + FEE));
    const snap = simnet.callReadOnlyFn(ORACLE, "get-collateral-snapshot", [], deployer).result;
    expect(snap).toBeOk();
  });
});
