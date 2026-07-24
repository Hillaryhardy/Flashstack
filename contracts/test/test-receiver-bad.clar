;; TEST-ONLY receiver: keeps the borrowed STX and never repays.
;; The core's reserve invariant must reject this and revert the whole transaction.
(impl-trait .stx-flash-receiver-trait.stx-flash-receiver-trait)

(define-public (execute-stx-flash (amount uint) (core principal))
  ;; deliberately no repayment
  (ok true)
)
