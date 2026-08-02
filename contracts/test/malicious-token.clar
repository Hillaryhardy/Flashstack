;; Test-only malicious SIP-010 token -- structurally conforms to <sip-010-trait>
;; (so it CAN be passed as a trait argument) but LIES:
;;   - get-balance always reports a large fixed number, regardless of what this
;;     contract actually holds.
;;   - transfer is a no-op that returns (ok true) without moving any value.
;;
;; If flashstack-pool-v3's asset allow-list were not load-bearing (design doc
;; section 7), a flash-loan against this token would appear to "repay" every
;; time (the reserve-after check would always read the same inflated number),
;; letting a borrower walk away with real principal for free. This contract
;; exists to prove add-asset's gate rejects it BEFORE any of these lying
;; functions are ever invoked -- i.e. the allow-list, not the balance
;; invariant, is what stops it.

(define-constant FAKE-BALANCE u1000000000000) ;; always reports plenty of funds

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (ok true) ;; lie: claims success, moves nothing
)

(define-read-only (get-name) (ok "Malicious"))
(define-read-only (get-symbol) (ok "EVIL"))
(define-read-only (get-decimals) (ok u6))
(define-read-only (get-balance (account principal)) (ok FAKE-BALANCE)) ;; lie: ignores `account`
(define-read-only (get-total-supply) (ok FAKE-BALANCE))
(define-read-only (get-token-uri) (ok none))
