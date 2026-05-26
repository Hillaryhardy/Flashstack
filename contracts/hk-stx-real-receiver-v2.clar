;; HK STX Real Receiver v2
;;
;; v2 changes vs v1:
;;   - Adds contract-caller assertion at the top of execute-stx-flash so only
;;     the live flashstack-stx-core can invoke the callback. Closes the
;;     direct-drain path that v1 inherited from the stx-test-receiver pattern.
;;
;; Behaviour vs v1:
;;   - Identical trait, identical absolute principals.
;;   - Identical fee/repayment math (dynamic fee lookup, floor-to-u1 on tiny loans).
;;   - Identical (ok true) shape on success.
;;   - On a direct invocation by anyone other than flashstack-stx-core, reverts
;;     with ERR-WRONG-CALLER instead of paying out.

(impl-trait 'SP3TGRVG7DKGFVRTTVGGS60S59R916FWB4DAB9STZ.stx-flash-receiver-trait.stx-flash-receiver-trait)

(define-constant FLASHSTACK-STX-CORE 'SP20XD46NGAX05ZQZDKFYCCX49A3852BQABNP0VG5.flashstack-stx-core)

(define-constant ERR-REPAY        (err u500))
(define-constant ERR-WRONG-CALLER (err u403))

(define-public (execute-stx-flash (amount uint) (core principal))
  (begin
    (asserts! (is-eq contract-caller FLASHSTACK-STX-CORE) ERR-WRONG-CALLER)
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
)
