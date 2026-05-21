;; HK STX Real Receiver v1
;;
;; Minimal flash-loan receiver, deployed from an external developer wallet
;; against the live FlashStack mainnet (deployer SP20XD46NGAX05ZQZDKFYCCX49A3852BQABNP0VG5).
;; Borrows STX, repays principal + fee atomically, no strategy.
;;
;; Uses absolute principals for the protocol contracts because this receiver
;; lives under a different deployer than flashstack-stx-core and the
;; `.contract-name` shorthand would resolve to the wrong address.

(impl-trait 'SP3TGRVG7DKGFVRTTVGGS60S59R916FWB4DAB9STZ.stx-flash-receiver-trait.stx-flash-receiver-trait)

(define-constant ERR-REPAY (err u500))

(define-public (execute-stx-flash (amount uint) (core principal))
  (let (
    (fee-bp     (unwrap! (contract-call? 'SP20XD46NGAX05ZQZDKFYCCX49A3852BQABNP0VG5.flashstack-stx-core get-fee-basis-points) ERR-REPAY))
    (raw-fee    (/ (* amount fee-bp) u10000))
    (fee        (if (> raw-fee u0) raw-fee u1))
    (total-owed (+ amount fee))
  )
    (unwrap! (as-contract (stx-transfer? total-owed tx-sender core)) ERR-REPAY)
    (ok true)
  )
)
