import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * F-1 fix verification for the sBTC pool: flashstack-sbtc-pool-v2 adds virtual
 * shares + virtual assets (OpenZeppelin ERC-4626 mitigation), applied through
 * the built-in oracle. Same proof as the STX v2 suite: honest LPs unaffected,
 * the inflation attack is neutralized, and the deployed v1 sBTC pool is shown to
 * be vulnerable to the same attack for contrast.
 */

const V2 = "flashstack-sbtc-pool-v2";
const V1 = "flashstack-sbtc-pool"; // deployed (vulnerable) sBTC pool

const DEP = 1_000_000; // 0.01 BTC (sats)
const ATTACKER_DEP = 1; // 1 sat
const DONATION = 100_000_000; // 1 BTC donated directly to the pool
const VICTIM_DEP = 1_000_000; // 0.01 BTC

describe("flashstack-sbtc-pool-v2 (F-1 hardening: virtual shares/assets)", () => {
  let deployer: string;
  let attacker: string;
  let victim: string;

  const mint = (amount: number, to: string) =>
    simnet.callPublicFn("sbtc-token", "mint", [Cl.uint(amount), Cl.principal(to)], deployer);
  const depositAs = (pool: string, amount: number, who: string) => {
    mint(amount, who);
    return simnet.callPublicFn(pool, "deposit", [Cl.uint(amount)], who);
  };
  const lpValue = (pool: string, who: string) =>
    Number((simnet.callReadOnlyFn(pool, "get-lp-value", [Cl.principal(who)], deployer).result as any).value.value);
  const shares = (pool: string, who: string) =>
    Number(simnet.callReadOnlyFn(pool, "get-shares", [Cl.principal(who)], deployer).result.value);

  const runInflationAttack = (pool: string) => {
    depositAs(pool, ATTACKER_DEP, attacker);
    mint(DONATION, attacker);
    simnet.callPublicFn("sbtc-token", "transfer",
      [Cl.uint(DONATION), Cl.principal(attacker), Cl.principal(`${deployer}.${pool}`), Cl.none()], attacker); // donation
    depositAs(pool, VICTIM_DEP, victim);
  };

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    attacker = simnet.getAccounts().get("wallet_1")!;
    victim = simnet.getAccounts().get("wallet_2")!;
  });

  // --- Regression: honest LPs unaffected ---------------------------------
  it("a sole honest LP withdraws exactly what they deposited", () => {
    depositAs(V2, DEP, deployer);
    expect(simnet.callPublicFn(V2, "withdraw", [Cl.uint(shares(V2, deployer))], deployer).result).toBeOk(Cl.uint(DEP));
  });

  // --- Neutralization proof ----------------------------------------------
  it("v2 defuses the inflation attack: victim protected, attacker cannot recover the donation", () => {
    runInflationAttack(V2);
    expect(lpValue(V2, victim)).toBeGreaterThanOrEqual(VICTIM_DEP * 0.99);
    expect(lpValue(V2, attacker)).toBeLessThan(DONATION);
  });

  it("contrast: the deployed v1 sBTC pool lets the attacker recover the donation", () => {
    runInflationAttack(V1);
    const attackerValueV1 = lpValue(V1, attacker);
    expect(attackerValueV1).toBeGreaterThanOrEqual(DONATION);

    runInflationAttack(V2);
    expect(lpValue(V2, attacker)).toBeLessThan(attackerValueV1 / 2 + 1);
  });

  // --- Oracle consistency (F-2 also fixed here) --------------------------
  it("built-in oracle share-price is consistent at launch and after a deposit (no scale jump)", () => {
    const launch = Number((simnet.callReadOnlyFn(V2, "get-share-price", [], deployer).result as any).value.value);
    depositAs(V2, DEP, deployer);
    const afterDeposit = Number((simnet.callReadOnlyFn(V2, "get-share-price", [], deployer).result as any).value.value);
    // v1 jumps from SHARE-PRECISION (1e8) to ~1; v2 stays on one scale.
    expect(launch).toBe(afterDeposit);
  });
});
