
**`calculate-compound-benefit`** - Check if worth it
```clarity
(calculate-compound-benefit
  u100000000000  ;; current position (1000)
  u5000000       ;; pending rewards (0.05)
  u800           ;; 8% APY
  u12)           ;; compound 12x/year
=> {
  net-annual-benefit: 3000000,  ;; 0.03 sBTC/year extra
  is-beneficial: true
}
```

**`calculate-strategy-migration-benefit`** - Compare strategies
```clarity
(calculate-strategy-migration-benefit
  u500    ;; old APY 5%
  u1200   ;; new APY 12%
  u100000000000)  ;; position size
=> {
  annual-improvement: 7000000000,  ;; 70 sBTC/year
  breakeven-time-years: 0,  ;; Immediate benefit
  is-beneficial: true
}
```

### Economics

**Compounding Example:**
- Position: 1,000 sBTC
- Rewards: 50 sBTC pending
- APY: 10%
- Compound frequency: Monthly (12x/year)
- Flash fee per compound: 5 sBTC
- Annual fees: 60 sBTC
- Additional yield from compounding: ~105 sBTC
- Net benefit: 45 sBTC/year

**Migration Example:**
- Position: 10,000 sBTC
- Old strategy: 5% APY = 500 sBTC/year
- New strategy: 12% APY = 1,200 sBTC/year
- Migration flash fee: 5 sBTC
- Annual improvement: 700 sBTC
- Breakeven: Immediate (fee paid back in 3 days)

---

## ⚡ 5. Leverage Loop Receiver

### Purpose
Create leveraged positions by recursively borrowing and depositing, amplifying exposure to price movements.

### How It Works

**Leverage Creation (3x example):**
```clarity
1. Flash loan: 1,000 sBTC
2. Deposit 1,000 → Borrow 750 (75% LTV)
3. Deposit 750 → Borrow 562.5
4. Deposit 562.5 → Total position = 2,312.5 sBTC
5. Borrow extra to repay flash loan + fee
6. Result: 2.3x leveraged position
```

**Deleverage:**
```clarity
1. Flash loan amount to repay debt
2. Repay debt → collateral freed
3. Withdraw collateral
4. Use to repay more debt
5. Repeat until unwound
6. Repay flash loan from freed collateral
```

### Key Functions

**`execute-flash`** - Create leverage
- Recursive borrow/deposit loop
- Achieves up to 3x leverage
- Automatically calculates max safe leverage

**`execute-flash-custom-leverage`** - Precise control
- Specify exact leverage ratio
- 1.5x, 2x, 2.5x, etc.
- Custom risk management

**`execute-flash-deleverage`** - Unwind position
- Reverse the leverage loop
- Reduce risk
- Partial or full unwind

**`calculate-leverage-economics`** - Plan position
```clarity
(calculate-leverage-economics
  u1000000000   ;; initial capital (1000)
  u20000        ;; target 2x leverage
  u7500)        ;; 75% LTV
=> {
  total-position: 2000000000,   ;; 2000 sBTC
  total-debt: 1000000000,       ;; 1000 sBTC debt
  flash-loan-needed: 1000000000,
  flash-fee: 500000,
  effective-leverage: 2,
  is-safe: true  ;; >150% collateral
}
```

**`calculate-liquidation-price`** - Risk management
```clarity
(calculate-liquidation-price
  u50000      ;; entry: $50,000
  u20000      ;; 2x leverage
  u8500)      ;; liquidation at 85% LTV
=> {
  liquidation-price: 42500,  ;; $42,500
  max-price-drop-bp: 1500,   ;; 15% drop allowed
  buffer-percent: 15
}
```

**`calculate-amplified-returns`** - Profit/loss analysis
```clarity
(calculate-amplified-returns
  u1000000000   ;; capital
  u20000        ;; 2x leverage
  u1000)        ;; 10% price increase
=> {
  unleveraged-return: 100000000,  ;; 100 sBTC (10%)
  leveraged-return: 200000000,    ;; 200 sBTC (20%)
  amplification-effect: 100000000,
  return-multiplier: 2
}
```

### Economics & Risk

**Leverage Impact:**

| Leverage | Capital | Position | Price +10% | Price -10% |
|----------|---------|----------|------------|------------|
| 1x | 1,000 | 1,000 | +100 (10%) | -100 (-10%) |
| 2x | 1,000 | 2,000 | +200 (20%) | -200 (-20%) |
| 3x | 1,000 | 3,000 | +300 (30%) | -300 (-30%) |

