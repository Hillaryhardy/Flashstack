# FlashStack Testnet Deployment Script
# Run this from the flashstack directory

Write-Host "🚀 FlashStack Testnet Deployment" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check we're in the right directory
if (-not (Test-Path "Clarinet.toml")) {
    Write-Host "❌ Error: Clarinet.toml not found!" -ForegroundColor Red
    Write-Host "Please run this script from the flashstack directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Found Clarinet.toml" -ForegroundColor Green

# Step 2: Check Clarinet installation
Write-Host ""
Write-Host "Checking Clarinet installation..." -ForegroundColor Yellow
try {
    $clarinet_version = clarinet --version
    Write-Host "✓ Clarinet installed: $clarinet_version" -ForegroundColor Green
} catch {
    Write-Host "❌ Clarinet not found! Please install Clarinet first." -ForegroundColor Red
    Write-Host "Visit: https://github.com/hirosystems/clarinet" -ForegroundColor Yellow
    exit 1
}

# Step 3: Check all contracts compile
Write-Host ""
Write-Host "Checking all contracts compile..." -ForegroundColor Yellow
$check_result = clarinet check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ All contracts compile successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Contract compilation failed:" -ForegroundColor Red
    Write-Host $check_result -ForegroundColor Red
    exit 1
}

# Step 4: Generate deployment plan
Write-Host ""
Write-Host "Generating testnet deployment plan..." -ForegroundColor Yellow
$deploy_plan = clarinet deployments generate --testnet --medium-cost 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Deployment plan generated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Plan location: deployments/default.testnet-plan.yaml" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to generate deployment plan:" -ForegroundColor Red
    Write-Host $deploy_plan -ForegroundColor Red
    exit 1
}

# Step 5: Show deployment plan
Write-Host ""
Write-Host "📋 Deployment Plan Summary" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
if (Test-Path "deployments/default.testnet-plan.yaml") {
    Get-Content "deployments/default.testnet-plan.yaml" | Select-Object -First 30
} else {
    Write-Host "⚠️  Deployment plan file not found" -ForegroundColor Yellow
}

# Step 6: Pre-deployment checklist
Write-Host ""
Write-Host "📝 Pre-Deployment Checklist" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Before deploying, please ensure:" -ForegroundColor Yellow
Write-Host "  1. ✓ You have testnet STX in your wallet" -ForegroundColor White
Write-Host "     Get testnet STX: https://explorer.hiro.so/sandbox/faucet?chain=testnet" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. ✓ You have reviewed the deployment plan above" -ForegroundColor White
Write-Host ""
Write-Host "  3. ✓ You are ready to deploy all 11 contracts:" -ForegroundColor White
Write-Host "     - flash-receiver-trait" -ForegroundColor Gray
Write-Host "     - sbtc-token" -ForegroundColor Gray
Write-Host "     - flashstack-core" -ForegroundColor Gray
Write-Host "     - test-receiver" -ForegroundColor Gray
Write-Host "     - example-arbitrage-receiver" -ForegroundColor Gray
Write-Host "     - liquidation-receiver" -ForegroundColor Gray
Write-Host "     - leverage-loop-receiver" -ForegroundColor Gray
Write-Host "     - yield-optimization-receiver" -ForegroundColor Gray
Write-Host "     - collateral-swap-receiver" -ForegroundColor Gray
Write-Host "     - dex-aggregator-receiver" -ForegroundColor Gray
Write-Host "     - multidex-arbitrage-receiver" -ForegroundColor Gray
Write-Host ""

# Step 7: Prompt for deployment
Write-Host "🚀 Ready to Deploy to Testnet" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""
$deploy = Read-Host "Do you want to proceed with deployment? (yes/no)"

if ($deploy -eq "yes") {
    Write-Host ""
    Write-Host "🚀 Deploying to testnet..." -ForegroundColor Cyan
    Write-Host "This may take several minutes..." -ForegroundColor Yellow
    Write-Host ""
    
    # Deploy
    clarinet deployments apply -p deployments/default.testnet-plan.yaml
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 Deployment Successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Next Steps:" -ForegroundColor Cyan
        Write-Host "1. Save the contract addresses shown above" -ForegroundColor White
        Write-Host "2. Update TESTNET_DEPLOYMENT.md with contract addresses" -ForegroundColor White
        Write-Host "3. Run post-deployment setup (see post-deploy.ps1)" -ForegroundColor White
        Write-Host "4. Test first flash mint on testnet" -ForegroundColor White
        Write-Host ""
        Write-Host "📄 Deployment details saved to: deployments/testnet-deployment-$(Get-Date -Format 'yyyy-MM-dd-HH-mm').log" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "❌ Deployment failed!" -ForegroundColor Red
        Write-Host "Check the error messages above for details" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "⏸️  Deployment cancelled" -ForegroundColor Yellow
    Write-Host "You can run this script again when ready" -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "✅ Deployment script complete!" -ForegroundColor Green
