# FlashStack Deployment Guide

Complete guide for deploying FlashStack to Stacks testnet and mainnet.

## Pre-Deployment Checklist

- [ ] All tests passing (`clarinet test`)
- [ ] Contracts compile without errors (`clarinet check`)
- [ ] Security review completed
- [ ] Testnet STX available for deployment
- [ ] Wallet configured (Hiro, Leather, or Xverse)

## Testnet Deployment

### 1. Prepare Deployment Account

You'll need testnet STX for deployment fees (~0.1 STX per contract).

**Get Testnet STX:**
- Faucet: https://explorer.hiro.so/sandbox/faucet?chain=testnet
- Request: ~5 STX for comfortable deployment

### 2. Configure Deployment Settings

Edit `settings/Testnet.toml` (if not exists, create it):

```toml
[network]
name = "testnet"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "YOUR_MNEMONIC_HERE"  # NEVER commit this!
```

**⚠️ SECURITY WARNING**: Never commit your mnemonic to Git!
Add `settings/Testnet.toml` to `.gitignore` if it contains your mnemonic.

### 3. Deploy Contracts

Deploy in this specific order (dependencies):

```bash
# 1. Deploy trait first
clarinet deployments generate --testnet

# 2. Review deployment plan
cat deployments/default.testnet-plan.yaml

# 3. Execute deployment
clarinet deployments apply --testnet
```

Expected deployment order:
1. `flash-receiver-trait.clar`
2. `sbtc-token.clar`
3. `flashstack-core.clar`
4. `example-arbitrage-receiver.clar`

### 4. Verify Deployment

```bash
# Check contracts on explorer
# Visit: https://explorer.hiro.so/txid/YOUR_TX_ID?chain=testnet

# Or use Clarinet
clarinet deployments check --testnet
```

### 5. Initialize Protocol

After deployment, initialize the protocol:

```bash
# Start console connected to testnet
clarinet console --testnet

# Set FlashStack as flash minter
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
```

## Testnet Testing

### Basic Functionality Test

```clarity
;; 1. Check protocol stats
(contract-call? .flashstack-core get-stats)

;; 2. Calculate fee for test amount
(contract-call? .flashstack-core calculate-fee u1000000000)

;; 3. Try a test flash mint
(contract-call? .flashstack-core flash-mint 
  u100000000  ;; 1 sBTC
  .example-arbitrage-receiver)
```

### Integration Testing

Test with real testnet conditions:
- Try with actual stacked STX
- Test with various amounts
- Verify fee collection
- Test error conditions

## Mainnet Deployment

### Pre-Mainnet Checklist

- [ ] Comprehensive testnet testing (2+ weeks)
- [ ] Security audit completed
- [ ] Bug bounty program considered
- [ ] Emergency procedures documented
- [ ] Multi-sig admin wallet setup (recommended)
- [ ] Community announcement prepared

### 1. Mainnet Preparation

**Get Mainnet STX:**
- Need ~10 STX for deployment costs
- Extra STX for initial protocol operations

**Security Measures:**
- Use hardware wallet for mainnet deployment
- Set up multi-sig for admin functions
- Document emergency response plan

### 2. Deploy to Mainnet

```bash
# Generate mainnet deployment
clarinet deployments generate --mainnet

# CAREFULLY review the plan
cat deployments/default.mainnet-plan.yaml

# Deploy (no going back!)
clarinet deployments apply --mainnet
```

### 3. Post-Deployment Setup

```bash
# Initialize protocol
# Connect to mainnet
clarinet console --mainnet

# 1. Set flash minter
(contract-call? .sbtc-token set-flash-minter .flashstack-core)

# 2. Verify initial state
(contract-call? .flashstack-core get-stats)
(contract-call? .flashstack-core get-fee-basis-points)

# 3. Transfer admin to multi-sig (recommended)
(contract-call? .flashstack-core set-admin 'MULTI_SIG_ADDRESS)
```

## Contract Addresses

### Testnet
After deployment, record your contract addresses here:

```
flash-receiver-trait: ST...
sbtc-token: ST...
flashstack-core: ST...
example-arbitrage-receiver: ST...
```

### Mainnet
After deployment, record mainnet addresses:

```
flash-receiver-trait: SP...
sbtc-token: SP...
flashstack-core: SP...
```

## Monitoring

### Key Metrics to Track

1. **Volume Metrics**
```clarity
(contract-call? .flashstack-core get-stats)
```

2. **Fee Collection**
```clarity
;; Check sBTC balance of FlashStack contract
(contract-call? .sbtc-token get-balance .flashstack-core)
```

3. **Transaction Count**
Monitor flash mint transactions on explorer

### Setting Up Alerts

- Block explorer notifications for contract interactions
- Discord/Telegram bot for large transactions
- Email alerts for admin actions

## Upgradeability

FlashStack v1 is **non-upgradeable** for security.

For future versions:
1. Deploy new contract versions
2. Migrate users gradually
3. Deprecate old contracts after migration period

## Emergency Procedures

### If Critical Bug Found

1. **Immediate Response**
   - Announce on all channels
   - Contact large users directly
   - Document the issue

2. **If Admin Control Possible**
   ```clarity
   ;; Increase fees to maximum to discourage use
   (contract-call? .flashstack-core set-fee u100)  ;; 1% fee
   ```

3. **Deploy Fixed Version**
   - Deploy new contracts
   - Migrate users
   - Provide migration tools

### Security Contacts

- **Security Email**: security@flashstack.xyz (setup before mainnet)
- **Emergency Multi-sig**: 3-of-5 team members
- **Bug Bounty**: Immunefi (recommended)

## Deployment Costs

### Testnet
- **Per Contract**: ~0.025 STX
- **Total**: ~0.1 STX
- **Testing**: ~1 STX recommended

### Mainnet
- **Per Contract**: ~0.1-0.5 STX (varies with network)
- **Total**: ~2-5 STX
- **Buffer**: Keep 10 STX for initial operations

## Post-Deployment Checklist

- [ ] All contracts deployed successfully
- [ ] Flash minter role assigned
- [ ] Admin transferred to multi-sig (if applicable)
- [ ] Contracts verified on explorer
- [ ] Monitoring tools active
- [ ] Documentation updated with addresses
- [ ] Community announcement posted
- [ ] Integration guides published

## Integration Examples

For developers wanting to integrate FlashStack:

### Basic Integration

```clarity
;; Your receiver contract
(define-public (execute-flash (amount uint) (borrower principal))
  (let ((fee (contract-call? .flashstack-core calculate-fee amount)))
    ;; Your logic here
    
    ;; Always repay
    (try! (contract-call? .sbtc-token transfer 
      (+ amount fee)
      borrower
      .flashstack-core
      none))
    (ok true)
  )
)

;; Call flash mint
(contract-call? .flashstack-core flash-mint 
  u1000000000
  .your-receiver-contract)
```

## Support

For deployment support:
- Discord: [Join FlashStack]
- Docs: https://docs.flashstack.xyz (coming soon)
- Email: support@flashstack.xyz

---

**Deploy carefully. Double-check everything. Test on testnet first!** 🚀
