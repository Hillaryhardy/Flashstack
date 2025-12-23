import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

describe("sBTC Token Tests", () => {
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

  it("returns correct token metadata", () => {
    const name = simnet.callReadOnlyFn("sbtc-token", "get-name", [], deployer);
    const symbol = simnet.callReadOnlyFn("sbtc-token", "get-symbol", [], deployer);
    const decimals = simnet.callReadOnlyFn("sbtc-token", "get-decimals", [], deployer);

    expect(name.result).toBeOk(Cl.stringAscii("Stacks Bitcoin"));
    expect(symbol.result).toBeOk(Cl.stringAscii("sBTC"));
    expect(decimals.result).toBeOk(Cl.uint(8));
  });

  it("returns zero for initial token supply", () => {
    const { result } = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-total-supply",
      [],
      deployer
    );
    expect(result).toBeOk(Cl.uint(0));
  });

  it("only authorized minter can mint tokens", () => {
    // Unauthorized mint should fail
    const { result: failResult } = simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      wallet1
    );
    expect(failResult).toBeErr(Cl.uint(401)); // ERR-NOT-AUTHORIZED

    // Authorized mint should succeed (deployer is owner)
    const { result: successResult } = simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      deployer
    );
    expect(successResult).toBeOk(Cl.bool(true));
  });

  it("can transfer tokens between accounts", () => {
    // Mint tokens to wallet1
    simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      deployer
    );

    // Transfer from wallet1 to wallet2
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "transfer",
      [
        Cl.uint(500000000),
        Cl.principal(wallet1),
        Cl.principal(wallet2),
        Cl.none()
      ],
      wallet1
    );
    expect(result).toBeOk(Cl.bool(true));

    // Check balances
    const balance1 = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-balance",
      [Cl.principal(wallet1)],
      deployer
    );
    const balance2 = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-balance",
      [Cl.principal(wallet2)],
      deployer
    );

    expect(balance1.result).toBeOk(Cl.uint(500000000));
    expect(balance2.result).toBeOk(Cl.uint(500000000));
  });

  it("can burn tokens", () => {
    // Mint tokens first
    simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      deployer
    );

    // Burn tokens
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "burn",
      [Cl.uint(500000000), Cl.principal(wallet1)],
      deployer
    );
    expect(result).toBeOk(Cl.bool(true));

    // Verify balance reduced
    const { result: balance } = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-balance",
      [Cl.principal(wallet1)],
      deployer
    );
    expect(balance).toBeOk(Cl.uint(500000000));
  });

  it("can set and verify flash minter", () => {
    // Set flashstack-core as flash minter
    const { result: setResult } = simnet.callPublicFn(
      "sbtc-token",
      "set-flash-minter",
      [Cl.principal(`${deployer}.flashstack-core`)],
      deployer
    );
    expect(setResult).toBeOk(Cl.bool(true));

    // Verify flash minter
    const { result: getResult } = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-flash-minter",
      [],
      deployer
    );
    expect(getResult).toBeOk(Cl.principal(`${deployer}.flashstack-core`));
  });

  it("only owner can set flash minter", () => {
    // Non-owner tries to set flash minter
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "set-flash-minter",
      [Cl.principal(wallet1)],
      wallet1
    );
    expect(result).toBeErr(Cl.uint(401)); // ERR-NOT-AUTHORIZED
  });

  it("tracks total supply correctly after mint and burn", () => {
    // Mint
    simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      deployer
    );

    // Check supply after mint
    let { result: supply } = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-total-supply",
      [],
      deployer
    );
    expect(supply).toBeOk(Cl.uint(1000000000));

    // Burn half
    simnet.callPublicFn(
      "sbtc-token",
      "burn",
      [Cl.uint(500000000), Cl.principal(wallet1)],
      deployer
    );

    // Check supply after burn
    ({ result: supply } = simnet.callReadOnlyFn(
      "sbtc-token",
      "get-total-supply",
      [],
      deployer
    ));
    expect(supply).toBeOk(Cl.uint(500000000));
  });

  it("prevents insufficient balance transfers", () => {
    // Mint tokens first
    simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(100), Cl.principal(wallet1)],
      deployer
    );

    // Try to transfer more than balance
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "transfer",
      [
        Cl.uint(200),
        Cl.principal(wallet1),
        Cl.principal(wallet2),
        Cl.none()
      ],
      wallet1
    );
    expect(result).toBeErr(Cl.uint(1)); // u1 is ft-insufficient-balance
  });

  it("allows transfers with memo", () => {
    // Mint tokens
    simnet.callPublicFn(
      "sbtc-token",
      "mint",
      [Cl.uint(1000000000), Cl.principal(wallet1)],
      deployer
    );

    // Transfer with memo
    const memo = Cl.bufferFromUtf8("Flash loan repayment");
    const { result } = simnet.callPublicFn(
      "sbtc-token",
      "transfer",
      [
        Cl.uint(500000000),
        Cl.principal(wallet1),
        Cl.principal(wallet2),
        Cl.some(memo)
      ],
      wallet1
    );
    expect(result).toBeOk(Cl.bool(true));
  });
});
