;; TEST-ONLY sBTC receiver: keeps the borrowed sBTC and never repays.
;; The core's reserve invariant must reject this and revert the whole transaction.
(impl-trait .sbtc-flash-receiver-trait.sbtc-flash-receiver-trait)

(define-public (execute-sbtc-flash (amount uint) (core principal))
  ;; deliberately no repayment
  (ok true)
)
