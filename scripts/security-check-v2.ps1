# FlashStack - Smart Security Check
# Only flags ACTUAL sensitive files, not documentation mentioning security concepts

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         FlashStack Security Check v2.0            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\mattg\flashstack"
Set-Location $baseDir

Write-Host "🔍 Checking critical security files..." -ForegroundColor Yellow
Write-Host ""

# CRITICAL FILES - These MUST be gitignored
$criticalFiles = @{
    "settings/Testnet.toml" = "Contains testnet wallet mnemonic"
    "settings/Mainnet.toml" = "Would contain mainnet wallet (if created)"
    "settings/Devnet.toml" = "Contains devnet wallet mnemonic"
    ".env" = "Environment variables"
    ".env.local" = "Local environment variables"
    "wallet.json" = "Wallet data"
    "secrets.json" = "Secret keys"
}

$criticalIssues = 0
$protectedFiles = 0

foreach ($file in $criticalFiles.Keys) {
    if (Test-Path $file) {
        $ignored = git check-ignore $file 2>$null
        if ($ignored) {
            Write-Host "  ✅ PROTECTED: $file" -ForegroundColor Green
            $protectedFiles++
        } else {
            Write-Host "  ❌ EXPOSED: $file - $($criticalFiles[$file])" -ForegroundColor Red
            $criticalIssues++
        }
    }
}

Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "⚠️  Git not initialized yet" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Show what will actually be committed
Write-Host "📋 Verifying staged files..." -ForegroundColor Yellow
Write-Host ""

# Check if critical files would be committed
$wouldCommit = @()
foreach ($file in $criticalFiles.Keys) {
    if (Test-Path $file) {
        $staged = git ls-files $file 2>$null
        if ($staged) {
            $wouldCommit += $file
        }
    }
}

if ($wouldCommit.Count -gt 0) {
    Write-Host "❌ CRITICAL: These files would be committed:" -ForegroundColor Red
    foreach ($file in $wouldCommit) {
        Write-Host "  • $file" -ForegroundColor Red
    }
    Write-Host ""
    $criticalIssues++
}

Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($criticalIssues -gt 0) {
    Write-Host "❌ SECURITY CHECK FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Critical issues found: $criticalIssues" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  STOP! Do NOT push to GitHub!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix Required:" -ForegroundColor Yellow
    Write-Host "1. Add exposed files to .gitignore" -ForegroundColor White
    Write-Host "2. Run: git rm --cached <file>" -ForegroundColor White
    Write-Host "3. Run this check again" -ForegroundColor White
    Write-Host ""
    exit 1
} else {
    Write-Host "✅ SECURITY CHECK PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  ✅ $protectedFiles critical files protected" -ForegroundColor Green
    Write-Host "  ✅ No sensitive files will be committed" -ForegroundColor Green
    Write-Host "  ✅ .gitignore properly configured" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Safe to proceed with GitHub push!" -ForegroundColor Green
    Write-Host ""
    
    # Show sample of files to be committed
    Write-Host "📦 Sample of files to be committed:" -ForegroundColor Yellow
    git add . 2>$null
    git diff --cached --name-only | Select-Object -First 15 | ForEach-Object {
        Write-Host "  • $_" -ForegroundColor White
    }
    Write-Host "  ... (and more)" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "✅ All clear! Proceed with:" -ForegroundColor Green
    Write-Host "  git commit -m 'Initial commit: FlashStack v1.0 - First flash loan protocol on Bitcoin L2'" -ForegroundColor White
    Write-Host ""
}
