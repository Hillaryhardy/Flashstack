;; TEST-ONLY receiver for flashstack-pool-v3: repays principal + fee for
;; whichever asset it's called with (happy path). Funded with a small buffer
;; of that asset in the test to cover the fee.
(impl-trait .flashstack-v3-receiver-trait.flashstack-v3-receiver-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-public (execute-flash (token <sip-010-trait>) (amount uint) (core principal))
  (let (
    (cfg     (unwrap! (contract-call? .flashstack-pool-v3 get-asset (contract-of token)) (err u901)))
    (raw-fee (/ (* amount (get fee-bp cfg)) u10000))
    (fee     (if (> raw-fee u0) raw-fee u1))
  )
    (unwrap! (as-contract (contract-call? token transfer (+ amount fee) tx-sender core none)) (err u902))
    (ok true)
  )
)
