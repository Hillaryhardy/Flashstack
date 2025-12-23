# 🔗 Direct Links - FlashStack Tests 4-8


---

> **This document is from December 7, 2025** - when we finished testnet testing.  
> Check the main [README.md](../../README.md) for current status.
> 
> **Where we are now (Dec 23):**  
> - Repo is public on GitHub
> - Still on testnet (no audit yet)  
> - Applying for grants to fund the audit


**All tests use the same link - just different arguments!**

---

## Test #4: Leverage Loop Receiver (2M sBTC)

**Direct Link:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

**Arguments to paste:**
```
amount: u2000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.leverage-loop-receiver
```

**Expected:** flash-mint-id: u4, fee: u1000

---

## Test #5: Yield Optimization Receiver (3.5M sBTC)

**Direct Link:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

**Arguments to paste:**
```
amount: u3500000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.yield-optimization-receiver
```

**Expected:** flash-mint-id: u5, fee: u1750

---

## Test #6: Collateral Swap Receiver (2.5M sBTC)

**Direct Link:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

**Arguments to paste:**
```
amount: u2500000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.collateral-swap-receiver
```

**Expected:** flash-mint-id: u6, fee: u1250

---

## Test #7: DEX Aggregator Receiver (6M sBTC) 🔥 LARGEST!

**Direct Link:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

**Arguments to paste:**
```
amount: u6000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.dex-aggregator-receiver
```

**Expected:** flash-mint-id: u7, fee: u3000

⚠️ **This is the BIGGEST test - 6 MILLION sBTC!**

---

## Test #8: Multi-DEX Arbitrage Receiver (4M sBTC) 🏁 FINAL!

**Direct Link:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/flash-mint?chain=testnet
```

**Arguments to paste:**
```
amount: u4000000
receiver: ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.multidex-arbitrage-receiver
```

**Expected:** flash-mint-id: u8, fee: u2000

🎉 **FINAL TEST - After this you're DONE!**

---

## 📋 Quick Workflow

For each test:

1. **Click the direct link** (opens sandbox with flash-mint function)
2. **Paste the amount** in the "amount" field
3. **Paste the receiver** in the "receiver" field
4. **Click "Call function"**
5. **Wait ~10 seconds** for confirmation
6. **Check "Function called" tab** for result
7. **Screenshot the result**
8. **Move to next test**

---

## 🎯 After All Tests

**Final Verification:**

**Check Supply = 0:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.sbtc-token/get-total-supply?chain=testnet
```
Expected: (ok u0)

**Check Final Stats:**
```
https://explorer.hiro.so/sandbox/contract-call/ST2X1GBHA2WJXREWP231EEQXZ1GDYZEEXYRAD1PA8.flashstack-core/get-stats?chain=testnet
```
Expected:
- total-flash-mints: u8
- total-volume: u27000000
- total-fees-collected: u13500

---

## 🎉 Success Criteria

✅ All 8 tests pass  
✅ Supply returns to 0  
✅ Statistics match expected  
✅ 100% success rate  
✅ First fully-tested flash loan protocol on Bitcoin L2!

---

**Start with Test #4 and work through to Test #8!** 🚀
