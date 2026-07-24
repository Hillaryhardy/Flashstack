;; TEST-ONLY sBTC receiver: repays principal + fee (happy path).
;; Funded with a small sBTC buffer in the test to cover the fee.
(impl-trait .sbtc-flash-receiver-trait.sbtc-flash-receiver-trait)

(define-public (execute-sbtc-flash (amount uint) (core principal))
  (let (
    (fee-bp  (unwrap! (contract-call? .flashstack-sbtc-core get-fee-basis-points) (err u901)))
    (raw-fee (/ (* amount fee-bp) u10000))
    (fee     (if (> raw-fee u0) raw-fee u1))
  )
    (unwrap! (as-contract (contract-call? .sbtc-token transfer (+ amount fee) tx-sender core none)) (err u902))
    (ok true)
  )
)
