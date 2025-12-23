# 🚀 FlashStack Testnet Deployment Checklist


---

> **This document is from December 7, 2025** - when we finished testnet testing.  
> Check the main [README.md](../../README.md) for current status.
> 
> **Where we are now (Dec 23):**  
> - Repo is public on GitHub
> - Still on testnet (no audit yet)  
> - Applying for grants to fund the audit


**Status**: Ready to Deploy  
**Date**: December 7, 2024  
**Version**: v1.3 Production Ready

---

## ✅ Pre-Deployment Checklist

### Environment Setup
- [ ] Clarinet 3.5.0+ installed
- [ ] PowerShell available
- [ ] In flashstack directory
- [ ] All contracts compile (`clarinet check`)

### Wallet Setup
- [ ] Have Stacks testnet wallet (Leather, Xverse, or Hiro)
- [ ] Wallet has testnet STX (get from https://explorer.hiro.so/sandbox/faucet?chain=testnet)
- [ ] Wallet is connected and ready

### Testing Complete
- [ ] All 31 tests passed (100% success rate)
- [ ] All 8 receivers working
- [ ] All bugs fixed
- [ ] Documentation complete

---

## 🚀 Deployment Steps

### Step 1: Prepare for Deployment

```powershell
cd C:\Users\mattg\flashstack

# Check contracts compile
clarinet check
```

**Expected**: ✅ All contracts compile successfully

---

### Step 2: Run Deployment Script

```powershell
.\deploy-testnet.ps1
```

This script will:
1. ✅ Check Clarinet installation
2. ✅ Verify all contracts compile
3. ✅ Generate deployment plan
4. ✅ Show deployment summary
5. ⏸️ Prompt for confirmation
6. 🚀 Deploy to testnet (if confirmed)

---

### Step 3: Deploy Contracts

When prompted "Do you want to proceed with deployment? (yes/no)":
- Type `yes` and press Enter
- Wait for deployment (may take 5-10 minutes)
- Watch for success messages

**Expected Output**:
```
✓ flash-receiver-trait deployed: ST...
✓ sbtc-token deployed: ST...
✓ flashstack-core deployed: ST...
✓ test-receiver deployed: ST...
✓ example-arbitrage-receiver deployed: ST...
✓ liquidation-receiver deployed: ST...
✓ leverage-loop-receiver deployed: ST...
✓ yield-optimization-receiver deployed: ST...
✓ collateral-swap-receiver deployed: ST...
✓ dex-aggregator-receiver deployed: ST...
✓ multidex-arbitrage-receiver deployed: ST...
```

---

### Step 4: Save Contract Addresses

Copy all contract addresses from the deployment output!

Example:
```
flash-receiver-trait: ST1ABC...XYZ.flash-receiver-trait
sbtc-token: ST1ABC...XYZ.sbtc-token
flashstack-core: ST1ABC...XYZ.flashstack-core
...
```

---

### Step 5: Post-Deployment Setup

```powershell
.\post-deploy.ps1
```

This will:
1. Ask for contract addresses
2. Generate Clarity commands
3. Save addresses to `testnet-addresses.md`
4. Provide next steps

---

### Step 6: Set Flash Minter (CRITICAL!)

Go to Stacks Explorer: https://explorer.hiro.so/?chain=testnet

Connect your wallet and call:

```clarity
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
```

**Expected**: `(ok true)`

---

### Step 7: Test First Flash Mint

```clarity
(contract-call? .flashstack-core flash-mint u1000000 .test-receiver)
```

**Expected**:
```clarity
(ok {
  amount: u1000000,
  borrower: ST...,
  fee: u50,
  flash-mint-id: u1,
  total-minted: u1000050
})
```

---

### Step 8: Verify Deployment

```clarity
;; Check stats
(contract-call? .flashstack-core get-stats)
;; Expected: total-flash-mints: u1, total-volume: u1000000

;; Verify supply
(contract-call? .sbtc-token get-total-supply)
;; Expected: (ok u0)
```

---

## 📋 Post-Deployment Tasks

### Immediate
- [ ] Save all contract addresses
- [ ] Update TESTNET_DEPLOYMENT.md with addresses
- [ ] Create testnet-addresses.md file
- [ ] Test all 8 receivers on testnet
- [ ] Verify stats tracking
- [ ] Test pause/unpause

### Communication
- [ ] Update README with testnet info
- [ ] Create deployment announcement
- [ ] Share on Twitter
- [ ] Post in Discord/Telegram
- [ ] Update project documentation

### Monitoring (First Week)
- [ ] Monitor for any errors
- [ ] Track usage statistics
- [ ] Collect community feedback
- [ ] Document any issues
- [ ] Test all receiver contracts

---

## 🎯 Contract Deployment Order

The contracts will deploy in this order:

1. **flash-receiver-trait** - Interface definition (no dependencies)
2. **sbtc-token** - Token contract (depends on nothing)
3. **flashstack-core** - Core protocol (depends on trait + token)
4. **All receivers** - Example contracts (depend on trait + core)

---

## 💡 Troubleshooting

### "Clarinet not found"
**Solution**: Install Clarinet from https://github.com/hirosystems/clarinet

### "Insufficient STX balance"
**Solution**: Get more testnet STX from https://explorer.hiro.so/sandbox/faucet?chain=testnet

### "Contract already exists"
**Solution**: Either:
- Use a different wallet address
- Increment the deployment plan version
- Wait for testnet to reset

### "Flash mint fails with ERR-NOT-AUTHORIZED"
**Solution**: Ensure you called `set-flash-minter` first

### "Flash mint fails with ERR-CALLBACK-FAILED"
**Solution**: Check receiver contract logic - ensure it returns correct amount

---

## 📊 Success Metrics

After deployment, verify:

- ✅ All 11 contracts deployed
- ✅ Flash minter set correctly
- ✅ First flash mint successful
- ✅ Supply returns to 0
- ✅ Stats tracked correctly
- ✅ No errors in console

---

## 🎉 Deployment Complete!

Once all steps are complete:

1. ✅ All contracts deployed to testnet
2. ✅ Flash minter authorized
3. ✅ First flash mint successful
4. ✅ All tests passing
5. ✅ Addresses documented

**Next**: Share your success and gather feedback!

---

## 📁 Generated Files

After deployment, you'll have:

- `deployments/default.testnet-plan.yaml` - Deployment plan
- `testnet-addresses.md` - Contract addresses
- `deployments/testnet-deployment-[date].log` - Deployment log

---

## 🚀 What's Next?

### Short Term (This Week)
1. Monitor testnet deployment
2. Test all receiver contracts
3. Gather initial feedback
4. Fix any issues

### Medium Term (This Month)
1. Community testing
2. Documentation improvements
3. Demo video creation
4. Prepare for mainnet

### Long Term (Q1 2026)
1. Code4STX grant application (January)
2. Security audit
3. Mainnet preparation
4. Marketing campaign

---

**Good luck with your deployment! 🚀**

For questions or issues, refer to TESTNET_DEPLOYMENT.md or create a GitHub issue.
