;; TEST-ONLY receiver for the LP pool: repays principal + fee (happy path).
;; Funded with a small STX buffer in the test so it can cover the fee.
(impl-trait .stx-flash-receiver-trait.stx-flash-receiver-trait)

(define-public (execute-stx-flash (amount uint) (core principal))
  (let (
    (fee-bp  (unwrap! (contract-call? .flashstack-stx-pool get-fee-basis-points) (err u901)))
    (raw-fee (/ (* amount fee-bp) u10000))
    (fee     (if (> raw-fee u0) raw-fee u1))
  )
    (unwrap! (as-contract (stx-transfer? (+ amount fee) tx-sender core)) (err u902))
    (ok true)
  )
)
