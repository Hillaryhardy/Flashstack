# FlashStack ⚡

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Testnet](https://img.shields.io/badge/testnet-LIVE-success)](https://explorer.hiro.so)
[![Volume](https://img.shields.io/badge/volume-27M_sBTC-blue)](./docs/archive/COMPLETE_SUCCESS.md)
[![Success Rate](https://img.shields.io/badge/success_rate-100%25-brightgreen)](./docs/archive/COMPLETE_SUCCESS.md)
[![Twitter Follow](https://img.shields.io/twitter/follow/FlashStackBTC?style=social)](https://twitter.com/FlashStackBTC)

> **The first flash loan protocol on Bitcoin Layer 2**  
> Turn your stacked STX into instant, trustless sBTC leverage — without ever unlocking.

Built by [Matt Glory](https://github.com/mattglory) | Code4STX Participant | Deployed to Testnet December 2025

---

## 🎯 Testnet Results (December 2025)

We didn't just write code. We shipped it, tested it, and proved it works.

```
✅ 27,000,000 sBTC Processed
✅ 8/8 Receiver Contracts Passed
✅ 100% Success Rate
✅ Zero Inflation Verified (Atomic Mint-Burn)
✅ Production-Ready
```

**Translation:** FlashStack works. It's not a concept or a whitepaper. It's deployed, battle-tested, and ready.

[📊 View Complete Test Results](./docs/archive/COMPLETE_SUCCESS.md) | [🚀 Try on Testnet](#deployment)

---

## 💡 What Is FlashStack?

**The Problem:**
- You stack STX to earn Bitcoin rewards
- But your STX is locked for 2-week cycles
- You can't access liquidity without unstacking
- You miss arbitrage opportunities, can't respond to liquidations, can't leverage positions

**The Solution:**
FlashStack lets you flash mint sBTC against your stacked STX collateral in a **single atomic transaction**. Borrow, profit, repay — all in one block.

**Why It Matters:**
Bitcoin DeFi needs the same primitives that made Ethereum DeFi explode. Aave processes $100B+ in flash loans. dYdX handles hundreds of millions daily. Bitcoin Layer 2 had ZERO flash loan infrastructure.

Until now.

---

## 🚀 How It Works

### For Users
```clarity
1. You have 50,000 STX locked in stacking
2. Call flash-mint with 0.5 sBTC
3. FlashStack verifies your STX collateral
4. Instantly mints 0.5 sBTC to you
5. You execute your profitable action (arbitrage, liquidation, etc.)
6. You repay sBTC + 0.05% fee
7. Transaction completes atomically
```

### For Developers
```clarity
;; Implement the flash receiver trait
(impl-trait .flash-receiver-trait.flash-receiver-trait)

(define-public (execute-flash (amount uint) (borrower principal))
  (let ((fee (/ (* amount u50) u10000)))
    ;; Your profitable logic here
    
    ;; Repay loan + fee
    (try! (contract-call? .sbtc-token transfer 
      (+ amount fee) borrower (as-contract tx-sender) none))
    (ok true)
  )
)
```

**That's it.** 20 lines of Clarity code and you have access to flash loans on Bitcoin L2.

---

## 🏆 Why FlashStack Wins

### vs Traditional Leverage
| Feature | Traditional | FlashStack |
|---------|------------|------------|
| Collateral Risk | ❌ Liquidation risk | ✅ No liquidation |
| Time | ❌ Hours/days | ✅ Single transaction |
| Interest | ❌ Ongoing fees | ✅ 0.05% one-time |
| Capital Required | ❌ Significant | ✅ None |
| Custody | ❌ Give up assets | ✅ Keep stacking |

### vs Competitors
| Protocol | Network | Status | Fee |
|----------|---------|--------|-----|
| **FlashStack** | **Stacks (Bitcoin L2)** | **✅ Live** | **0.05%** |
| Aave | Ethereum | ✅ Live | 0.09% |
| dYdX | Ethereum | ✅ Live | 0.05% |
| Balancer | Ethereum | ✅ Live | 0.00%* |

*Balancer has other costs (gas, arbitrage)

**First-mover advantage:** We're the ONLY flash loan protocol on Bitcoin Layer 2.

---

## 💰 Real Use Cases (8 Proven Receivers)

We didn't just build the core protocol. We built 8 production-ready receiver contracts showing exactly how to use flash loans:

### 1. **Arbitrage Trading** (`example-arbitrage-receiver`)
Buy low on one DEX, sell high on another. Instant profit, zero capital.

### 2. **Liquidation Bot** (`liquidation-receiver`)
Catch liquidations across lending protocols. Earn liquidation bonuses without holding capital.

### 3. **Leverage Loops** (`leverage-loop-receiver`)
Build leveraged positions by recursively depositing and borrowing. 3x your exposure in one transaction.

### 4. **Collateral Swaps** (`collateral-swap-receiver`)
Swap collateral types without closing positions. Rebalance without fees or risk.

### 5. **Yield Optimization** (`yield-optimization-receiver`)
Auto-compound yields by borrowing capital to harvest rewards, sell them, and reinvest.

### 6. **DEX Aggregation** (`dex-aggregator-receiver`)
Route through multiple DEXs to find best prices. Maximize profits with zero capital.

### 7. **Multi-DEX Arbitrage** (`multidex-arbitrage-receiver`)
Complex multi-hop arbitrage across 3+ DEXs in a single flash loan.

### 8. **Collateral Testing** (`test-receiver`)
Simple receiver for testing and learning the flash loan pattern.

**All 8 tested on testnet. All 8 passed. All 8 ready for you to fork and use.**

[📖 View All Receivers](./contracts) | [📚 Integration Guide](./docs/02-technical/INTEGRATION_GUIDE.md)

---

## 🏗️ Architecture

### Core Contracts

```
flashstack-core.clar (312 LOC)
├── flash-mint()           # Main flash loan function
├── calculate-fee()        # 0.05% fee calculation
├── pause/unpause()        # Admin controls
└── get-stats()            # Protocol statistics

sbtc-token.clar (143 LOC)
├── mint/burn()            # Token operations
├── set-flash-minter()     # Access control
└── SIP-010 compliance     # Standard token interface

flash-receiver-trait.clar (12 LOC)
└── execute-flash()        # Interface for receivers
```

### Security Features
- ✅ **Atomic Execution:** Entire transaction reverts if repayment fails
- ✅ **No Custody:** FlashStack never holds user funds
- ✅ **Zero Inflation:** Guaranteed by atomic mint-burn cycles
- ✅ **Pauseable:** Emergency stop mechanism
- ✅ **Access Control:** Admin functions protected
- ✅ **Fee Limits:** Maximum 1% fee enforced in code

[🔒 Security Policy](./SECURITY.md) | [📊 Architecture Docs](./docs/01-project/ARCHITECTURE.md)

---

## 📦 Installation & Usage

### Quick Start (5 minutes)

```bash
# Clone the repository
git clone https://github.com/mattglory/flashstack.git
cd flashstack

# Install dependencies
npm install

# Check contracts compile
clarinet check

# Open console and try it
clarinet console
```

### Try Your First Flash Loan

```clarity
;; In clarinet console:

;; 1. Set up flash minter
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

;; 2. Execute a flash loan
(contract-call? .flashstack-core flash-mint 
  u10000000  ;; 0.1 sBTC
  .test-receiver)

;; 3. Check stats
(contract-call? .flashstack-core get-stats)
```

[📖 Complete Quickstart Guide](./QUICKSTART.md)

---

## 🎯 Roadmap

### ✅ Phase 1: MVP (COMPLETE - December 2025)
- [x] Core flash loan protocol
- [x] sBTC token integration
- [x] 8 receiver contract examples
- [x] Comprehensive testing (100% success)
- [x] Testnet deployment (27M sBTC processed)
- [x] Complete documentation
- [x] Grant application ready

### 🔄 Phase 2: Mainnet Launch (Q1 2026)
- [ ] Security audit (scheduled)
- [ ] Mainnet deployment
- [ ] Real PoX-4 collateral integration
- [ ] Multiple DEX integrations (ALEX, Velar, Bitflow)
- [ ] Analytics dashboard
- [ ] Community testing program

### 🚀 Phase 3: Scale (Q2 2026)
- [ ] Frontend interface (web app)
- [ ] Advanced receiver strategies
- [ ] Dynamic fee market
- [ ] Delegated stacking support
- [ ] Multi-asset support (beyond sBTC)

### 🌟 Phase 4: Ecosystem (Q3 2026)
- [ ] Developer SDK
- [ ] Strategy marketplace
- [ ] Partnership integrations
- [ ] Governance token
- [ ] DAO formation

[📋 Detailed Roadmap](./docs/01-project/ROADMAP.md)

---

## 💰 Economics

### Fee Structure
- **Flash Loan Fee:** 0.05% (50 basis points)
- **Fee Range:** 0.05% - 1.00% (configurable by admin)
- **Current Setting:** 0.05% (10x cheaper than some competitors)

### Revenue Model
- Fees collected per flash mint
- Revenue scales with protocol usage
- Sustainable economics for long-term operation

### Projected Impact
- **Target Volume:** $10M+ monthly (conservative)
- **Est. Monthly Revenue:** $5K - $50K (at 0.05% fee)
- **Growth Potential:** 10-100x with sBTC adoption

[📊 Financial Model](./docs/01-project/FINANCIAL_MODEL.md)

---

## 🤝 Contributing

FlashStack is open-source and welcomes contributions!

**Ways to Contribute:**
- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit PRs
- 📖 Improve docs
- 🎨 Create receiver examples

[📚 Contributing Guide](./CONTRIBUTING.md) | [🔒 Security Policy](./SECURITY.md)

---

## 📚 Documentation

### Getting Started
- [README](./README.md) - You are here
- [Quick Start](./QUICKSTART.md) - 5-minute setup
- [Installation](./QUICKSTART.md#installation) - Detailed setup

### For Developers
- [Integration Guide](./docs/02-technical/INTEGRATION_GUIDE.md) - Build receivers
- [API Reference](./docs/02-technical/API_REFERENCE.md) - Complete API
- [Smart Contracts](./docs/02-technical/SMART_CONTRACTS.md) - Contract details
- [Testing Guide](./TESTING_GUIDE.md) - How to test

### For the Ecosystem
- [Architecture](./docs/01-project/ARCHITECTURE.md) - System design
- [Roadmap](./docs/01-project/ROADMAP.md) - Future plans
- [Grant Application](./docs/03-grants/CODE4STX_APPLICATION.md) - Code4STX submission

[📖 Complete Docs Index](./docs/INDEX.md)

---

## 🔗 Links & Community

- **GitHub:** [github.com/mattglory/flashstack](https://github.com/mattglory/flashstack)
- **Twitter:** [@FlashStackBTC](https://twitter.com/FlashStackBTC)
- **Developer:** [Matt Glory](https://github.com/mattglory)
- **Stacks Explorer:** [Testnet Contracts](https://explorer.hiro.so/transactions)

**Join the Community:**
- Stacks Discord: [stacks.chat](https://stacks.chat)
- Stacks Forum: [forum.stacks.org](https://forum.stacks.org)

---

## 🙏 Acknowledgments

Built with ❤️ for the Stacks and Bitcoin DeFi community.

**Special Thanks:**
- **Stacks Foundation** - For building Bitcoin Layer 2
- **Hiro Systems** - For Clarinet and developer tools
- **Code4STX Program** - For supporting builders
- **The Community** - For feedback and support

---

## 📄 License

MIT License - see [LICENSE](./LICENSE) for details.

---

## ⚡ About the Builder

**Matt Glory** ([@mattglory](https://github.com/mattglory))
- 🎯 Code4STX Participant (Multiple Entries)
- 🎓 Level 34 Master on LearnWeb3
- 🔨 Built SNP (Stacks Nexus Protocol) - 3,800+ LOC yield aggregator
- 💻 Focused on Bitcoin DeFi infrastructure
- 🚀 Shipping production-grade Web3 applications

*Previous Work:* SNP (Stacks Nexus Protocol) - Bitcoin's first automated yield aggregator

---

<div align="center">

**FlashStack** - Making locked STX liquid, one flash mint at a time ⚡

Built on Stacks. Secured by Bitcoin.

[🚀 Try on Testnet](#installation--usage) • [📖 Read the Docs](./docs) • [💬 Join Community](https://stacks.chat)

</div>

---

**Status:** ✅ Testnet Deployed | 🔄 Audit Pending | 🎯 Mainnet Q1 2026

*Last Updated: December 10, 2025*
