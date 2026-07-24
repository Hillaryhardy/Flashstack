import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

/**
 * Tests for the DEPLOYED reserve-model core: flashstack-stx-core
 * (mainnet SP20XD46...flashstack-stx-core). The contract under test is a
 * localized copy — byte-identical logic, trait reference pointed at the local
 * trait for simnet. Covers the two invariants that make the protocol safe
 * (reserve grows by exactly the fee; unpaid loans revert) plus every guard.
 *
 * Error codes: 300 NOT-ADMIN · 301 ZERO-AMOUNT · 302 REPAY-FAILED
 * 303 INSUFFICIENT-RESERVE · 304 EXCEEDS-LIMIT · 305 PAUSED · 306 NOT-APPROVED
 */

const CORE = "flashstack-stx-core";
const GOOD = "test-receiver-good";
const BAD = "test-receiver-bad";

const RESERVE = 1_000_000_000; // 1,000 STX seeded
const LOAN = 100_000_000; //   100 STX borrowed
const FEE = 50_000; //   0.05% of 100 STX
const BUFFER = 1_000_000; //   1 STX funded into the good receiver to cover the fee

describe("flashstack-stx-core (deployed reserve model)", () => {
  let deployer: string;
  let wallet1: string;

  const reserveBalance = () =>
    Number(simnet.callReadOnlyFn(CORE, "get-reserve-balance", [], deployer).result.value);

  const seedAndApprove = (receiver: string) => {
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer);
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, receiver)], deployer);
  };

  beforeEach(() => {
    deployer = simnet.getAccounts().get("deployer")!;
    wallet1 = simnet.getAccounts().get("wallet_1")!;
  });

  // --- Admin gating ------------------------------------------------------
  it("deposit-reserve credits the reserve; non-admin is rejected", () => {
    expect(simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer).result).toBeOk(Cl.bool(true));
    expect(simnet.callReadOnlyFn(CORE, "get-reserve-balance", [], deployer).result).toBeUint(RESERVE);
    expect(simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], wallet1).result).toBeErr(Cl.uint(300));
  });

  it("only the admin can whitelist a receiver", () => {
    expect(
      simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], wallet1).result
    ).toBeErr(Cl.uint(300));
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    expect(
      simnet.callReadOnlyFn(CORE, "is-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeBool(true);
  });

  // --- The invariants ----------------------------------------------------
  it("happy path: an approved receiver repays, and the reserve grows by exactly the fee", () => {
    seedAndApprove(GOOD);
    simnet.transferSTX(BUFFER, `${deployer}.${GOOD}`, deployer);
    const before = reserveBalance();

    const { result } = simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer);

    expect(result).toBeOk(Cl.bool(true));
    expect(reserveBalance()).toBe(before + FEE);
    expect(simnet.callReadOnlyFn(CORE, "get-stats", [], deployer).result).toBeOk();
  });

  it("repay-or-revert: a receiver that keeps the funds reverts, and the reserve is untouched", () => {
    seedAndApprove(BAD);
    const before = reserveBalance();

    const { result } = simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, BAD)], deployer);

    expect(result).toBeErr(Cl.uint(302)); // ERR-REPAY-FAILED
    expect(reserveBalance()).toBe(before); // fully rolled back
  });

  // --- Guards ------------------------------------------------------------
  it("rejects an unapproved receiver (306)", () => {
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(RESERVE)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(306));
  });

  it("rejects a loan above max-single-loan (304)", () => {
    seedAndApprove(GOOD);
    simnet.callPublicFn(CORE, "set-max-single-loan", [Cl.uint(BUFFER)], deployer); // cap at 1 STX
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(304));
  });

  it("rejects a loan larger than the reserve (303)", () => {
    simnet.callPublicFn(CORE, "deposit-reserve", [Cl.uint(LOAN)], deployer); // reserve = 100 STX
    simnet.callPublicFn(CORE, "add-approved-receiver", [Cl.contractPrincipal(deployer, GOOD)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN * 2), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(303));
  });

  it("rejects loans while paused (305)", () => {
    seedAndApprove(GOOD);
    simnet.callPublicFn(CORE, "set-paused", [Cl.bool(true)], deployer);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(LOAN), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(305));
  });

  it("rejects a zero-amount loan (301)", () => {
    seedAndApprove(GOOD);
    expect(
      simnet.callPublicFn(CORE, "flash-loan", [Cl.uint(0), Cl.contractPrincipal(deployer, GOOD)], deployer).result
    ).toBeErr(Cl.uint(301));
  });
});
