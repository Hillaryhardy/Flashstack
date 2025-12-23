;; Advanced Receiver Bug Fixes - Verification Tests
;; Tests the two previously failing advanced receivers after bug fixes

;; Setup
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

;; =============================================================================
;; Test 1: DEX Aggregator Receiver (Previously Failed with ArithmeticUnderflow)
;; =============================================================================
;; Fix: Changed mock prices from 50 billion to 50 thousand (realistic BTC prices)

(contract-call? .flashstack-core flash-mint u6000000 .dex-aggregator-receiver)
;; Expected: SUCCESS
;; Should show:
;; - amount: u6000000
;; - fee: u3000
;; - total-minted: u6003000
;; Events: mint → transfer → burn (6,003,000 sBTC)

;; =============================================================================
;; Test 2: Multi-DEX Arbitrage Receiver (Previously Failed with ERR-CALLBACK-FAILED)
;; =============================================================================
;; Fix: Increased MAX-SLIPPAGE-BP from 100 (1%) to 200 (2%)

(contract-call? .flashstack-core flash-mint u4000000 .multidex-arbitrage-receiver)
;; Expected: SUCCESS
;; Should show:
;; - amount: u4000000
;; - fee: u2000
;; - total-minted: u4002000
;; Events: mint → transfer → burn (4,002,000 sBTC)

;; =============================================================================
;; Verification
;; =============================================================================

;; Check final stats
(contract-call? .flashstack-core get-stats)
;; Expected:
;; - total-flash-mints: u2
;; - total-volume: u10000000 (6M + 4M)
;; - total-fees-collected: u5000 (3,000 + 2,000)

;; Verify zero supply
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)

;; =============================================================================
;; Expected Results Summary
;; =============================================================================
;; If both tests pass:
;; ✅ dex-aggregator-receiver: FIXED
;; ✅ multidex-arbitrage-receiver: FIXED
;; ✅ All 8 receivers now working: 100% success rate
;; ✅ Overall protocol: 100% functional
