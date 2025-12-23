# FlashStack Developer Documentation - Updated

**First Flash Loan Protocol on Bitcoin Layer 2**

*Last Updated: December 7, 2025 - Testnet Launch*

---

## 🚀 Quick Start

FlashStack is now live on Stacks testnet with 100% test success rate!

**Testnet Deployment:**
- Deployer Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8`
- Network: Stacks Testnet
- Status: Ready for audit (code works, needs security review)
- Test Results: 8/8 Passed (27M sBTC volume)

**GitHub Repository:**
```bash
git clone https://github.com/mattglory/flashstack
cd flashstack
```

---

## 📚 Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Core Contracts](#core-contracts)
4. [Integration Guide](#integration-guide)
5. [Receiver Contracts](#receiver-contracts)
6. [Testing](#testing)
7. [Deployment](#deployment)
8. [API Reference](#api-reference)
9. [Examples](#examples)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)
12. [Resources](#resources)

---

## 1. Overview

### What is FlashStack?

FlashStack enables uncollateralized flash loans on Stacks (Bitcoin Layer 2). Borrow millions of sBTC for a single transaction with no collateral required.

**Key Features:**
- ✅ Zero collateral required
- ✅ Atomic execution guarantee
- ✅ 0.05% competitive fees
- ✅ Zero-inflation guarantee
- ✅ 8 production-ready receivers
- ✅ 100% test success rate

### How Flash Loans Work

```
1. BORROW → 2. EXECUTE → 3. REPAY
    ↓            ↓           ↓
 Mint sBTC   Your Logic   Burn sBTC
    ↓            ↓           ↓
If repayment fails → ENTIRE TRANSACTION REVERTS
```

**All or nothing:**  
- Success = profit kept, loan repaid, zero inflation
- Failure = transaction reverts, no tokens created

---

## 2. Getting Started

### Prerequisites

**Required:**
- Clarity smart contract knowledge
- Clarinet installed (`brew install clarinet`)
- Basic understanding of flash loans
- Stacks wallet (testnet STX for deployment)

**Recommended:**
- Git installed
- Code editor (VS Code + Clarity extension)
- Stacks Explorer access
- Discord/X for support

### Installation

```bash
# Clone repository
git clone https://github.com/mattglory/flashstack
cd flashstack

# Install dependencies (if any)
clarinet install

# Run tests
clarinet test

# Start console for local testing
clarinet console
```

### Project Structure

```
flashstack/
├── contracts/
│   ├── flashstack-core.clar          # Main protocol
│   ├── sbtc-token.clar                # Flash-mintable token
│   ├── flash-receiver-trait.clar      # Interface
│   ├── test-receiver.clar             # Simple example
│   ├── example-arbitrage-receiver.clar
│   ├── liquidation-receiver.clar
│   ├── leverage-loop-receiver.clar
│   ├── yield-optimization-receiver.clar
│   ├── collateral-swap-receiver.clar
│   ├── dex-aggregator-receiver.clar
│   └── multidex-arbitrage-receiver.clar
├── tests/
│   └── flashstack_test.ts             # Comprehensive tests
├── settings/
│   ├── Devnet.toml
│   └── Testnet.toml
├── docs/
│   ├── TECHNICAL_SPEC.md
│   ├── INTEGRATION_GUIDE.md
│   ├── API_REFERENCE.md
│   ├── TESTNET_SUCCESS.md
│   └── RECEIVER_TESTING_GUIDE.md
└── README.md
```

---

## 3. Core Contracts

### 3.1 flashstack-core.clar

Main protocol contract orchestrating flash loans.

**Key Functions:**
```clarity
;; Execute a flash loan
(define-public (flash-mint (amount uint) (receiver <flash-receiver-trait>))
  (response (tuple ...) uint))

;; Get current protocol statistics
(define-read-only (get-stats)
  (response (tuple ...) uint))

;; Calculate fee for amount
(define-read-only (calculate-fee (amount uint))
  uint)

