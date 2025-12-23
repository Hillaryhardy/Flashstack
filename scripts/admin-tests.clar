;; =============================================================================
;; FlashStack Admin Functions Test Suite
;; Tests: pause, unpause, fee adjustment, admin controls
;; =============================================================================

;; --- SETUP ---
;; Set flash minter authorization
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

;; Verify initial state
(contract-call? .flashstack-core get-admin)
;; Expected: (ok ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u5) - 0.05%

;; =============================================================================
;; TEST SUITE 1: PAUSE/UNPAUSE FUNCTIONALITY
;; =============================================================================

;; --- Test 1.1: Normal Flash Mint (Before Pause) ---
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {...}) - Should succeed

(contract-call? .flashstack-core get-stats)
;; Expected: total-flash-mints: u1

;; --- Test 1.2: Pause the Protocol ---
(contract-call? .flashstack-core pause)
;; Expected: (ok true)

;; Verify paused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok true)

;; --- Test 1.3: Try Flash Mint While Paused (Should Fail) ---
(contract-call? .flashstack-core flash-mint u500000 .test-receiver)
;; Expected: (err u105) - ERR-PAUSED

;; Verify stats unchanged
(contract-call? .flashstack-core get-stats)
;; Expected: total-flash-mints: u1 (unchanged)

;; --- Test 1.4: Unpause the Protocol ---
(contract-call? .flashstack-core unpause)
;; Expected: (ok true)

;; Verify unpaused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

;; --- Test 1.5: Flash Mint After Unpause (Should Work) ---
(contract-call? .flashstack-core flash-mint u2000000 .test-receiver)
;; Expected: (ok {...}) - Should succeed

(contract-call? .flashstack-core get-stats)
;; Expected: total-flash-mints: u2

;; =============================================================================
;; TEST SUITE 2: FEE ADJUSTMENT
;; =============================================================================

;; --- Test 2.1: Check Current Fee ---
(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u5) - 0.05%

(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u500) - 0.05% of 1M

;; --- Test 2.2: Change Fee to 0.1% (10 basis points) ---
(contract-call? .flashstack-core set-fee u10)
;; Expected: (ok true)

;; Verify new fee
(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u10)

(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u1000) - 0.1% of 1M = 1,000

;; --- Test 2.3: Flash Mint with New Fee (0.1%) ---
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {fee: u1000, ...})

(contract-call? .flashstack-core get-stats)
;; Expected: Shows fee of 1000 added to total-fees-collected

;; --- Test 2.4: Change Fee to 0.25% (25 basis points) ---
(contract-call? .flashstack-core set-fee u25)
;; Expected: (ok true)

(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u2500) - 0.25% of 1M = 2,500

;; --- Test 2.5: Flash Mint with 0.25% Fee ---
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {fee: u2500, ...})

;; --- Test 2.6: Change Fee to 1% (100 basis points) ---
(contract-call? .flashstack-core set-fee u100)
;; Expected: (ok true)

(contract-call? .flashstack-core calculate-fee u1000000)
;; Expected: (ok u10000) - 1% of 1M = 10,000

;; --- Test 2.7: Flash Mint with 1% Fee ---
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
;; Expected: (ok {fee: u10000, ...})

;; --- Test 2.8: Try Invalid Fee (>100%) - Should Fail ---
(contract-call? .flashstack-core set-fee u10001)
;; Expected: (err u102) - ERR-UNAUTHORIZED (fee validation)

;; --- Test 2.9: Reset to Original Fee (0.05%) ---
(contract-call? .flashstack-core set-fee u5)
;; Expected: (ok true)

(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u5)

;; =============================================================================
;; TEST SUITE 3: ERROR CONDITIONS
;; =============================================================================

;; --- Test 3.1: Try Zero Amount Flash Mint ---
(contract-call? .flashstack-core flash-mint u0 .test-receiver)
;; Expected: (err u104) - ERR-INVALID-AMOUNT

;; --- Test 3.2: Multiple Pause/Unpause Cycles ---
(contract-call? .flashstack-core pause)
(contract-call? .flashstack-core is-paused)
;; Expected: (ok true)

(contract-call? .flashstack-core unpause)
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

(contract-call? .flashstack-core pause)
(contract-call? .flashstack-core is-paused)
;; Expected: (ok true)

(contract-call? .flashstack-core unpause)
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

;; =============================================================================
;; TEST SUITE 4: FINAL VERIFICATION
;; =============================================================================

;; Get final statistics
(contract-call? .flashstack-core get-stats)
;; Should show multiple flash mints with varying fees

;; Verify total supply is still 0
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)

;; Verify not paused
(contract-call? .flashstack-core is-paused)
;; Expected: (ok false)

;; Verify fee is back to 0.05%
(contract-call? .flashstack-core get-fee-basis-points)
;; Expected: (ok u5)

;; =============================================================================
;; EXPECTED RESULTS SUMMARY
;; =============================================================================
;;
;; Total Flash Mints: ~6 successful
;; - 1 before pause
;; - 1 after unpause
;; - 1 with 0.1% fee
;; - 1 with 0.25% fee
;; - 1 with 1% fee
;;
;; Total Fees Collected:
;; - First: 500 (0.05% of 1M)
;; - Second: 1000 (0.05% of 2M)
;; - Third: 1000 (0.1% of 1M)
;; - Fourth: 2500 (0.25% of 1M)
;; - Fifth: 10000 (1% of 1M)
;; = 15,000 total fees
;;
;; Failed Attempts:
;; - 1 while paused (err u105)
;; - 1 with zero amount (err u104)
;; - 1 with invalid fee >100% (err u102)
;;
;; Final State:
;; - Not paused
;; - Fee at 0.05% (u5)
;; - Total supply: 0
;; - Protocol ready for production
;;
;; =============================================================================
