# FlashStack Post-Deployment Setup Script
# Run this AFTER successful testnet deployment

Write-Host "⚙️  FlashStack Post-Deployment Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Instructions for post-deployment
Write-Host "📝 Post-Deployment Steps" -ForegroundColor Yellow
Write-Host ""
Write-Host "After deploying to testnet, you need to:" -ForegroundColor White
Write-Host ""
Write-Host "1. Set Flash Minter Authorization" -ForegroundColor Cyan
Write-Host "   This allows flashstack-core to mint/burn tokens" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Test First Flash Mint" -ForegroundColor Cyan
Write-Host "   Verify the protocol works on testnet" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Verify Statistics" -ForegroundColor Cyan
Write-Host "   Check that stats are tracked correctly" -ForegroundColor Gray
Write-Host ""

# Contract addresses placeholder
Write-Host "📋 Contract Addresses" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please update these with your deployed contract addresses:" -ForegroundColor Yellow
Write-Host ""

$trait_address = Read-Host "flash-receiver-trait address"
$token_address = Read-Host "sbtc-token address"
$core_address = Read-Host "flashstack-core address"
$test_receiver = Read-Host "test-receiver address"

Write-Host ""
Write-Host "✓ Addresses saved" -ForegroundColor Green
Write-Host ""

# Generate Clarity commands
Write-Host "📝 Clarity Commands to Run" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy and paste these commands into the Stacks Explorer or Clarinet:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  Set Flash Minter Authorization:" -ForegroundColor Cyan
Write-Host "(contract-call? '$token_address set-flash-minter '$core_address)" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  Test Flash Mint (1M sBTC):" -ForegroundColor Cyan
Write-Host "(contract-call? '$core_address flash-mint u1000000 '$test_receiver)" -ForegroundColor White
Write-Host ""

Write-Host "3️⃣  Check Statistics:" -ForegroundColor Cyan
Write-Host "(contract-call? '$core_address get-stats)" -ForegroundColor White
Write-Host ""

Write-Host "4️⃣  Verify Supply (should be 0):" -ForegroundColor Cyan
Write-Host "(contract-call? '$token_address get-total-supply)" -ForegroundColor White
Write-Host ""

# Save addresses to file
Write-Host "💾 Saving contract addresses..." -ForegroundColor Yellow

$addresses = @"
# FlashStack Testnet Contract Addresses
Deployment Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Core Contracts
- flash-receiver-trait: $trait_address
- sbtc-token: $token_address  
- flashstack-core: $core_address

## Receivers
- test-receiver: $test_receiver

## Explorer Links
- Trait: https://explorer.hiro.so/txid/$trait_address?chain=testnet
- Token: https://explorer.hiro.so/txid/$token_address?chain=testnet
- Core: https://explorer.hiro.so/txid/$core_address?chain=testnet
- Test Receiver: https://explorer.hiro.so/txid/$test_receiver?chain=testnet

## Post-Deployment Commands

### 1. Set Flash Minter
``````clarity
(contract-call? '$token_address set-flash-minter '$core_address)
``````

### 2. Test Flash Mint
``````clarity
(contract-call? '$core_address flash-mint u1000000 '$test_receiver)
``````

### 3. Check Stats
``````clarity
(contract-call? '$core_address get-stats)
``````

### 4. Verify Supply
``````clarity
(contract-call? '$token_address get-total-supply)
``````
"@

$addresses | Out-File -FilePath "testnet-addresses.md" -Encoding UTF8

Write-Host "✓ Contract addresses saved to: testnet-addresses.md" -ForegroundColor Green
Write-Host ""

# Next steps
Write-Host "🚀 Next Steps" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Visit Stacks Explorer:" -ForegroundColor White
Write-Host "   https://explorer.hiro.so/?chain=testnet" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Connect your wallet" -ForegroundColor White
Write-Host ""
Write-Host "3. Run the commands above in the contract call interface" -ForegroundColor White
Write-Host ""
Write-Host "4. Verify each transaction succeeds" -ForegroundColor White
Write-Host ""
Write-Host "5. Share your testnet deployment:" -ForegroundColor White
Write-Host "   - Twitter: 'Just deployed FlashStack to @Stacks testnet!'" -ForegroundColor Gray
Write-Host "   - Discord: Share contract addresses" -ForegroundColor Gray
Write-Host "   - GitHub: Update README with testnet info" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Post-deployment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📖 For more info, see TESTNET_DEPLOYMENT.md" -ForegroundColor Gray