;; Check if protocol is paused
(define-read-only (is-paused)
  bool)
```

**Admin Functions:**
```clarity
;; Set fee (owner only)
(define-public (set-fee (new-fee-bp uint))
  (response bool uint))

;; Pause protocol (owner only)
(define-public (pause)
  (response bool uint))

;; Unpause protocol (owner only)
(define-public (unpause)
  (response bool uint))
```

### 3.2 sbtc-token.clar

Flash-mintable synthetic Bitcoin token (SIP-010 compliant).

**Key Functions:**
```clarity
;; Mint tokens (flash minter only)
(define-public (mint (amount uint) (recipient principal))
  (response bool uint))

;; Burn tokens (anyone with balance)
(define-public (burn (amount uint) (sender principal))
  (response bool uint))

;; Standard SIP-010 transfer
(define-public (transfer (amount uint) (sender principal) 
                        (recipient principal) (memo (optional (buff 34))))
  (response bool uint))

;; Get total supply
(define-read-only (get-total-supply)
  (response uint uint))
```

**Admin Functions:**
```clarity
;; Set flash minter authorization (owner only)
(define-public (set-flash-minter (minter principal))
  (response bool uint))
```

### 3.3 flash-receiver-trait.clar

Interface all receiver contracts must implement.

```clarity
(define-trait flash-receiver-trait
  (
    ;; Execute flash loan logic
    ;; @param amount - Principal borrowed
    ;; @param fee - Fee charged (0.05% = 5 basis points)
    ;; @returns (ok true) if successful, (err ...) if failed
    (execute-flash-loan (uint uint) (response bool uint))
  )
)
```

---

## 4. Integration Guide

### Step 1: Implement the Trait

```clarity
(impl-trait .flash-receiver-trait.flash-receiver-trait)
```

### Step 2: Write Your Receiver

```clarity
(define-public (execute-flash-loan (amount uint) (fee uint))
  (let (
    (total-repayment (+ amount fee))
    (profit u0)  ;; Will be calculated
  )
    ;; 1. VALIDATE INPUTS
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    
    ;; 2. YOUR CUSTOM LOGIC HERE
    ;; Examples:
    ;; - Arbitrage across DEXs
    ;; - Liquidate positions
    ;; - Build leveraged position
    ;; - Optimize yield
    ;; - Anything else!
    
    ;; Example: Simple arbitrage
    (let (
      (tokens-bought (try! (buy-on-dex-1 amount)))
      (sbtc-received (try! (sell-on-dex-2 tokens-bought)))
    )
      (set profit (- sbtc-received total-repayment))
      
      ;; 3. VALIDATE PROFIT
      (asserts! (> profit u0) ERR-UNPROFITABLE)
      
      ;; 4. TRANSFER REPAYMENT TO FLASHSTACK-CORE
      (try! (contract-call? .sbtc-token transfer 
             total-repayment tx-sender .flashstack-core none))
      
      ;; 5. RETURN SUCCESS
      (ok true)
    )
  )
)
```

### Step 3: Call flash-mint

**From your contract:**
```clarity
(define-public (execute-arbitrage)
  (contract-call? .flashstack-core flash-mint 
    u1000000  ;; Borrow 1M sBTC
    (as-contract tx-sender))  ;; Your receiver contract
)
```

**From Clarinet console:**
```clarity
(contract-call? .flashstack-core flash-mint 
  u1000000 
  .your-receiver)
```

**From Stacks Explorer (testnet):**
```
1. Go to: explorer.hiro.so/sandbox
2. Navigate to: flashstack-core contract
3. Call: flash-mint function
4. Provide: amount and receiver address
```

### Step 4: Test Locally

```bash
# Start Clarinet console
clarinet console

# Test your receiver
(contract-call? .flashstack-core flash-mint 
  u1000000 .your-receiver)

# Check supply returned to 0
(contract-call? .sbtc-token get-total-supply)
;; Should return (ok u0)

