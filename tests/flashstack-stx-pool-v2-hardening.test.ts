import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * F-1 fix verification: flashstack-stx-pool-v2 adds virtual shares + virtual
 * assets (OpenZeppelin ERC-4626 inflation-attack mitigation).
 *
 * Two things are proven here:
 *   1. Regression — honest deposits/withdrawals are still exact (the virtual
 *      offset costs honest LPs nothing at these scales).
 *   2. Neutralization — the first-depositor / donation inflation attack that the
 *      v1 pool is vulnerable to is defused: on v2 the attacker cannot recover
 *      their donation and the victim keeps ~their full deposit. The SAME attack
 *      is run against the deployed v1 pool to show the contrast.
 */

const V2 = "flashstack-stx-pool-v2";
const V1 = "flashstack-stx-pool"; // deployed (vulnerable) pool, for contrast

const DEP = 100_000_000; // 100 STX
const ATTACKER_DEP = 1; // 1 microSTX
const DONATION = 10_000_000_000; // 10,000 STX donated directly to the pool
const VICTIM_DEP = 100_000_000; // 100 STX

describe("flashstack-stx-pool-v2 (F-1 hardening: virtual shares/assets)", () => {
  let deployer: string;
  let attacker: string;
  let victim: string;

  const stxValue = (pool: string, who: string) =>
    Number(simnet.callReadOnlyFn(pool, "get-stx-value", [Cl.principal(who)], deployer).result.value);

  // deposit / donate / victim-deposit — the classic inflation setup
  const runInflationAttack = (pool: string) => {
    simnet.callPublicFn(pool, "deposit", [Cl.uint(ATTACKER_DEP)], attacker);
    simnet.transferSTX(DONATION, `${deployer}.${pool}`, attacker); // direct donation, mints no shares
    simnet.callPublicFn(pool, "deposit", [Cl.uint(VICTIM_DEP)], victim);
  };

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    attacker = simnet.getAccounts().get("wallet_1")!;
    victim = simnet.getAccounts().get("wallet_2")!;
  });

  // --- Regression: honest LPs unaffected ---------------------------------
  it("a sole honest LP withdraws exactly what they deposited", () => {
    simnet.callPublicFn(V2, "deposit", [Cl.uint(DEP)], deployer);
    const shares = Number(simnet.callReadOnlyFn(V2, "get-shares", [Cl.principal(deployer)], deployer).result.value);
    expect(simnet.callPublicFn(V2, "withdraw", [Cl.uint(shares)], deployer).result).toBeOk(Cl.uint(DEP));
  });

  it("two honest LPs each hold their fair share", () => {
    simnet.callPublicFn(V2, "deposit", [Cl.uint(DEP)], deployer);
    simnet.callPublicFn(V2, "deposit", [Cl.uint(DEP)], attacker);
    expect(stxValue(V2, deployer)).toBe(DEP);
    expect(stxValue(V2, attacker)).toBe(DEP);
  });

  // --- Neutralization proof ----------------------------------------------
  it("v2 defuses the inflation attack: victim protected, attacker cannot recover the donation", () => {
    runInflationAttack(V2);

    const victimValue = stxValue(V2, victim);
    const attackerValue = stxValue(V2, attacker);

    // Victim keeps essentially their whole deposit (>= 99%).
    expect(victimValue).toBeGreaterThanOrEqual(VICTIM_DEP * 0.99);
    // Attacker cannot recover the 10,000 STX they donated -> the attack loses money.
    expect(attackerValue).toBeLessThan(DONATION);
  });

  it("contrast: the deployed v1 pool lets the attacker recover the donation (the vulnerability being fixed)", () => {
    runInflationAttack(V1);

    const attackerValueV1 = stxValue(V1, attacker);
    // On v1 the attacker recovers ~their donation (>= the donated amount) — exactly the F-1 vector.
    expect(attackerValueV1).toBeGreaterThanOrEqual(DONATION);

    // Same attack on v2 for a side-by-side: attacker recovers far less.
    runInflationAttack(V2);
    expect(stxValue(V2, attacker)).toBeLessThan(attackerValueV1 / 2 + 1);
  });
});
