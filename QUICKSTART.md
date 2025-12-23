# FlashStack - Quick Start Guide

Get FlashStack running on your local devnet in under 5 minutes!

## Prerequisites

1. **Install Clarinet** (if not already installed)
```bash
# Windows (PowerShell)
winget install clarinet

# Or download from:
# https://github.com/hirosystems/clarinet/releases
```

2. **Verify Installation**
```bash
clarinet --version
# Should show: clarinet-cli 1.x.x
```

## Setup (2 minutes)

### 1. Navigate to Project
```bash
cd C:\Users\mattg\flashstack
```

### 2. Check Contracts
```bash
clarinet check
```

You should see:
```
✔ 4 contracts checked
✔ All contracts are valid
```

### 3. Run Tests
```bash
# Install dependencies (first time only)
npm install

# Run test suite
npm test
```

Expected output:
```
✓ tests/flashstack-core_test.ts
✓ tests/sbtc-token_test.ts

Test Files  2 passed (2)
Tests  X passed (X)
✔ FlashStack: Tracks statistics correctly
✔ sBTC: Returns correct token metadata
✔ sBTC: Only authorized minter can mint tokens
✔ sBTC: Can transfer tokens between accounts
✔ sBTC: Can set and verify flash minter

9 passing
```

## Quick Demo (3 minutes)

### 1. Start Clarinet Console
```bash
clarinet console
```

### 2. Deploy Contracts (in console)
```clarity
;; Contracts auto-deploy on console start
;; Verify they're there:
(contract-call? .flashstack-core get-stats)
```

### 3. Execute Your First Flash Mint!

```clarity
;; Step 1: Set FlashStack as the flash minter
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

;; Step 2: Execute a flash mint (10 sBTC)
(contract-call? .flashstack-core flash-mint 
  u1000000000  ;; 10 sBTC
  .example-arbitrage-receiver)

;; Step 3: Check statistics
(contract-call? .flashstack-core get-stats)
```

Expected result:
```clarity
(ok {
  total-flash-mints: u1,
  total-volume: u1000000000,
  total-fees-collected: u500000,
  current-fee-bp: u50
})
```

🎉 **Congratulations!** You've executed your first flash mint!

## Next Steps

### Experiment with Parameters

```clarity
;; Try different amounts
(contract-call? .flashstack-core flash-mint 
  u5000000000  ;; 50 sBTC
  .example-arbitrage-receiver)

;; Check fee calculations
(contract-call? .flashstack-core calculate-fee u1000000000)
;; Returns: (ok u500000) - which is 0.05%

;; Check max flash amount for collateral
(contract-call? .flashstack-core get-max-flash-amount u1000000000000)
;; Shows max sBTC you can mint with 1M STX locked
```

### Understand Collateral Ratios

```clarity
;; Calculate minimum collateral needed
(contract-call? .flashstack-core get-min-collateral u1000000000)
;; Returns: (ok u3000000000) - need 30 sBTC worth of STX for 10 sBTC

;; Check your locked STX (simulated in tests)
(contract-call? .flashstack-core get-stx-locked tx-sender)
;; Returns: u1000000000000 (1M STX in tests)
```

## Common Commands

```bash
# Check all contracts compile
clarinet check

# Run all tests
clarinet test

# Run specific test
clarinet test tests/flashstack-core_test.ts

# Start console for manual testing
clarinet console

# Start local devnet
clarinet integrate
```

## Understanding Test Accounts

In devnet, you have these accounts (from settings/Devnet.toml):
- **deployer**: Contract owner, 100M STX
- **wallet_1**: Test user, 100M STX
- **wallet_2**: Test user, 100M STX
- **wallet_3**: Test user, 100M STX

## Troubleshooting

### "Contract not found" error
**Solution**: Make sure you're in the flashstack directory:
```bash
cd C:\Users\mattg\flashstack
clarinet check
```

### Tests failing
**Solution**: Clear cache and retry:
```bash
rm -rf .cache
clarinet test
```

### "Cannot read PoX state"
**Solution**: This is normal in tests. The `get-stx-locked` function returns a hardcoded value for testing. In production, it will read from PoX-4.

## Ready for Testnet?

See [DEPLOYMENT.md](DEPLOYMENT.md) for instructions on deploying to Stacks testnet.

## Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Review contract code in `contracts/` directory
- Look at test examples in `tests/` directory

---

**Happy Flash Minting!** ⚡
