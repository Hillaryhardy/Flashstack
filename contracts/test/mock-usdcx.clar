;; Test-only second SIP-010 asset (stand-in for USDCx) -- freely mintable, no
;; access control on mint. Exists purely to prove flashstack-pool-v3 correctly
;; isolates per-asset state between two DIFFERENT listed tokens (no cross-asset
;; leakage in lp-shares/total-shares/assets, all keyed by contract-of token).

(define-fungible-token mock-usdcx)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1))
    (try! (ft-transfer? mock-usdcx amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (ft-mint? mock-usdcx amount recipient)
)

(define-read-only (get-name) (ok "Mock USDCx"))
(define-read-only (get-symbol) (ok "mUSDCx"))
(define-read-only (get-decimals) (ok u6))
(define-read-only (get-balance (account principal)) (ok (ft-get-balance mock-usdcx account)))
(define-read-only (get-total-supply) (ok (ft-get-supply mock-usdcx)))
(define-read-only (get-token-uri) (ok none))