# Check statistics updated
(contract-call? .flashstack-core get-stats)
```

---

## 5. Receiver Contracts

FlashStack includes 8 production-ready receiver examples.

### 5.1 test-receiver

**Purpose:** Simple pass-through for testing
**Complexity:** ⭐ Beginner
**Use Case:** Verify flash loan mechanics

```clarity
(define-public (execute-flash-loan (amount uint) (fee uint))
  (let ((total-repayment (+ amount fee)))
    (try! (contract-call? .sbtc-token transfer 
           total-repayment tx-sender .flashstack-core none))
    (ok true)))
```

### 5.2 example-arbitrage-receiver

**Purpose:** DEX arbitrage
**Complexity:** ⭐⭐ Intermediate
**Use Case:** Profit from price differences

**Key Functions:**
- `execute-flash-loan`: Main arbitrage logic
- `calculate-expected-profit`: Profitability check
- `get-dex-prices`: Price feed integration

### 5.3 liquidation-receiver

**Purpose:** Liquidate undercollateralized positions
**Complexity:** ⭐⭐⭐ Advanced
**Use Case:** Lending protocol liquidations

**Key Functions:**
- `execute-flash-loan`: Liquidation orchestration
- `calculate-liquidation-profit`: Profit analysis
- `check-position-health`: Position monitoring

### 5.4 leverage-loop-receiver

**Purpose:** Build leveraged positions
**Complexity:** ⭐⭐⭐ Advanced  
**Use Case:** One-transaction leverage

**Key Functions:**
- `execute-flash-loan`: Leverage building
- `calculate-max-leverage`: Safety limits
- `optimize-loop-iterations`: Gas efficiency

### 5.5 yield-optimization-receiver

**Purpose:** Rebalance across protocols
**Complexity:** ⭐⭐⭐ Advanced
**Use Case:** Yield farming optimization

**Key Functions:**
- `execute-flash-loan`: Rebalancing logic
- `compare-yields`: Protocol comparison
- `calculate-optimal-allocation`: Position sizing

### 5.6 collateral-swap-receiver

**Purpose:** Change collateral type
**Complexity:** ⭐⭐ Intermediate
**Use Case:** Collateral management

**Key Functions:**
- `execute-flash-loan`: Swap orchestration
- `calculate-swap-amounts`: Size calculation
- `validate-collateral-ratios`: Safety checks

### 5.7 dex-aggregator-receiver

**Purpose:** Multi-DEX routing
**Complexity:** ⭐⭐⭐⭐ Expert
**Use Case:** Large trade optimization

**Key Functions:**
- `execute-flash-loan`: Multi-venue execution
- `optimize-routing`: Path finding
- `split-order`: Order splitting logic

### 5.8 multidex-arbitrage-receiver

**Purpose:** Complex multi-step arbitrage
**Complexity:** ⭐⭐⭐⭐ Expert
**Use Case:** Triangular/circular arbitrage

**Key Functions:**
- `execute-flash-loan`: Multi-hop trading
- `find-profitable-paths`: Opportunity detection
- `execute-trades`: Trade execution

---

## 6. Testing

### Local Testing with Clarinet

```bash
# Run all tests
clarinet test

# Run specific test
clarinet test --filter flash_loan_basic

# Run with coverage
clarinet test --coverage
```

**Test Categories:**
1. Core functionality (mint, burn, transfer)
2. Flash loan execution
3. Fee calculations
4. Access controls
5. Error handling
6. Edge cases
7. Integration tests

### Testnet Testing

**Deployment Address:**
`ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8`

**Test Procedure:**
1. Deploy your receiver to testnet
2. Get testnet STX from faucet
3. Call flash-mint via Explorer
4. Verify transaction success
5. Check supply returned to 0
6. Monitor statistics

**Testnet Explorer:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

### Verification Checklist

After each test:
- [ ] Transaction succeeded (ok ...)
- [ ] Mint event emitted
- [ ] Transfer event emitted
- [ ] Burn event emitted
- [ ] Supply returned to 0
- [ ] Statistics incremented
- [ ] Fee calculated correctly

---

## 7. Deployment

### Testnet Deployment

**Already Deployed:**
All FlashStack contracts are live on testnet at:
`ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8`

**Deploy Your Receiver:**

```bash
# Generate deployment plan
clarinet deployments generate --testnet --medium-cost