**Liquidation Thresholds:**

| Leverage | Entry | Liquidation | Drop Allowed |
|----------|-------|-------------|--------------|
| 1.5x | $50,000 | $33,333 | -33% |
| 2x | $50,000 | $42,500 | -15% |
| 3x | $50,000 | $47,222 | -5.5% |

**Warning**: Higher leverage = higher risk!

---

## 🛠️ Integration Checklist

### For All Receivers

1. **Replace Mock Functions**
```clarity
;; Mock → Real protocol integration
(define-private (mock-function ...)
  ;; Change to:
  (contract-call? .real-protocol function-name ...))
```

2. **Add Error Handling**
```clarity
(define-constant ERR-PROTOCOL-FAILED (err u600))

(match (contract-call? .protocol action)
  success (ok success)
  error ERR-PROTOCOL-FAILED)
```

3. **Test Thoroughly**
- Unit tests for each function
- Integration tests with real protocols
- Testnet validation
- Edge case scenarios

4. **Gas Optimization**
- Minimize contract calls
- Batch operations where possible
- Optimize data structures
- Profile gas usage

5. **Security Review**
- Access control checks
- Re-entrancy protection
- Integer overflow handling
- Input validation

---

## 📊 Comparison Matrix

| Receiver | Complexity | Profit Type | Risk Level | Gas Cost |
|----------|------------|-------------|------------|----------|
| Liquidation | ⭐⭐⭐ | Fixed bonus | Low | Medium |
| Collateral Swap | ⭐⭐⭐ | APY improvement | Low | Medium |
| Multi-DEX Arb | ⭐⭐⭐⭐ | Price spread | Medium | High |
| Yield Opt | ⭐⭐⭐⭐ | Compound gains | Low | Low-Med |
| Leverage | ⭐⭐⭐⭐⭐ | Amplified gains | High | High |

---

## 🚀 Getting Started

### 1. Choose Your Use Case
Pick the receiver that matches your strategy.

### 2. Study the Code
Read through the contract and comments.

### 3. Understand Economics
Use read-only functions to calculate profitability.

### 4. Replace Mocks
Integrate with real protocols.

### 5. Test on Devnet
```bash
clarinet console

# Load contracts
(contract-call? .flashstack-core flash-mint 
  u1000000000 
  .liquidation-receiver)
```

### 6. Deploy to Testnet
Test with real testnet protocols.

### 7. Mainnet Launch
After security audit and thorough testing.

---

## 💡 Pro Tips

### Profitability First
Always calculate expected profit before executing:
```clarity
;; Example: Check liquidation profit
(contract-call? .liquidation-receiver 
  calculate-expected-profit 
  u1000000000)

;; Only proceed if is-profitable: true
```

### Gas Awareness
Flash loans fail if gas runs out:
- Keep operations simple
- Minimize DEX hops
- Batch where possible
- Test gas usage

### Slippage Protection
Always set maximum acceptable slippage:
```clarity
(define-constant MAX-SLIPPAGE-BP u100) ;; 1%
```

### Safety Buffers
Add safety margins to calculations:
- Don't borrow absolute maximum
- Leave buffer for price volatility
- Account for fees at each step

### Monitor Continuously
Set up alerts for:
- Liquidation opportunities
- Arbitrage spreads
- APY changes
- Risk thresholds

---

## 🔗 Related Documentation

- [FlashStack Core](../../contracts/flashstack-core.clar) - Main protocol
- [Fee Mechanism](./FEE_MECHANISM.md) - How fees work
- [Integration Guide](./INTEGRATION_GUIDE.md) - Build your own
- [Security Model](../05-security/SECURITY_MODEL.md) - Stay safe

---

## 📞 Need Help?

- **Examples unclear?** Open GitHub issue
- **Integration questions?** Join Discord
- **Found a bug?** Submit PR
- **Want to contribute?** Check CONTRIBUTING.md

---

## 🎯 Next Steps

1. **Explore** - Read through each example
2. **Experiment** - Try on devnet
3. **Build** - Create your own receiver
4. **Share** - Contribute back to community

**Happy building!** 🚀

---

*These examples are educational. Always perform security audits before mainnet deployment.*
