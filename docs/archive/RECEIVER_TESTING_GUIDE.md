# 🧪 FlashStack Receiver Testing Guide

**Complete testing sequence for all 8 receiver contracts**

---

## 🎯 Test #1: test-receiver ✅ COMPLETE

**Amount:** 1,000,000 sBTC  
**Status:** ✅ SUCCESS

---

## 🎯 Test #2: example-arbitrage-receiver

### Contract Call Details
**Contract:** `ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core`  
**Function:** `flash-mint`

**Arguments:**
```clarity
amount: u3000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver
```

### Expected Result
```clarity
(ok {
  amount: u3000000,
  borrower: ST2X1GB...D1PA8,
  fee: u1500,
  flash-mint-id: u2,
  total-minted: u3001500
})
```

### Use Case
Simulates DEX arbitrage: buy low on one DEX, sell high on another

### Direct Link
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

---

## 🎯 Test #3: liquidation-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u5000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver
```

### Expected Result
```clarity
(ok {
  amount: u5000000,
  borrower: ST2X1GB...D1PA8,
  fee: u2500,
  flash-mint-id: u3,
  total-minted: u5002500
})
```

### Use Case
Liquidate undercollateralized positions and claim rewards

---

## 🎯 Test #4: leverage-loop-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u2000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver
```

### Expected Result
```clarity
(ok {
  amount: u2000000,
  borrower: ST2X1GB...D1PA8,
  fee: u1000,
  flash-mint-id: u4,
  total-minted: u2001000
})
```

### Use Case
Create leveraged positions: borrow → deposit → borrow more → repeat

---

## 🎯 Test #5: yield-optimization-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u3500000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver
```

### Expected Result
```clarity
(ok {
  amount: u3500000,
  borrower: ST2X1GB...D1PA8,
  fee: u1750,
  flash-mint-id: u5,
  total-minted: u3501750
})
```

### Use Case
Rebalance positions across yield protocols to maximize returns

---

## 🎯 Test #6: collateral-swap-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u2500000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver
```

### Expected Result
```clarity
(ok {
  amount: u2500000,
  borrower: ST2X1GB...D1PA8,
  fee: u1250,
  flash-mint-id: u6,
  total-minted: u2501250
})
```

### Use Case
Swap collateral type without closing position: repay → swap → redeposit

---

## 🎯 Test #7: dex-aggregator-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u6000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver
```

### Expected Result
```clarity
(ok {
  amount: u6000000,
  borrower: ST2X1GB...D1PA8,
  fee: u3000,
  flash-mint-id: u7,
  total-minted: u6003000
})
```

### Use Case
Route large trades through multiple DEXs for best execution

**Note:** This is the LARGEST test amount (6M sBTC)

---

## 🎯 Test #8: multidex-arbitrage-receiver

### Contract Call Details
**Arguments:**
```clarity
amount: u4000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver
```

### Expected Result
```clarity
(ok {
  amount: u4000000,
  borrower: ST2X1GB...D1PA8,
  fee: u2000,
  flash-mint-id: u8,
  total-minted: u4002000
})
```

### Use Case
Complex arbitrage: buy on DEX A, sell on DEX B, buy back on DEX C

---

## 📊 Testing Workflow

### For Each Test:

1. **Navigate to FlashStack Core**
   ```
   https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
   ```

2. **Enter Arguments**
   - Copy the `amount` value
   - Copy the `receiver` contract address
   - Skip post-conditions (or set to STX ≥ 0)

3. **Call Function**
   - Click "Call function"
   - Confirm transaction in wallet
   - Wait for confirmation (~10 seconds)

4. **Verify Results**
   - Check transaction success
   - Verify returned values match expected
   - Note transaction ID

5. **Check Supply**
   Navigate to sbtc-token and call `get-total-supply`
   - Expected: `(ok u0)` ✅

6. **Check Statistics**
   Navigate to flashstack-core and call `get-stats`
   - Verify flash mint count incremented
   - Verify volume increased
   - Verify fees accumulated

7. **Document**
   - Save transaction ID
   - Screenshot result
   - Update TESTNET_SUCCESS.md

---

## 🎉 After All Tests Complete

### Final Verification

1. **Supply Check**
   ```
   Contract: ST2X1GB...D1PA8.sbtc-token
   Function: get-total-supply
   Expected: (ok u0) ✅
   ```

2. **Final Statistics**
   ```
   Contract: ST2X1GB...D1PA8.flashstack-core
   Function: get-stats
   Expected:
   {
     current-fee-bp: u5,
     paused: false,
     total-fees-collected: u13500,
     total-flash-mints: u8,
     total-volume: u27000000
   }
   ```

3. **Success Rate**
   - 8/8 receivers passed = 100% ✅

---

## 🎯 Quick Copy-Paste Commands

### Test 2 - Arbitrage
```
u3000000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.example-arbitrage-receiver
```

### Test 3 - Liquidation
```
u5000000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.liquidation-receiver
```

### Test 4 - Leverage
```
u2000000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver
```

### Test 5 - Yield
```
u3500000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver
```

### Test 6 - Collateral
```
u2500000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver
```

### Test 7 - DEX Aggregator
```
u6000000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver
```

### Test 8 - Multi-DEX
```
u4000000
ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver
```

---

**Ready to test? Start with Test #2 (example-arbitrage-receiver)!** 🚀