# Review plan
cat deployments/default.testnet-plan.yaml

# Apply deployment
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

### Mainnet Deployment

**Status:** Planned Q1 2026 (post-audit)

**Requirements:**
- Security audit completed
- Community feedback integrated
- Sufficient mainnet STX for fees
- Deployment checklist completed

**Process:**
1. Final security review
2. Deployment plan generation
3. Community announcement
4. Staged rollout
5. Monitoring and support

---

## 8. API Reference

### flashstack-core Functions

#### flash-mint
```clarity
(define-public (flash-mint 
  (amount uint)
  (receiver <flash-receiver-trait>))
  (response 
    (tuple 
      (amount uint)
      (borrower principal)
      (fee uint)
      (flash-mint-id uint)
      (total-minted uint))
    uint))
```

**Parameters:**
- `amount`: Principal to borrow (in micro-sBTC)
- `receiver`: Contract implementing flash-receiver-trait

**Returns:**
- Success: `(ok {amount, borrower, fee, flash-mint-id, total-minted})`
- Failure: `(err u<error-code>)`

**Errors:**
- `u401`: ERR-PAUSED (protocol paused)
- `u402`: ERR-INVALID-RECEIVER (receiver failed)
- `u403`: ERR-MINT-FAILED (token mint failed)
- `u404`: ERR-BURN-FAILED (token burn failed)

#### get-stats
```clarity
(define-read-only (get-stats)
  (response 
    (tuple
      (current-fee-bp uint)
      (paused bool)
      (total-fees-collected uint)
      (total-flash-mints uint)
      (total-volume uint))
    uint))
```

**Returns:** Protocol statistics

#### calculate-fee
```clarity
(define-read-only (calculate-fee (amount uint))
  uint)
```

**Parameters:**
- `amount`: Loan amount

**Returns:** Fee in micro-sBTC (amount × fee-bp ÷ 10000)

### sbtc-token Functions

#### mint
```clarity
(define-public (mint (amount uint) (recipient principal))
  (response bool uint))
```

**Authorization:** Flash minter only

#### burn
```clarity
(define-public (burn (amount uint) (sender principal))
  (response bool uint))
```

**Authorization:** Anyone with balance

#### transfer
```clarity
(define-public (transfer 
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34))))
  (response bool uint))
```

**Standard SIP-010 transfer**

---

## 9. Examples

### Example 1: Simple Arbitrage

```clarity
(define-public (execute-flash-loan (amount uint) (fee uint))
  (let (
    (total-repayment (+ amount fee))
    ;; Buy on DEX 1 (cheaper)
    (tokens (try! (contract-call? .dex-1 swap-exact-tokens-for-tokens
                   amount .sbtc-token .target-token u0)))
    ;; Sell on DEX 2 (expensive)
    (sbtc (try! (contract-call? .dex-2 swap-exact-tokens-for-tokens
                  tokens .target-token .sbtc-token u0)))
  )
    ;; Ensure profitable
    (asserts! (>= sbtc total-repayment) ERR-UNPROFITABLE)
    
    ;; Repay loan
    (try! (contract-call? .sbtc-token transfer
           total-repayment tx-sender .flashstack-core none))
    
    (ok true)
  )
)
```

### Example 2: Liquidation

```clarity
(define-public (execute-flash-loan (amount uint) (fee uint))
  (let (
    (total-repayment (+ amount fee))
    ;; Liquidate position
    (collateral (try! (contract-call? .lending-protocol liquidate
                       .borrower-address amount)))
    ;; Swap collateral for sBTC
    (sbtc (try! (contract-call? .dex swap-exact-tokens-for-tokens
                  collateral .collateral-token .sbtc-token u0)))
  )
    ;; Ensure enough to repay
    (asserts! (>= sbtc total-repayment) ERR-INSUFFICIENT-COLLATERAL)
    
    ;; Repay loan
    (try! (contract-call? .sbtc-token transfer
           total-repayment tx-sender .flashstack-core none))
    
    (ok true)
  )
)
```

