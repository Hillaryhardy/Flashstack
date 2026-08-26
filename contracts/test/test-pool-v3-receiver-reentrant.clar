;; TEST-ONLY receiver reproducing Hillary Kibet's pool-v3 review finding F1
;; (2026-08-25): during the flash-loan callback, reenters deposit() on the pool
;; for the SAME asset before repaying. The reentrant deposit's token transfer
;; inflates the balance delta flash-loan measures, so total-fees/total-volume
;; get credited with the deposit amount as if it were loan repayment/fee.
;;
;; Unlike the earlier reentrant-token.clar attempt (removed, section 12 of the
;; design doc), this does NOT trigger Clarinet's CircularReference limitation:
;; a receiver forwarding the <sip-010-trait> argument it already received to
;; another contract-call is normal dynamic dispatch, not a self-reference.

(impl-trait .flashstack-v3-receiver-trait.flashstack-v3-receiver-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-data-var reentrant-deposit-amount uint u0)

(define-public (arm (amount uint))
  (ok (var-set reentrant-deposit-amount amount))
)

(define-public (execute-flash (token <sip-010-trait>) (amount uint) (core principal))
  (let (
    (cfg     (unwrap! (contract-call? .flashstack-pool-v3 get-asset (contract-of token)) (err u901)))
    (raw-fee (/ (* amount (get fee-bp cfg)) u10000))
    (fee     (if (> raw-fee u0) raw-fee u1))
    (reenter (var-get reentrant-deposit-amount))
  )
    ;; Reenter BEFORE repaying: deposit reenter units of the SAME asset. The
    ;; depositor is attributed to tx-sender (the original external caller, who
    ;; must hold and fund this out of their own balance -- tx-sender does not
    ;; change across nested contract-calls in Clarity). Uses try! (not
    ;; unwrap-panic) so a blocked reentry (ERR-REENTRANT, post-fix) propagates
    ;; as a normal (err ...) response instead of a raw runtime panic.
    (if (> reenter u0)
      (try! (contract-call? .flashstack-pool-v3 deposit token reenter))
      u0
    )
    (unwrap! (as-contract (contract-call? token transfer (+ amount fee) tx-sender core none)) (err u902))
    (ok true)
  )
)
