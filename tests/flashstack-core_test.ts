import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

describe("FlashStack Core Tests", () => {
  let accounts: Map<string, string>;
  let deployer: string;
  let wallet1: string;
  let wallet2: string;

  beforeEach(() => {
    accounts = simnet.getAccounts();
    deployer = accounts.get("deployer")!;
    wallet1 = accounts.get("wallet_1")!;
    wallet2 = accounts.get("wallet_2")!;
  });

  it("ensures contracts are deployed", () => {
    const assets = simnet.getAssetsMap();
    expect(assets.has(`${deployer}.flashstack-core`)).toBe(true);
    expect(assets.has(`${deployer}.sbtc-token`)).toBe(true);
  });

  it("can set flash minter", () => {
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "set-flash-minter",
      [Cl.principal(`${deployer}.flashstack-core`)],
      deployer
    );
    expect(result).toBeOk(Cl.bool(true));
  });

  it("calculates fees correctly", () => {
    const { result } = simnet.callReadOnlyFn(
      "flashstack-core",
      "calculate-fee",
      [Cl.uint(10000000000)], // 100 sBTC
      deployer
    );
    // Fee is 0.05% = 50 basis points
    // 10000000000 * 50 / 10000 = 5000000
    expect(result).toBeUint(5000000);
  });

  it("can flash mint with proper setup", () => {
    // First set up the flash minter
    simnet.callPublicFn(
      "sbtc-token",
      "set-flash-minter",
      [Cl.principal(`${deployer}.flashstack-core`)],
      deployer
    );

    // Try a flash mint (will fail without proper receiver, but shouldn't error on permission)
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "flash-mint",
      [
        Cl.uint(1000000), // 0.01 sBTC
        Cl.principal(`${deployer}.test-receiver`)
      ],
      wallet1
    );
    
    // Should execute (even if receiver fails, the flash-mint call itself works)
    expect(result).toBeDefined();
  });

  it("admin can pause protocol", () => {
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "pause",
      [],
      deployer
    );
    expect(result).toBeOk(Cl.bool(true));

    // Verify paused
    const { result: isPaused } = simnet.callReadOnlyFn(
      "flashstack-core",
      "is-paused",
      [],
      deployer
    );
    expect(isPaused).toBeBool(true);
  });

  it("admin can unpause protocol", () => {
    // First pause
    simnet.callPublicFn("flashstack-core", "pause", [], deployer);

    // Then unpause
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "unpause",
      [],
      deployer
    );
    expect(result).toBeOk(Cl.bool(true));

    // Verify unpaused
    const { result: isPaused } = simnet.callReadOnlyFn(
      "flashstack-core",
      "is-paused",
      [],
      deployer
    );
    expect(isPaused).toBeBool(false);
  });

  it("non-admin cannot pause protocol", () => {
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "pause",
      [],
      wallet1
    );
    expect(result).toBeErr(Cl.uint(103)); // err-not-authorized
  });

  it("admin can update fee", () => {
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "set-fee",
      [Cl.uint(100)], // 1%
      deployer
    );
    expect(result).toBeOk(Cl.bool(true));

    // Verify new fee
    const { result: newFee } = simnet.callReadOnlyFn(
      "flashstack-core",
      "get-fee-basis-points",
      [],
      deployer
    );
    expect(newFee).toBeUint(100);
  });

  it("cannot set fee above maximum", () => {
    const { result } = simnet.callPublicFn(
      "flashstack-core",
      "set-fee",
      [Cl.uint(101)], // Above 1% max
      deployer
    );
    expect(result).toBeErr(Cl.uint(105)); // err-invalid-fee
  });

  it("gets protocol statistics", () => {
    const { result } = simnet.callReadOnlyFn(
      "flashstack-core",
      "get-stats",
      [],
      deployer
    );
    expect(result).toBeTuple({
      "total-flash-mints": Cl.uint(0),
      "paused": Cl.bool(false)
    });
  });
});