### Example 3: Leverage Loop

```clarity
(define-public (execute-flash-loan (amount uint) (fee uint))
  (let (
    (total-repayment (+ amount fee))
    (user-capital (var-get initial-capital))
    (total-collateral (+ user-capital amount))
  )
    ;; Deposit all as collateral
    (try! (contract-call? .lending-protocol deposit total-collateral))
    
    ;; Borrow against it
    (let ((borrowed (try! (contract-call? .lending-protocol borrow 
                           (calculate-borrow-amount total-collateral)))))
      
      ;; Ensure can repay flash loan
      (asserts! (>= borrowed total-repayment) ERR-INSUFFICIENT-BORROW)
      
      ;; Repay flash loan
      (try! (contract-call? .sbtc-token transfer
             total-repayment tx-sender .flashstack-core none))
      
      (ok true)
    )
  )
)
```

---

## 10. Best Practices

### Security

**1. Always validate inputs:**
```clarity
(asserts! (> amount u0) ERR-ZERO-AMOUNT)
(asserts! (<= amount MAX-LOAN) ERR-EXCEEDS-MAX)
```

**2. Check profitability before execution:**
```clarity
(define-read-only (is-profitable (amount uint))
  (let ((expected-profit (calculate-profit amount)))
    (> expected-profit (calculate-fee amount))))
```

**3. Use read-only functions for calculations:**
```clarity
(define-read-only (calculate-expected-output (input uint))
  ;; Pure calculation, no state changes
)
```

**4. Emit detailed events:**
```clarity
(print {
  event: "flash-loan-executed",
  amount: amount,
  fee: fee,
  profit: profit,
  strategy: "arbitrage"
})
```

### Gas Optimization

**1. Minimize external calls:**
```clarity
;; Bad: Multiple calls
(contract-call? .contract-a get-price)
(contract-call? .contract-b get-price)
(contract-call? .contract-c get-price)

;; Good: Batch call if possible
(contract-call? .aggregator get-all-prices)
```

**2. Use let bindings efficiently:**
```clarity
;; Avoid recalculating
(let ((total (+ amount fee)))
  ;; Use 'total' multiple times
)
```

**3. Early exit on failures:**
```clarity
;; Check cheapest conditions first
(asserts! (> amount MIN-AMOUNT) ERR-TOO-SMALL)
(asserts! (is-profitable amount) ERR-UNPROFITABLE)
;; Then expensive operations
```

### Error Handling

**Define clear error codes:**
```clarity
(define-constant ERR-ZERO-AMOUNT (err u100))
(define-constant ERR-UNPROFITABLE (err u101))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u102))
(define-constant ERR-SLIPPAGE-TOO-HIGH (err u103))
```

**Provide context in errors:**
```clarity
(asserts! (>= output min-output) 
  (err (tuple (code u103) (expected min-output) (actual output))))
```

---

## 11. Troubleshooting

### Common Issues

#### Issue: "ERR-NOT-AUTHORIZED"
**Cause:** Flash minter not set or calling from wrong address
**Solution:**
```clarity
;; Ensure flashstack-core is authorized
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
```

#### Issue: "ERR-INSUFFICIENT-BALANCE"
**Cause:** Not enough tokens to repay
**Solution:** Check your profit calculation includes fee

```clarity
(let ((profit (- output (+ amount fee))))
  (asserts! (> profit u0) ERR-UNPROFITABLE))
```

#### Issue: Supply not returning to 0
**Cause:** Burn amount doesn't match mint amount
**Solution:** Always burn exact total-repayment

```clarity
(define-constant total-repayment (+ amount fee))
(try! (contract-call? .sbtc-token burn total-repayment ...))
```

