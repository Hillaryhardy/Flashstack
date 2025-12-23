;; FlashStack Admin Tests - Quick Run Version
;; Copy-paste these sections one at a time

;; === SETUP ===
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
(contract-call? .flashstack-core get-admin)
(contract-call? .flashstack-core is-paused)
(contract-call? .flashstack-core get-fee-basis-points)

;; === TEST 1: PAUSE/UNPAUSE ===
;; Flash mint before pause (should work)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
(contract-call? .flashstack-core get-stats)

;; Pause the protocol
(contract-call? .flashstack-core pause)
(contract-call? .flashstack-core is-paused)

;; Try flash mint while paused (should fail with err u105)
(contract-call? .flashstack-core flash-mint u500000 .test-receiver)

;; Unpause
(contract-call? .flashstack-core unpause)
(contract-call? .flashstack-core is-paused)

;; Flash mint after unpause (should work)
(contract-call? .flashstack-core flash-mint u2000000 .test-receiver)
(contract-call? .flashstack-core get-stats)

;; === TEST 2: FEE ADJUSTMENT ===
;; Current fee (0.05%)
(contract-call? .flashstack-core get-fee-basis-points)
(contract-call? .flashstack-core calculate-fee u1000000)

;; Change to 0.1%
(contract-call? .flashstack-core set-fee u10)
(contract-call? .flashstack-core calculate-fee u1000000)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)

;; Change to 0.25%
(contract-call? .flashstack-core set-fee u25)
(contract-call? .flashstack-core calculate-fee u1000000)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)

;; Change to 1%
(contract-call? .flashstack-core set-fee u100)
(contract-call? .flashstack-core calculate-fee u1000000)
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)

;; Try invalid fee >100% (should fail)
(contract-call? .flashstack-core set-fee u10001)

;; Reset to 0.05%
(contract-call? .flashstack-core set-fee u5)
(contract-call? .flashstack-core get-fee-basis-points)

;; === TEST 3: ERROR CONDITIONS ===
;; Zero amount (should fail)
(contract-call? .flashstack-core flash-mint u0 .test-receiver)

;; === FINAL VERIFICATION ===
(contract-call? .flashstack-core get-stats)
(contract-call? .sbtc-token get-total-supply)
(contract-call? .flashstack-core is-paused)
(contract-call? .flashstack-core get-fee-basis-points)
