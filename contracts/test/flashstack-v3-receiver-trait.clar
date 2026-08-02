;; Local simnet copy of contracts/flashstack-v3-receiver-trait.clar.
;; Trait-only, no state -- byte-identical except for the sip-010-trait use-trait
;; target, which points at the local mirror instead of the mainnet principal.

(use-trait sip-010-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-trait flashstack-v3-receiver-trait
  (
    (execute-flash (<sip-010-trait> uint principal) (response bool uint))
  )
)
