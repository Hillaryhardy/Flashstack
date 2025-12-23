# FlashStack Testnet Deployment Guide

## Prerequisites

- [ ] Clarinet 3.5.0+ installed
- [ ] Testnet STX wallet with funds
- [ ] All contracts compile successfully (`clarinet check`)

## Deployment Steps

### 1. Get Testnet STX

Visit the Stacks testnet faucet:
**https://explorer.hiro.so/sandbox/faucet?chain=testnet**

Request testnet STX to your deployment address.

### 2. Generate Deployment Plan

```bash
cd C:\Users\mattg\flashstack
clarinet deployments generate --testnet
```

This creates `deployments/default.testnet-plan.yaml`

### 3. Review Deployment Plan

Check the generated plan:
```bash
cat deployments/default.testnet-plan.yaml
```

Verify:
- All 5 contracts are included
- Deployment order is correct
- Network is set to testnet

### 4. Deploy to Testnet

```bash
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

This will:
1. Deploy flash-receiver-trait
2. Deploy sbtc-token
3. Deploy flashstack-core  
4. Deploy example-arbitrage-receiver
5. Deploy test-receiver
6. Deploy simple-receiver

### 5. Verify Deployment

After deployment, you'll see contract addresses. Save them!

Example output:
```
✓ flash-receiver-trait deployed: ST1ABCD...XYZ.flash-receiver-trait
✓ sbtc-token deployed: ST1ABCD...XYZ.sbtc-token
✓ flashstack-core deployed: ST1ABCD...XYZ.flashstack-core
```

### 6. Post-Deployment Setup

Set the flash minter authorization:

```clarity
;; Connect to testnet via Clarinet or Stacks Explorer
(contract-call? .sbtc-token set-flash-minter .flashstack-core)
```

### 7. Test Flash Mint on Testnet

```clarity
;; Execute first testnet flash mint
(contract-call? .flashstack-core flash-mint u1000000000 .example-arbitrage-receiver)

;; Check stats
(contract-call? .flashstack-core get-stats)
```

## Contract Addresses (Update After Deployment)

### Testnet Contracts

| Contract | Address | Explorer |
|----------|---------|----------|
| flash-receiver-trait | `[UPDATE]` | [View](https://explorer.hiro.so/txid/[TX]?chain=testnet) |
| sbtc-token | `[UPDATE]` | [View](https://explorer.hiro.so/txid/[TX]?chain=testnet) |
| flashstack-core | `[UPDATE]` | [View](https://explorer.hiro.so/txid/[TX]?chain=testnet) |
| example-arbitrage-receiver | `[UPDATE]` | [View](https://explorer.hiro.so/txid/[TX]?chain=testnet) |
| test-receiver | `[UPDATE]` | [View](https://explorer.hiro.so/txid/[TX]?chain=testnet) |

## Verification Checklist

After deployment:

- [ ] All contracts deployed successfully
- [ ] Contract addresses saved
- [ ] Explorer links work
- [ ] Set flash minter authorization
- [ ] Execute test flash mint
- [ ] Verify stats update correctly
- [ ] Check fee collection works
- [ ] Test pause/unpause functions
- [ ] Document any issues

## Troubleshooting

### Deployment Fails

**Issue**: Insufficient STX balance
**Solution**: Get more testnet STX from faucet

**Issue**: Contract already exists
**Solution**: Use a different deployer address or increment deployment plan version

### Flash Mint Fails

**Issue**: `ERR-NOT-ENOUGH-COLLATERAL (100)`
**Solution**: This is expected on testnet - the collateral check reads from PoX-4. For testing, you can temporarily modify the collateral check or set a test value.

**Issue**: `ERR-CALLBACK-FAILED (103)`
**Solution**: Check receiver contract logic and ensure it returns the correct amount

### Authorization Issues

**Issue**: Token minting fails
**Solution**: Ensure `set-flash-minter` was called after deployment

## Production Considerations

Before mainnet deployment:

1. **Replace Mock Collateral Check**: Integrate real PoX-4 reads
2. **Security Audit**: Get contracts audited
3. **Emergency Multisig**: Set admin to multisig wallet
4. **Fee Optimization**: Analyze competitive fees
5. **Monitor Gas Costs**: Optimize contract efficiency

## Support

- GitHub Issues: https://github.com/[your-username]/flashstack
- Discord: [Your Discord]
- Twitter: @FlashStackBTC

## Next Steps

After successful testnet deployment:

1. [ ] Update README with testnet addresses
2. [ ] Create demo video with testnet transactions
3. [ ] Write deployment announcement
4. [ ] Share on Twitter/Discord
5. [ ] Gather community feedback
6. [ ] Prepare for mainnet launch
