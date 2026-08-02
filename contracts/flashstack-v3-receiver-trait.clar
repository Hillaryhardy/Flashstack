;; FlashStack v3 Generic Flash Receiver Trait
;;
;; Interface every flashstack-pool-v3 flash-loan receiver must implement.
;; Unlike the legacy per-asset traits (stx-flash-receiver-trait,
;; sbtc-flash-receiver-trait), the token is passed as a trait argument so a
;; single receiver contract can, in principle, service any listed SIP-010
;; asset -- pool-v3 is generic across assets (design doc MULTI_ASSET_CORE_DESIGN.md
;; section 3).
;;
;; Deployed FRESH under the secure wallet (SPR9PQ...) -- see design doc section 3
;; ("provenance-clean deploy"): no reference to the SP20XD46/SP3TGRVG namespaces.

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-trait flashstack-v3-receiver-trait
  (
    ;; Called by flashstack-pool-v3 after transferring `amount` of `token` to the
    ;; receiver. The receiver must repay amount + fee (in `token`) to `core`
    ;; before this returns, or the whole flash-loan transaction reverts.
    (execute-flash (<sip-010-trait> uint principal) (response bool uint))
  )
)
