;; =============================================================================
;; FlashStack Quick Test Script
;; Copy-paste these commands into your Clarinet console one at a time
;; =============================================================================

;; --- STEP 1: Verify Initial State ---
(contract-call? .sbtc-token get-name)
(contract-call? .sbtc-token get-symbol)
(contract-call? .sbtc-token get-total-supply)
(contract-call? .flashstack-core get-fee-basis-points)
(contract-call? .flashstack-core is-paused)
(contract-call? .flashstack-core get-stats)

;; --- STEP 2: Set Flash Minter Authorization (CRITICAL!) ---
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
(contract-call? .sbtc-token get-flash-minter)

;; --- STEP 3: Test Fee Calculation ---
(contract-call? .flashstack-core calculate-fee u1000000)
(contract-call? .flashstack-core calculate-fee u100000000)

;; --- STEP 4: Execute First Flash Mint ---
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
(contract-call? .flashstack-core get-stats)
(contract-call? .sbtc-token get-total-supply)

;; --- STEP 5: Execute More Flash Mints ---
(contract-call? .flashstack-core flash-mint u5000000 .test-receiver)
(contract-call? .flashstack-core get-stats)

(contract-call? .flashstack-core flash-mint u250000 .test-receiver)
(contract-call? .flashstack-core get-stats)

;; --- STEP 6: Test Arbitrage Receiver ---
(contract-call? .example-arbitrage-receiver set-dex-a-price u9500)
(contract-call? .example-arbitrage-receiver set-dex-b-price u10500)
(contract-call? .example-arbitrage-receiver calculate-potential-profit u1000000)
(contract-call? .flashstack-core flash-mint u1000000 .example-arbitrage-receiver)

;; --- STEP 7: Test Pause/Unpause ---
(contract-call? .flashstack-core pause)
(contract-call? .flashstack-core is-paused)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
(contract-call? .flashstack-core unpause)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)

;; --- STEP 8: Test Fee Adjustment ---
(contract-call? .flashstack-core set-fee u10)
(contract-call? .flashstack-core calculate-fee u1000000)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
(contract-call? .flashstack-core set-fee u5)

;; --- STEP 9: Test Error Conditions ---
(contract-call? .flashstack-core flash-mint u0 .test-receiver)
(contract-call? .flashstack-core set-fee u10001)

;; --- STEP 10: Test Large Amount ---
(contract-call? .flashstack-core flash-mint u100000000 .test-receiver)

;; --- FINAL VERIFICATION ---
(contract-call? .flashstack-core get-stats)
(contract-call? .sbtc-token get-total-supply)
(contract-call? .flashstack-core is-paused)

;; =============================================================================
;; Expected Results Summary:
;; - All flash mints should return: (ok {amount: <amount>, fee: <fee>, borrower: <principal>})
;; - Total supply should always be u0 after each flash mint
;; - Stats should accumulate: total-flash-mints, total-volume, total-fees-collected
;; - Pause should block flash mints with (err u103)
;; - Invalid amounts should return (err u101)
;; - Invalid fees should return (err u104)
;; =============================================================================
