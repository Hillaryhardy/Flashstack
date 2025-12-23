# FlashStack Receiver Examples Guide

**Version**: 1.0
**Last Updated**: December 6, 2025

---

## Overview

This guide covers the **5 comprehensive receiver contract examples** included with FlashStack. Each demonstrates a real-world DeFi use case with complete, working code.

---

## 📦 Available Receiver Examples

### 1. Liquidation Receiver
**File**: `contracts/liquidation-receiver.clar`
**Use Case**: Liquidate undercollateralized positions for profit
**Complexity**: ⭐⭐⭐ Intermediate

### 2. Collateral Swap Receiver  
**File**: `contracts/collateral-swap-receiver.clar`
**Use Case**: Swap collateral types without closing positions
**Complexity**: ⭐⭐⭐ Intermediate

### 3. Multi-DEX Arbitrage Receiver
**File**: `contracts/multidex-arbitrage-receiver.clar`
**Use Case**: Capture price differences across multiple DEXs
**Complexity**: ⭐⭐⭐⭐ Advanced

### 4. Yield Optimization Receiver
**File**: `contracts/yield-optimization-receiver.clar`
**Use Case**: Auto-compound rewards and migrate strategies
**Complexity**: ⭐⭐⭐⭐ Advanced

### 5. Leverage Loop Receiver
**File**: `contracts/leverage-loop-receiver.clar`
**Use Case**: Create leveraged positions with recursive borrowing
**Complexity**: ⭐⭐⭐⭐⭐ Expert

---

## 🎯 1. Liquidation Receiver

### Purpose
Liquidate undercollateralized positions in lending protocols using flash loans, profiting from liquidation bonuses.

### How It Works

```clarity
1. Flash loan: Borrow debt amount
2. Repay borrower's debt → releases collateral
3. Receive collateral + liquidation bonus (10%)
4. Swap collateral to sBTC
5. Repay flash loan + fee
6. Keep profit: liquidation bonus - flash fee
```

### Key Functions

**`execute-flash`** - Main liquidation logic
- Takes flash loan to repay user's debt
- Receives collateral with bonus
- Swaps if needed
- Repays flash loan
- Returns profit

**`calculate-expected-profit`** - Check profitability
```clarity
(calculate-expected-profit u1000000000)
=> {
  flash-loan-amount: 1000000000,
  flash-loan-fee: 500000,
  liquidation-bonus: 100000000,
  expected-profit: 99500000,
  total-to-repay: 1000500000
}
```

**`is-liquidation-profitable`** - Quick check
```clarity
(is-liquidation-profitable u1000000000)
=> true  ;; 10% bonus > 0.05% fee
```

### Economics

| Debt Amount | Flash Fee | Liquidation Bonus | Net Profit |
|-------------|-----------|-------------------|------------|
| 1,000 sBTC | 0.5 sBTC | 100 sBTC | 99.5 sBTC |
| 10,000 sBTC | 5 sBTC | 1,000 sBTC | 995 sBTC |

### Integration Example

```clarity
;; Replace mock functions with real protocol calls

(define-private (mock-repay-debt (amount uint))
  ;; Real integration:
  (contract-call? .lending-protocol repay-debt 
    loan-id 
    amount)
)

(define-private (mock-swap-collateral (collateral uint))
  ;; Real integration:
  (contract-call? .dex swap 
    collateral-token 
    sbtc-token 
    collateral 
    min-out)
)
```

---

## 🔄 2. Collateral Swap Receiver

### Purpose
Swap collateral types in lending positions without closing/reopening, useful when better yield opportunities emerge.

### How It Works

```clarity
1. Flash loan: Borrow current debt amount
2. Repay existing debt → releases old collateral
3. Receive old collateral back
4. Swap old → new collateral on DEX
5. Deposit new collateral
6. Borrow against new collateral
7. Repay flash loan
```

### Key Functions

**`execute-flash`** - Swap collateral
- Repays debt to unlock old collateral
- Swaps collateral on DEX
- Deposits new collateral
- Borrows to repay flash loan

**`calculate-swap-economics`** - Analyze swap
```clarity
(calculate-swap-economics 
  u1000000000  ;; debt
  u1500000000  ;; old collateral value
  u1650000000) ;; new collateral value
=> {
  value-improvement: 150000000,
  net-benefit: 149500000,  ;; After 0.5 fee
  is-profitable: true
}
```