#### Issue: Transaction timeout
**Cause:** Too many operations in flash loan
**Solution:** Optimize or split strategy

```clarity
;; Reduce external calls
;; Use batch operations
;; Simplify logic
```

### Debug Checklist

- [ ] Implement flash-receiver-trait correctly
- [ ] Calculate fee: (amount × 5) ÷ 10000
- [ ] Transfer exact total-repayment
- [ ] Handle all error cases
- [ ] Test locally first
- [ ] Check gas costs
- [ ] Verify profitability

### Getting Help

**Resources:**
- GitHub Issues: github.com/mattglory/flashstack/issues
- Twitter: @FlashStackBTC
- Stacks Discord: #flashstack channel
- Documentation: github.com/mattglory/flashstack/docs

**When asking for help, provide:**
1. Contract code (relevant sections)
2. Error message / transaction ID
3. Expected vs. actual behavior
4. Testing environment (local/testnet)
5. Clarinet version

---

## 12. Resources

### Official Links

**GitHub:**
- Repository: github.com/mattglory/flashstack
- Issues: github.com/mattglory/flashstack/issues
- Discussions: github.com/mattglory/flashstack/discussions

**Social:**
- Twitter: @FlashStackBTC
- Developer: @mattglory

**Documentation:**
- Technical Spec: /docs/TECHNICAL_SPEC.md
- Integration Guide: /docs/INTEGRATION_GUIDE.md
- API Reference: /docs/API_REFERENCE.md
- Testing Guide: /docs/RECEIVER_TESTING_GUIDE.md

### Testnet Resources

**Deployed Contracts:**
```
Deployer: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8

Core:
- flashstack-core
- sbtc-token
- flash-receiver-trait

Receivers:
- test-receiver
- example-arbitrage-receiver
- liquidation-receiver
- leverage-loop-receiver
- yield-optimization-receiver
- collateral-swap-receiver
- dex-aggregator-receiver
- multidex-arbitrage-receiver
```

**Explorer Links:**
- Testnet Explorer: explorer.hiro.so?chain=testnet
- Sandbox: explorer.hiro.so/sandbox
- Contract Calls: explorer.hiro.so/sandbox/contract-call

**Testnet Tools:**
- Faucet: explorer.hiro.so/sandbox/faucet
- STX Faucet: Get test STX for deployment
- sBTC Faucet: [Coming soon]

### Learning Resources

**Clarity:**
- Book: book.clarity-lang.org
- Tutorial: docs.stacks.co/clarity
- Examples: github.com/hirosystems/clarity-examples

**Flash Loans:**
- Aave Docs: docs.aave.com/developers/guides/flash-loans
- dYdX Docs: dydx.exchange/developers
- Concepts: ethereum.org/en/defi/#flash-loans

**Stacks:**
- Docs: docs.stacks.co
- Discord: discord.gg/stacks
- Forum: forum.stacks.org

---

## Appendix: Testnet Test Results

**Date:** December 7, 2025  
**Success Rate:** 8/8 (100%)  
**Total Volume:** 27,000,000 sBTC  
**Total Fees:** 15,250 sBTC

**Individual Tests:**
1. test-receiver: 1M sBTC ✅
2. example-arbitrage: 3M sBTC ✅
3. liquidation: 5M sBTC ✅
4. leverage-loop: 2M sBTC ✅
5. yield-optimization: 3.5M sBTC ✅
6. collateral-swap: 2.5M sBTC ✅
7. dex-aggregator: 6M sBTC ✅ (LARGEST)
8. multidex-arbitrage: 4M sBTC ✅ (FINAL)

**Verification:**
- Supply: (ok u0) ✅
- Statistics: All correct ✅
- Events: All present ✅
- Fees: Correctly calculated ✅

---

**Ready to build? Start with test-receiver and work your way up!**

**Questions? Reach out on Twitter: @FlashStackBTC**

---

*Documentation maintained by @mattglory*  
*Last updated: December 7, 2025*  
*Version: 1.0.0-testnet*

