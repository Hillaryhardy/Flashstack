# FlashStack Comprehensive Test Suite

This document contains all tests to validate the FlashStack protocol functionality.

## Test Environment Setup
- Clarinet console is running
- All contracts loaded successfully
- Test accounts available with 100,000,000 uSTX each

## Test Suite

### TEST 1: Verify Initial State
**Purpose**: Check that contracts are properly initialized

```clarity
;; Check sbtc-token is set up correctly
(contract-call? .sbtc-token get-name)
;; Expected: (ok "Synthetic Bitcoin")

(contract-call? .sbtc-token get-symbol)
;; Expected: (ok "sBTC")

(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)

;; Check flashstack-core initial state
(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u5) ;; 0.05%

(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

(contract-call? .flashstack-core get-admin)
;; Expected: (ok ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(contract-call? .flashstack-core get-stats)
;; Expected: (ok {total-flash-mints: u0, total-volume: u0, total-fees-collected: u0})
```

### TEST 2: Set Flash Minter Authorization
**Purpose**: Authorize flashstack-core to mint/burn sBTC tokens

```clarity
;; Set flashstack-core as the authorized flash minter
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
;; Expected: (ok true)

;; Verify it was set
(contract-call? .sbtc-token get-flash-minter)
;; Expected: (ok ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.flashstack-core)
```

### TEST 3: Calculate Fee
**Purpose**: Verify fee calculation is correct (0.05% = 5 basis points)

```clarity
;; Test fee calculation
(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u500) ;; 0.05% of 1,000,000 = 500

(contract-call? .flashstack-core calculate-fee u100000000)
;; Expected: (ok u50000) ;; 0.05% of 100,000,000 = 50,000

(contract-call? .flashstack-core calculate-fee u10000)
;; Expected: (ok u5) ;; 0.05% of 10,000 = 5
```

### TEST 4: Basic Flash Mint with test-receiver
**Purpose**: Test the complete flash loan cycle

```clarity
;; Execute a flash mint of 1,000,000 sBTC
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {amount: u1000000, fee: u500, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})

;; Check stats were updated
(contract-call? .flashstack-core get-stats)
;; Expected: (ok {total-flash-mints: u1, total-volume: u1000000, total-fees-collected: u500})

;; Verify total supply returned to 0 (tokens minted and burned in same transaction)
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)
```

### TEST 5: Multiple Flash Mints
**Purpose**: Verify protocol can handle multiple transactions

```clarity
;; Execute second flash mint
(contract-call? .flashstack-core flash-mint u5000000 .test-receiver)
;; Expected: (ok {amount: u5000000, fee: u2500, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})

;; Check cumulative stats
(contract-call? .flashstack-core get-stats)
;; Expected: (ok {total-flash-mints: u2, total-volume: u6000000, total-fees-collected: u3000})

;; Execute third flash mint
(contract-call? .flashstack-core flash-mint u250000 .test-receiver)
;; Expected: (ok {amount: u250000, fee: u125, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})

;; Check final cumulative stats
(contract-call? .flashstack-core get-stats)
;; Expected: (ok {total-flash-mints: u3, total-volume: u6250000, total-fees-collected: u3125})
```

### TEST 6: Test with Example Arbitrage Receiver
**Purpose**: Test with a more complex receiver contract

```clarity
;; Set up DEX prices for arbitrage
(contract-call? .example-arbitrage-receiver set-dex-a-price u9500)
(contract-call? .example-arbitrage-receiver set-dex-b-price u10500)

;; Calculate potential profit
(contract-call? .example-arbitrage-receiver calculate-potential-profit u1000000)
;; Expected: Should show profit calculation

;; Execute flash mint through arbitrage receiver
(contract-call? .flashstack-core flash-mint u1000000 .example-arbitrage-receiver)
;; Expected: (ok {amount: u1000000, fee: u500, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})
```

### TEST 7: Admin Functions
**Purpose**: Test administrative controls

```clarity
;; Test pause function
(contract-call? .flashstack-core pause)
;; Expected: (ok true)

;; Verify paused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok true)

;; Try to flash mint while paused (should fail)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (err u103) ;; err-paused

;; Unpause
(contract-call? .flashstack-core unpause)
;; Expected: (ok true)

;; Verify unpaused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

;; Flash mint should work again
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {amount: u1000000, fee: u500, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})
```

### TEST 8: Fee Adjustment
**Purpose**: Test changing the fee rate

```clarity
;; Change fee to 0.1% (10 basis points)
(contract-call? .flashstack-core set-fee u10)
;; Expected: (ok true)

;; Verify new fee
(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u10)

;; Calculate fee with new rate
(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u1000) ;; 0.1% of 1,000,000 = 1,000

;; Execute flash mint with new fee
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {amount: u1000000, fee: u1000, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})

;; Reset fee to original 0.05%
(contract-call? .flashstack-core set-fee u5)
;; Expected: (ok true)
```

### TEST 9: Error Conditions
**Purpose**: Verify proper error handling

```clarity
;; Try to flash mint 0 amount (should fail)
(contract-call? .flashstack-core flash-mint u0 .test-receiver)
;; Expected: (err u101) ;; err-invalid-amount

;; Try to set invalid fee (> 100%)
(contract-call? .flashstack-core set-fee u10001)
;; Expected: (err u104) ;; err-invalid-fee
```

### TEST 10: Large Amount Flash Mint
**Purpose**: Test with realistic large amounts

```clarity
;; Execute large flash mint (100 million sBTC)
(contract-call? .flashstack-core flash-mint u100000000 .test-receiver)
;; Expected: (ok {amount: u100000000, fee: u50000, borrower: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM})

;; Verify total supply is still 0
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)
```

## Test Results Summary

After running all tests, verify:
- ✅ All contracts initialized correctly
- ✅ Flash minter authorization works
- ✅ Fee calculations are accurate
- ✅ Basic flash mints execute successfully
- ✅ Multiple flash mints accumulate stats correctly
- ✅ Complex receivers (arbitrage) work properly
- ✅ Pause/unpause controls function
- ✅ Fee adjustments work correctly
- ✅ Error handling is proper
- ✅ Large amounts are handled correctly
- ✅ Total supply always returns to 0 after flash mints

## Final Verification

```clarity
;; Get final statistics
(contract-call? .flashstack-core get-stats)
;; Should show accumulated totals from all tests

;; Verify sBTC supply is 0
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)

;; Verify protocol is not paused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)
```

## Notes
- All flash mints should complete atomically
- The total supply should always return to 0 after each flash mint
- Stats should accumulate correctly across all transactions
- Fee mechanism must mint the total amount (principal + fee) for repayment
