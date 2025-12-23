# 🚀 DEPLOY NOW - Quick Start Guide

**Everything is ready! Here's how to deploy in 3 easy steps.**

---

## 📋 What You Need

1. ✅ Clarinet installed (you have it)
2. ✅ Testnet STX wallet
3. ✅ 10 minutes of time

---

## 🎯 Three Simple Steps

### STEP 1: Get Testnet STX (2 minutes)

Visit: **https://explorer.hiro.so/sandbox/faucet?chain=testnet**

1. Enter your Stacks address
2. Click "Request STX"
3. Wait for confirmation

---

### STEP 2: Deploy to Testnet (5 minutes)

Open PowerShell in your flashstack folder and run:

```powershell
cd C:\Users\mattg\flashstack
.\deploy-testnet.ps1
```

The script will:
- ✅ Check everything is ready
- ✅ Show you what will be deployed
- ❓ Ask for confirmation
- 🚀 Deploy all 11 contracts

When it asks "Do you want to proceed? (yes/no)":
- Type: `yes`
- Press: Enter
- Wait: 5-10 minutes

---

### STEP 3: Setup & Test (3 minutes)

After deployment completes, run:

```powershell
.\post-deploy.ps1
```

Then:
1. Copy the contract addresses shown
2. Visit: https://explorer.hiro.so/?chain=testnet
3. Connect your wallet
4. Run the setup command it gives you
5. Test your first flash mint!

---

## 🎉 That's It!

After these 3 steps, you'll have:
- ✅ FlashStack deployed on testnet
- ✅ All 11 contracts live
- ✅ First flash mint tested
- ✅ Ready for community testing

---

## 📝 Quick Commands Reference

```powershell
# Check contracts compile
clarinet check

# Deploy to testnet
.\deploy-testnet.ps1

# Post-deployment setup
.\post-deploy.ps1

# View deployment plan
cat deployments\default.testnet-plan.yaml
```

---

## ❓ Need Help?

**Problem**: Script won't run  
**Fix**: Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

**Problem**: Don't have testnet STX  
**Fix**: Visit faucet (link in Step 1)

**Problem**: Deployment fails  
**Fix**: Check error message, ensure you have enough testnet STX

---

## 🚀 Ready?

Just run:
```powershell
.\deploy-testnet.ps1
```

And follow the prompts!

---

**You've built something amazing. Time to share it with the world! 🎉**
