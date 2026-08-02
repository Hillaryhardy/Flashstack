;; TEST-ONLY receiver for flashstack-pool-v3: never repays. Proves the
;; balance-invariant check reverts the entire flash-loan transaction.
(impl-trait .flashstack-v3-receiver-trait.flashstack-v3-receiver-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-public (execute-flash (token <sip-010-trait>) (amount uint) (core principal))
  (ok true) ;; deliberately does not repay
)
