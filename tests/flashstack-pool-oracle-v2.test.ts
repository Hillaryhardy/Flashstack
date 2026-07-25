import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * flashstack-pool-oracle-v2 — the external STX collateral oracle updated to the
 * pool v2 virtual-offset math. The point of v2 is CONSISTENCY: the oracle's
 * reported lp-value / share-price must equal the pool's real share<->asset
 * conversions (they drifted in v1). This suite proves that equality.
 */

const POOL = "flashstack-stx-pool-v2";
const ORACLE = "flashstack-pool-oracle-v2";
const GOOD = "test-pool-receiver-good"; // reads .flashstack-stx-pool fee; unused here (no flash loan)

const DEP = 100_000_000; // 100 STX

describe("flashstack-pool-oracle-v2 (matches pool v2 conversions)", () => {
  let deployer: string;
  let wallet1: string;

  const oracleLpValue = (who: string) =>
    Number((simnet.callReadOnlyFn(ORACLE, "get-lp-value", [Cl.principal(who)], deployer).result as any).value.value);
  const poolStxValue = (who: string) =>
    Number(simnet.callReadOnlyFn(POOL, "get-stx-value", [Cl.principal(who)], deployer).result.value);
  const oracleSharePrice = () =>
    Number((simnet.callReadOnlyFn(ORACLE, "get-share-price", [], deployer).result as any).value.value);

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    wallet1 = simnet.getAccounts().get("wallet_1")!;
  });

  it("oracle lp-value equals the pool's own get-stx-value (no drift)", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP * 3)], wallet1);
    // The oracle a lending protocol reads must equal what the LP can actually withdraw.
    expect(oracleLpValue(deployer)).toBe(poolStxValue(deployer));
    expect(oracleLpValue(wallet1)).toBe(poolStxValue(wallet1));
    expect(oracleLpValue(deployer)).toBe(DEP);
  });

  it("oracle share-price is defined and consistent at launch (F-2 fixed: no scale jump)", () => {
    const launch = oracleSharePrice();
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    expect(oracleSharePrice()).toBe(launch); // one scale before and after the first deposit
  });

  it("oracle reports zero value for a non-LP", () => {
    simnet.callPublicFn(POOL, "deposit", [Cl.uint(DEP)], deployer);
    expect(oracleLpValue(wallet1)).toBe(0);
  });
});
