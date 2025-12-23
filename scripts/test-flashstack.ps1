# FlashStack Test & Verification Script

Write-Host "🚀 FlashStack - Testing & Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check we're in the right directory
Write-Host "📁 Checking directory..." -ForegroundColor Yellow
if (!(Test-Path "Clarinet.toml")) {
    Write-Host "❌ Error: Clarinet.toml not found!" -ForegroundColor Red
    Write-Host "Please run this from the flashstack directory:" -ForegroundColor Red
    Write-Host "  cd C:\Users\mattg\flashstack" -ForegroundColor Yellow
    Write-Host "  .\test-flashstack.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ In correct directory`n" -ForegroundColor Green

# Step 2: Check Clarinet version
Write-Host "🔍 Checking Clarinet version..." -ForegroundColor Yellow
$clarinetVersion = clarinet --version
Write-Host "✅ $clarinetVersion`n" -ForegroundColor Green

# Step 3: Check contracts
Write-Host "📝 Checking contracts..." -ForegroundColor Yellow
$checkOutput = clarinet check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All contracts valid!" -ForegroundColor Green
    
    # Count warnings
    $warnings = ($checkOutput | Select-String "warning:").Count
    if ($warnings -gt 0) {
        Write-Host "⚠️  $warnings warnings (safe to ignore for now)`n" -ForegroundColor Yellow
    } else {
        Write-Host "✅ No warnings!`n" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Contract check failed!" -ForegroundColor Red
    Write-Host $checkOutput
    exit 1
}

# Step 4: Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
if (!(Test-Path "node_modules")) {
    npm install --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dependencies installed`n" -ForegroundColor Green
    } else {
        Write-Host "❌ npm install failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Dependencies already installed`n" -ForegroundColor Green
}

# Step 5: Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
npm test
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ All tests passed!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Some tests failed!" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🎉 FlashStack is ready!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Try console: clarinet console" -ForegroundColor White
Write-Host "2. Read docs: README.md" -ForegroundColor White
Write-Host "3. Deploy testnet: see DEPLOYMENT.md" -ForegroundColor White
Write-Host "4. Submit grant: see GRANT_APPLICATION.md`n" -ForegroundColor White
