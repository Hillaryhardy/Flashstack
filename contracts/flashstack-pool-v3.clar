;; FlashStack Pool v3 -- Generic Multi-Asset Flash-Loan + LP Pool
;;
;; Aave-style generic core: lists any admin-approved SIP-010 token as a
;; flash-loan reserve and LP asset in ONE contract (design decision #3, LOCKED
;; 2026-07-26 in docs/02-technical/MULTI_ASSET_CORE_DESIGN.md -- no separate
;; core/pool; LP liquidity *is* the flash-loan reserve, per asset).
;;
;; Clarity cannot persist a trait reference in state, so every entry point
;; takes the token as a <sip-010-trait> parameter; per-asset state is keyed by
;; (contract-of token) (design doc section 2).
;;
;; Security model (design doc section 7):
;;   - Asset allow-list (add-asset) is LOAD-BEARING FOR SOLVENCY: only admin-
;;     vetted SIP-010 tokens are borrowable/depositable. An unlisted token --
;;     however well- or ill-behaved -- is rejected before any token call is
;;     made. This is what stops a malicious token contract (one that lies
;;     about get-balance/transfer) from ever being reachable through this pool.
;;   - Balance invariant (per asset): flash-loan measures the token balance
;;     before/after the callback and reverts unless it grew by >= fee.
;;   - Receiver whitelist: defense-in-depth during the unaudited beta
;;     (decision #1); not load-bearing for solvency.
;;   - Virtual shares/assets (F-1 fix), per asset, from day one.
;;   - Two-step admin transfer (decision #5, BC1 audit finding 2026-08-01):
;;     every currently-deployed governed FlashStack contract uses a one-step,
;;     self-gated admin transfer that permanently bricks governance if given a
;;     bad value, with no recovery. Ported verbatim from the proven fix in
;;     flashstack-sbtc-pool-v3 / flashstack-stx-pool-v3 / flashstack-sbtc-core-v2.
;;   - Withdraw is intentionally NOT gated by asset enabled/paused/listed
;;     status: LPs can always exit their position, matching the invariant
;;     already relied on for v1/v2 pool recovery (withdraw is never
;;     pause-gated in any deployed FlashStack pool).
;;
;; NOT YET DEPLOYED. Deploy order: flashstack-v3-receiver-trait FIRST (fresh,
;; under the secure wallet SPR9PQ...), then this contract.
;;
;; Clarity version: 3 for now (NOT 6). Verified 2026-08-01: `as-contract`
;; (used throughout deposit/withdraw/flash-loan) fails to resolve at
;; clarity_version=6 in the current clarinet-sdk/CLI (3.22/3.23) -- a
;; toolchain gap, reproduced with an isolated minimal probe, not a defect
;; in this contract. Bump to 6 once clarinet/SDK fix it; no other Clarity-6-
;; specific feature is used, so the flip should be a one-line change.

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait flashstack-v3-receiver-trait 'SPR9PQANV6XHSDNRAX2GNKCA5Z1KH61961KE0BYG.flashstack-v3-receiver-trait.flashstack-v3-receiver-trait)

;; =============================================
;; Error Codes (800s -- fresh namespace, unused elsewhere in the repo)
;; =============================================

(define-constant ERR-NOT-ADMIN            (err u800))
(define-constant ERR-NOT-PENDING-ADMIN    (err u801))
(define-constant ERR-ZERO-AMOUNT          (err u802))
(define-constant ERR-PAUSED               (err u803))
(define-constant ERR-ASSET-PAUSED         (err u804))
(define-constant ERR-NOT-LISTED           (err u805))
(define-constant ERR-ALREADY-LISTED       (err u806))
(define-constant ERR-EXCEEDS-LIMIT        (err u807))
(define-constant ERR-NOT-APPROVED         (err u808))
(define-constant ERR-INSUFFICIENT-RESERVE (err u809))
(define-constant ERR-REPAY-FAILED         (err u810))
(define-constant ERR-TRANSFER-FAILED      (err u811))
(define-constant ERR-INVALID-FEE          (err u812))
(define-constant ERR-INSUFFICIENT-SHARES  (err u813))
(define-constant ERR-BALANCE-READ-FAILED  (err u814))

;; =============================================
;; Constants
;; =============================================

;; Hard cap on per-asset fee: admin cannot set a predatory fee (decision #4).
(define-constant MAX-FEE-BP u100) ;; 100 bp = 1%

;; F-1 fix: virtual shares + virtual assets (OpenZeppelin ERC-4626 inflation-
;; attack mitigation), applied per asset from day one (design doc section 6).
(define-constant VIRTUAL-SHARES u1000000) ;; 1e6 phantom shares
(define-constant VIRTUAL-ASSETS u1)       ;; 1 phantom base-unit of the asset
(define-constant SHARE-PRECISION u1000000)

;; =============================================
;; State
;; =============================================

(define-data-var admin         principal tx-sender)
(define-data-var pending-admin (optional principal) none)
(define-data-var paused        bool false) ;; global circuit breaker

;; Per-asset config, keyed by the token's contract principal (contract-of token).
;; `reserve` is a CACHE of the token's live balance, refreshed at the end of
;; every deposit/withdraw/flash-loan (all of which re-measure it via the trait
;; anyway). This exists because Clarity forbids dynamic (trait-typed)
;; contract-call? inside define-read-only -- it cannot statically prove an
;; arbitrary trait implementer's function is side-effect-free, so read-only
;; oracle functions cannot take <sip-010-trait> and must read cached state
;; instead of live-querying the token. A direct donation to the contract (not
;; via deposit) will not appear in the oracle price until the next real
;; interaction refreshes the cache -- expected, not a solvency issue: the
;; balance invariant in flash-loan/withdraw still measures the live balance.
(define-map assets principal {
  enabled:      bool,
  fee-bp:       uint,
  max-loan:     uint,
  paused:       bool,
  reserve:      uint,
  total-loans:  uint,
  total-volume: uint,
  total-fees:   uint,
})

;; Per-asset LP shares and per-asset total shares.
(define-map lp-shares    { asset: principal, lp: principal } uint)
(define-map total-shares principal uint)

;; Global receiver allowlist (decision #1: beta-only defense-in-depth; not
;; load-bearing for solvency -- the asset allow-list + balance invariant are).
(define-map approved-receivers principal bool)

;; =============================================
;; Admin -- two-step transfer (mandatory, decision #5 / BC1 fix)
;; =============================================

;; Step 1 of 2: propose a new admin. Takes effect ONLY after accept-admin.
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (ok (var-set pending-admin (some new-admin)))
  )
)

;; Step 2 of 2: the proposed admin accepts. A mistyped/uncontrolled principal
;; can never call this, so a bad proposal simply never takes effect -- the
;; original admin keeps full control and can re-propose the correct address.
(define-public (accept-admin)
  (let ((pending (unwrap! (var-get pending-admin) ERR-NOT-PENDING-ADMIN)))
    (asserts! (is-eq tx-sender pending) ERR-NOT-PENDING-ADMIN)
    (var-set admin pending)
    (var-set pending-admin none)
    (print { event: "admin-transferred", new-admin: pending })
    (ok true)
  )
)

;; =============================================
;; Admin -- asset allow-list (load-bearing for solvency, section 7)
;; =============================================

(define-public (add-asset (token principal) (fee-bp uint) (max-loan uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (is-none (map-get? assets token)) ERR-ALREADY-LISTED)
    (asserts! (and (> fee-bp u0) (<= fee-bp MAX-FEE-BP)) ERR-INVALID-FEE)
    (asserts! (> max-loan u0) ERR-ZERO-AMOUNT)
    (map-set assets token {
      enabled: true, fee-bp: fee-bp, max-loan: max-loan, paused: false, reserve: u0,
      total-loans: u0, total-volume: u0, total-fees: u0,
    })
    (print { event: "asset-added", token: token, fee-bp: fee-bp, max-loan: max-loan })
    (ok true)
  )
)

(define-public (set-asset (token principal) (fee-bp uint) (max-loan uint) (asset-paused bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (and (> fee-bp u0) (<= fee-bp MAX-FEE-BP)) ERR-INVALID-FEE)
    (asserts! (> max-loan u0) ERR-ZERO-AMOUNT)
    (let ((cfg (unwrap! (map-get? assets token) ERR-NOT-LISTED)))
      (map-set assets token (merge cfg { fee-bp: fee-bp, max-loan: max-loan, paused: asset-paused }))
      (ok true)
    )
  )
)

;; Delists the asset (blocks future deposit/flash-loan). Does NOT touch
;; lp-shares/total-shares -- existing LPs can still withdraw (withdraw is not
;; gated by this map at all), and it can be re-added later with add-asset.
(define-public (remove-asset (token principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (is-some (map-get? assets token)) ERR-NOT-LISTED)
    (ok (map-delete assets token))
  )
)

;; =============================================
;; Admin -- receiver allowlist + global pause
;; =============================================

(define-public (add-approved-receiver (receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (ok (map-set approved-receivers receiver true))
  )
)

(define-public (remove-approved-receiver (receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (ok (map-delete approved-receivers receiver))
  )
)

(define-public (set-paused (val bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (ok (var-set paused val))
  )
)

;; =============================================
;; LP Deposit / Withdraw (per asset)
;; =============================================

(define-public (deposit (token <sip-010-trait>) (amount uint))
  (let (
    (asset        (contract-of token))
    (depositor    tx-sender)
    (cfg          (unwrap! (map-get? assets asset) ERR-NOT-LISTED))
    (pool-balance (unwrap! (contract-call? token get-balance (as-contract tx-sender)) ERR-BALANCE-READ-FAILED))
    (current-shares (default-to u0 (map-get? total-shares asset)))
    ;; shares = amount * (total_shares + VS) / (pool_balance + VA)
    (new-shares (/ (* amount (+ current-shares VIRTUAL-SHARES)) (+ pool-balance VIRTUAL-ASSETS)))
  )
    (asserts! (get enabled cfg) ERR-NOT-LISTED)
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    ;; Reject a deposit that would mint zero shares (e.g. a dust amount into
    ;; an already-large/valuable pool, rounding down to 0 via floor division).
    ;; Without this, the transfer would still succeed and the depositor would
    ;; silently lose their funds with no shares credited. Mirrors the
    ;; equivalent guard withdraw() already has on its output (amount-out > 0).
    (asserts! (> new-shares u0) ERR-ZERO-AMOUNT)
    ;; Effects before interaction (matches withdraw's ordering below): all
    ;; state is written from values already captured above, THEN the external
    ;; call is made. If the transfer subsequently fails, the whole transaction
    ;; -- including these map-sets -- reverts atomically, so this costs
    ;; nothing on the happy path. It closes a reentrancy-corruption window: if
    ;; a listed token's transfer ever called back into deposit/withdraw for
    ;; the same asset mid-call, updating state first means there is nothing
    ;; left for the outer call to overwrite afterward.
    (map-set lp-shares { asset: asset, lp: depositor }
      (+ (default-to u0 (map-get? lp-shares { asset: asset, lp: depositor })) new-shares))
    (map-set total-shares asset (+ current-shares new-shares))
    ;; Refresh the cached reserve: this deposit is about to land `amount`
    ;; more into the contract, on top of the balance measured above.
    (map-set assets asset (merge cfg { reserve: (+ pool-balance amount) }))
    (unwrap! (contract-call? token transfer amount depositor (as-contract tx-sender) none) ERR-TRANSFER-FAILED)
    (ok new-shares)
  )
)

(define-public (withdraw (token <sip-010-trait>) (shares uint))
  (let (
    (asset            (contract-of token))
    (withdrawer       tx-sender)
    (depositor-shares (default-to u0 (map-get? lp-shares { asset: asset, lp: withdrawer })))
    (current-shares   (default-to u0 (map-get? total-shares asset)))
    (pool-balance     (unwrap! (contract-call? token get-balance (as-contract tx-sender)) ERR-BALANCE-READ-FAILED))
    ;; assets_out = shares * (pool_balance + VA) / (total_shares + VS)
    (amount-out (/ (* shares (+ pool-balance VIRTUAL-ASSETS)) (+ current-shares VIRTUAL-SHARES)))
  )
    (asserts! (> shares u0) ERR-ZERO-AMOUNT)
    (asserts! (>= depositor-shares shares) ERR-INSUFFICIENT-SHARES)
    (asserts! (> amount-out u0) ERR-ZERO-AMOUNT)
    (map-set lp-shares { asset: asset, lp: withdrawer } (- depositor-shares shares))
    (map-set total-shares asset (- current-shares shares))
    (unwrap! (as-contract (contract-call? token transfer amount-out tx-sender withdrawer none)) ERR-TRANSFER-FAILED)
    ;; Refresh the cached reserve if the asset is still listed (it may have
    ;; been removed via remove-asset -- withdraw must still work either way,
    ;; so this is a no-op rather than an error in that case).
    (match (map-get? assets asset)
      cfg (map-set assets asset (merge cfg { reserve: (- pool-balance amount-out) }))
      true
    )
    (ok amount-out)
  )
)

;; =============================================
;; Flash Loan
;; =============================================

(define-public (flash-loan (token <sip-010-trait>) (amount uint) (receiver <flashstack-v3-receiver-trait>))
  (let (
    (asset              (contract-of token))
    (cfg                (unwrap! (map-get? assets asset) ERR-NOT-LISTED))
    (receiver-principal (contract-of receiver))
    (raw-fee   (/ (* amount (get fee-bp cfg)) u10000))
    (fee       (if (> raw-fee u0) raw-fee u1))
    (reserve-before (unwrap! (contract-call? token get-balance (as-contract tx-sender)) ERR-BALANCE-READ-FAILED))
  )
    (asserts! (not (var-get paused))                                          ERR-PAUSED)
    (asserts! (get enabled cfg)                                               ERR-NOT-LISTED)
    (asserts! (not (get paused cfg))                                          ERR-ASSET-PAUSED)
    (asserts! (> amount u0)                                                   ERR-ZERO-AMOUNT)
    (asserts! (<= amount (get max-loan cfg))                                  ERR-EXCEEDS-LIMIT)
    (asserts! (default-to false (map-get? approved-receivers receiver-principal)) ERR-NOT-APPROVED)
    (asserts! (>= reserve-before amount)                                      ERR-INSUFFICIENT-RESERVE)

    ;; Send the asset to the receiver.
    (unwrap! (as-contract (contract-call? token transfer amount tx-sender receiver-principal none)) ERR-TRANSFER-FAILED)

    ;; Invoke the receiver callback. It must repay amount + fee before returning.
    (try! (contract-call? receiver execute-flash token amount (as-contract tx-sender)))

    ;; INVARIANT: this asset's reserve must have grown by >= fee. Measured, not
    ;; trusted -- identical safety to the single-asset cores, applied per token.
    (let ((reserve-after (unwrap! (contract-call? token get-balance (as-contract tx-sender)) ERR-BALANCE-READ-FAILED)))
      (asserts! (>= reserve-after (+ reserve-before fee)) ERR-REPAY-FAILED)
      (map-set assets asset (merge cfg {
        reserve:      reserve-after,
        total-loans:  (+ (get total-loans cfg) u1),
        total-volume: (+ (get total-volume cfg) amount),
        total-fees:   (+ (get total-fees cfg) (- reserve-after reserve-before)),
      }))
      (print { event: "flash-loan", asset: asset, receiver: receiver-principal, amount: amount, fee: fee })
      (ok true)
    )
  )
)

;; =============================================
;; Read-only
;; =============================================

(define-read-only (get-admin) (ok (var-get admin)))
(define-read-only (get-pending-admin) (ok (var-get pending-admin)))
(define-read-only (get-paused) (ok (var-get paused)))

(define-read-only (get-asset (token principal))
  (map-get? assets token)
)

(define-read-only (is-listed (token principal))
  (is-some (map-get? assets token))
)

;; Cached reserve (see the `assets` map comment for why this isn't a live
;; contract-call: Clarity forbids dynamic trait dispatch in define-read-only).
(define-read-only (get-reserve (token principal))
  (ok (get reserve (default-to
    { enabled: false, fee-bp: u0, max-loan: u0, paused: false, reserve: u0,
      total-loans: u0, total-volume: u0, total-fees: u0 }
    (map-get? assets token))))
)

(define-read-only (is-approved-receiver (receiver principal))
  (default-to false (map-get? approved-receivers receiver))
)

(define-read-only (get-shares (token principal) (lp principal))
  (default-to u0 (map-get? lp-shares { asset: token, lp: lp }))
)

(define-read-only (get-total-shares (token principal))
  (default-to u0 (map-get? total-shares token))
)

;; Current value of one pool share for `token`, scaled by SHARE-PRECISION.
;; Well-defined at zero shares (F-2 fix: virtual-offset formula, no special
;; case). Reads the cached reserve (see `assets` map comment) rather than a
;; live contract-call -- dynamic trait dispatch is not allowed in read-only fns.
(define-read-only (get-share-price (token principal))
  (let (
    (pool-balance   (default-to u0 (get reserve (map-get? assets token))))
    (current-shares (default-to u0 (map-get? total-shares token)))
  )
    (ok (/ (* (+ pool-balance VIRTUAL-ASSETS) SHARE-PRECISION) (+ current-shares VIRTUAL-SHARES)))
  )
)

;; Current value of an LP's position in `token`'s base units (cached reserve).
(define-read-only (get-lp-value (token principal) (lp principal))
  (let (
    (shares         (default-to u0 (map-get? lp-shares { asset: token, lp: lp })))
    (pool-balance   (default-to u0 (get reserve (map-get? assets token))))
    (current-shares (default-to u0 (map-get? total-shares token)))
  )
    (if (is-eq shares u0)
      (ok u0)
      (ok (/ (* shares (+ pool-balance VIRTUAL-ASSETS)) (+ current-shares VIRTUAL-SHARES)))
    )
  )
)

(define-read-only (calculate-fee (token principal) (amount uint))
  (let ((cfg (unwrap! (map-get? assets token) ERR-NOT-LISTED)))
    (let ((raw-fee (/ (* amount (get fee-bp cfg)) u10000)))
      (ok (if (> raw-fee u0) raw-fee u1))
    )
  )
)