**`is-swap-beneficial`** - APY comparison
```clarity
(is-swap-beneficial 
  u500   ;; current APY (5%)
  u1200  ;; new APY (12%)
  u1000000000)
=> true  ;; 7% APY gain > 0.05% fee
```

### Economics

**Example: USDA → STX staking**
- Current: USDA collateral, 5% APY
- New: STX collateral, 12% APY for staking
- Position: 1,000 sBTC debt, 1,500 USDA collateral
- Flash fee: 0.5 sBTC
- Annual benefit: 7% extra yield = 105 sBTC/year
- Breakeven: 0.5 sBTC / 105 sBTC = 0.005 years (~2 days!)

---

## 📈 3. Multi-DEX Arbitrage Receiver

### Purpose
Capture price differences across multiple DEXs by executing simultaneous buys and sells.

### How It Works

**Simple 2-DEX Arbitrage:**
```clarity
1. Flash loan: Borrow sBTC
2. Buy BTC on cheap DEX A
3. Sell BTC on expensive DEX B
4. Repay flash loan + fee
5. Keep profit
```

**Advanced 3-DEX Multi-hop:**
```clarity
1. Flash loan: Borrow sBTC
2. sBTC → BTC on DEX A
3. BTC → USDA on DEX B
4. USDA → sBTC on DEX C
5. Repay flash loan
6. Profit from circular arbitrage
```

### Key Functions

**`execute-flash`** - Basic arbitrage
- Buys on cheap DEX
- Sells on expensive DEX
- With slippage protection

**`execute-flash-multihop`** - Advanced arbitrage
- Multiple token swaps
- Circular arbitrage
- Higher potential profits

**`calculate-arbitrage-profit`** - Profitability check
```clarity
(calculate-arbitrage-profit
  u1000000000  ;; amount
  u50000       ;; buy price DEX A
  u50250)      ;; sell price DEX B (0.5% higher)
=> {
  net-profit: 4500000,  ;; After 0.05% fee
  roi-bp: 45,           ;; 0.45% return
  is-profitable: true
}
```

**`get-price-spread`** - Monitor opportunities
```clarity
(get-price-spread u50000 u50250)
=> {
  spread-bp: 50,  ;; 0.5% spread
  is-arbitrage-opportunity: true  ;; > 0.05% fee
}
```

### Economics

| Price Spread | Flash Loan | Gross Profit | Flash Fee | Net Profit | ROI |
|--------------|------------|--------------|-----------|------------|-----|
| 0.5% | 1,000 sBTC | 5 sBTC | 0.5 sBTC | 4.5 sBTC | 0.45% |
| 1.0% | 1,000 sBTC | 10 sBTC | 0.5 sBTC | 9.5 sBTC | 0.95% |
| 2.0% | 1,000 sBTC | 20 sBTC | 0.5 sBTC | 19.5 sBTC | 1.95% |

### Slippage Protection

```clarity
(define-constant MAX-SLIPPAGE-BP u100) ;; 1% max

(define-private (verify-slippage (expected uint) (actual uint))
  ;; Ensures swaps execute within acceptable range
  ;; Reverts transaction if slippage too high
)
```

---

## 💰 4. Yield Optimization Receiver

### Purpose
Maximize yield by auto-compounding rewards and migrating between strategies without selling positions.

### How It Works

**Auto-Compound:**
```clarity
1. Harvest pending rewards
2. Flash loan additional capital
3. Compound rewards + flash loan into strategy
4. Borrow against increased position
5. Repay flash loan
6. Net result: larger position, minimal debt increase
```

**Strategy Migration:**
```clarity
1. Flash loan to repay old strategy debt
2. Withdraw all collateral from old strategy
3. Harvest final rewards
4. Deposit everything in new strategy (better APY)
5. Borrow from new strategy
6. Repay flash loan
```

### Key Functions

**`execute-flash`** - Auto-compound
- Harvest rewards
- Add flash capital
- Compound everything
- Borrow to repay

**`execute-flash-strategy-migration`** - Migrate
- Exit old strategy completely
- Move to better strategy
- Maintain position size

**`execute-flash-auto-compound`** - Scheduled compounding
- Only executes if rewards meet threshold
- Automated yield optimization
- Gas-efficient