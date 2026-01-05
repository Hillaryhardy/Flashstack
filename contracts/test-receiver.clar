;; Simple test receiver for FlashStack
;; Just borrows, does nothing, and repays

(define-constant ERR-REPAYMENT-FAILED (err u200))
(define-constant ERR-FEE-FETCH-FAILED (err u201))

(define-public (execute-flash (amount uint) (borrower principal))
  (let (
    ;; Query the protocol for current fee rate
    (fee-bp (unwrap! (contract-call? .flashstack-core get-fee-basis-points) ERR-FEE-FETCH-FAILED))
    (fee (/ (* amount fee-bp) u10000))
    (total-owed (+ amount fee))
  )
    ;; Simply repay by transferring tokens back
    (as-contract (contract-call? .sbtc-token transfer
      total-owed
      tx-sender
      .flashstack-core
      none
    ))
  )
)
