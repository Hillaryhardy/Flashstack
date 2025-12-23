# FlashStack Bug Fixes - December 2025


---

> **This document is from December 7, 2025** - when we finished testnet testing.  
> Check the main [README.md](../../README.md) for current status.
> 
> **Where we are now (Dec 23):**  
> - Repo is public on GitHub
> - Still on testnet (no audit yet)  
> - Applying for grants to fund the audit


## Issues Found and Fixed

### Issue 1: Incorrect Default Fee
**Problem**: Flash fee was set to u50 (0.5%) instead of u5 (0.05%)
**Location**: `flashstack-core.clar` line 19
**Fix**: Changed `(define-data-var flash-fee-basis-points uint u50)` to `u5`
**Impact**: Makes flash loans 10x cheaper and more competitive

### Issue 2: Test Receiver Not Transferring Tokens
**Problem**: `test-receiver.clar` wasn't transferring borrowed tokens back to flashstack-core
**Location**: `test-receiver.clar` - entire execute-flash function
**Fix**: Added proper token transfer logic:
```clarity
(try! (contract-call? .sbtc-token transfer 
  total-owed 
  tx-sender 
  .flashstack-core 
  none))
```
**Impact**: Critical - flash mints will now complete successfully

### Issue 3: Inconsistent Fee in All Receiver Contracts
**Problem**: All receiver contracts used u50 instead of u5
**Location**: Multiple receiver contracts
**Files Fixed**:
- ✅ test-receiver.clar
- ✅ example-arbitrage-receiver.clar  
- ✅ liquidation-receiver.clar
- ✅ leverage-loop-receiver.clar
- ✅ multidex-arbitrage-receiver.clar
- ✅ dex-aggregator-receiver.clar
- ✅ yield-optimization-receiver.clar
- ✅ collateral-swap-receiver.clar
**Fix**: Changed all instances of `u50` to `u5` in fee calculations
**Impact**: Ensures all examples calculate fees correctly

## Verification Steps

1. ✅ Core contract fee updated
2. ✅ Test receiver fixed to transfer tokens back
3. ✅ All 8 receiver contracts updated with correct fee
4. ✅ Test documentation created (COMPREHENSIVE_TESTS.md)
5. ✅ Quick test script created (quick-test-script.clar)

## Testing Required

Run the following in your open Clarinet console:

### Critical Test Sequence
```clarity
;; 1. Set authorization
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

;; 2. Test basic flash mint
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {amount: u1000000, fee: u50, ...})

;; 3. Verify stats updated
(contract-call? .flashstack-core get-stats)
;; Expected: total-flash-mints: u1, total-fees-collected: u50

;; 4. Verify supply is 0 (tokens burned after flash mint)
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)
```

## What Changed Technically

### Fee Mechanism (Working Correctly Now)
1. Flash mint of 1,000,000 sBTC with 0.05% fee:
   - Fee = 1,000,000 * 0.0005 = 500 sBTC (was 5,000)
   - Total minted to receiver = 1,000,500 sBTC
   - Receiver must return exactly 1,000,500 sBTC
   - Net effect: Protocol collects 500 sBTC fee

### Token Flow (Fixed)
Before (BROKEN):
1. Mint amount to receiver
2. Receiver returns nothing
3. Flash mint fails ❌

After (FIXED):
1. Mint (amount + fee) to receiver
2. Receiver does operations  
3. Receiver transfers (amount + fee) back to flashstack-core
4. Flash mint succeeds ✅
5. Tokens automatically burned, supply returns to 0

## Files Modified

Total: 9 files

### Core Contracts
1. `contracts/flashstack-core.clar` - Fee changed from u50 to u5

### Receiver Contracts
2. `contracts/test-receiver.clar` - Added transfer logic + fee fix
3. `contracts/example-arbitrage-receiver.clar` - Fee fix
4. `contracts/liquidation-receiver.clar` - Fee fix (3 locations)
5. `contracts/leverage-loop-receiver.clar` - Fee fix (2 locations)
6. `contracts/multidex-arbitrage-receiver.clar` - Fee fix
7. `contracts/dex-aggregator-receiver.clar` - Fee fix
8. `contracts/yield-optimization-receiver.clar` - Fee fix
9. `contracts/collateral-swap-receiver.clar` - Fee fix

### Documentation
- Created: `COMPREHENSIVE_TESTS.md` - Full test suite with expected results
- Created: `quick-test-script.clar` - Copy-paste test commands

## Next Steps

1. **RESTART Clarinet Console** to reload all contracts with fixes
2. Run comprehensive tests from `quick-test-script.clar`
3. Verify all tests pass
4. Update knowledge base with test results
5. Ready for testnet deployment

## Fee Structure Confirmation

| Amount      | Fee @ 0.05% | Total Owed  |
|-------------|-------------|-------------|
| 1,000       | 0.5         | 1,000.5     |
| 10,000      | 5           | 10,005      |
| 100,000     | 50          | 100,050     |
| 1,000,000   | 500         | 1,000,500   |
| 100,000,000 | 50,000      | 100,050,000 |

## Success Criteria

- [x] All contracts compile without errors
- [ ] Basic flash mint succeeds
- [ ] Stats accumulate correctly  
- [ ] Token supply returns to 0
- [ ] Multiple flash mints work
- [ ] Different receivers work
- [ ] Pause/unpause functions work
- [ ] Fee adjustment works
- [ ] Error conditions handled properly

---

**Status**: Ready for Testing
**Date**: December 2025
**Version**: v1.1
