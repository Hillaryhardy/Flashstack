;; Local simnet mirror of the canonical SIP-010 trait
;; (SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard).
;; Structurally identical -- Clarity trait conformance is structural, so this
;; satisfies <sip-010-trait> in simnet without needing the mainnet contract
;; mirrored via Clarinet requirements. Trait-only, no state -- safe to share
;; between production references (which use the real mainnet principal) and
;; test copies (which dot-sugar to this file).

(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)
