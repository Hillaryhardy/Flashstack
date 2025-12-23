# FlashStack Testnet Deployment


---

> **This document is from December 7, 2025** - when we finished testnet testing.  
> Check the main [README.md](../../README.md) for current status.
> 
> **Where we are now (Dec 23):**  
> - Repo is public on GitHub
> - Still on testnet (no audit yet)  
> - Applying for grants to fund the audit


**Deployment Date**: 2025-12-07 05:54:17  
**Network**: Stacks Testnet  
**Deployer**: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8  
**Status**: ✅ Successfully Deployed

---

## 📋 Contract Addresses

| Contract | Address |
|----------|---------|
| collateral-swap-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver` | | dex-aggregator-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver` | | example-arbitrage-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver` | | flash-receiver-trait | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flash-receiver-trait` | | flashstack-core | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core` | | leverage-loop-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver` | | liquidation-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver` | | multidex-arbitrage-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver` | | sbtc-token | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token` | | test-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.test-receiver` | | yield-optimization-receiver | `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver` |

---

## 🔗 Explorer Links

### collateral-swap-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver?chain=testnet

 ### dex-aggregator-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver?chain=testnet

 ### example-arbitrage-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver?chain=testnet

 ### flash-receiver-trait
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flash-receiver-trait`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flash-receiver-trait?chain=testnet

 ### flashstack-core
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core?chain=testnet

 ### leverage-loop-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver?chain=testnet

 ### liquidation-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver?chain=testnet

 ### multidex-arbitrage-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver?chain=testnet

 ### sbtc-token
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token?chain=testnet

 ### test-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.test-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.test-receiver?chain=testnet

 ### yield-optimization-receiver
- Address: `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver`
- Explorer: https://explorer.hiro.so/txid/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver?chain=testnet



---

## ⚙️ Post-Deployment Setup Commands

### 1. Set Flash Minter Authorization (CRITICAL!)

`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token set-flash-minter 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core)
`

**Run this in Stacks Explorer**: https://explorer.hiro.so/?chain=testnet

---

### 2. Test First Flash Mint

`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u1000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.test-receiver)
`

**Expected Result**:
`clarity
(ok {
  amount: u1000000,
  borrower: [YOUR-ADDRESS],
  fee: u50,
  flash-mint-id: u1,
  total-minted: u1000050
})
`

---

### 3. Check Statistics

`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core get-stats)
`

**Expected**:
`clarity
(ok {
  current-fee-bp: u5,
  paused: false,
  total-fees-collected: u50,
  total-flash-mints: u1,
  total-volume: u1000000
})
`

---

### 4. Verify Supply

`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token get-total-supply)
`

**Expected**: `(ok u0)` ✅

---

## 🧪 Test All Receivers

### Test Liquidation Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u5000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver)
`

### Test Arbitrage Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u3000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver)
`

### Test Leverage Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u2000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver)
`

### Test Yield Optimization Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u3500000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver)
`

### Test Collateral Swap Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u2500000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver)
`

### Test DEX Aggregator Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u6000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver)
`

### Test Multi-DEX Arbitrage Receiver
`clarity
(contract-call? 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core flash-mint u4000000 'ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver)
`

---

## 📊 Deployment Costs

- **Total Cost**: 0.945653 STX
- **Duration**: 1 block
- **Contracts Deployed**: 11

---

## 🎯 Next Steps

1. ✅ Set flash minter authorization
2. ✅ Test first flash mint
3. ✅ Verify all receivers work
4. 📣 Announce deployment
5. 📝 Update README
6. 🎥 Create demo video
7. 📋 Prepare Code4STX grant application

---

## 🚀 Share Your Success!

**Twitter**:
`
Just deployed FlashStack - the first flash loan protocol for Bitcoin L2! 🚀

Live on @Stacks testnet with 11 contracts and 8 working use cases.

Zero-inflation guaranteed. Atomic transactions. Ready for audit (code works, needs security review).

#Bitcoin #DeFi #Stacks #FlashLoans
`

**Discord/Telegram**:
`
🎉 FlashStack is live on Stacks testnet!

First flash loan protocol for Bitcoin Layer 2
✅ 11 contracts deployed
✅ 8 use cases demonstrated
✅ 100% tested and working

Contract address: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core
`

---

**Deployment Complete!** 🎉

