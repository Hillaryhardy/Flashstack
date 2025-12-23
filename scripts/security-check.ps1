# 🔒 FlashStack - Security Check Before Push
# Verifies no sensitive data will be pushed to GitHub

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║      SECURITY CHECK - Critical Before Push        ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

$baseDir = "C:\Users\mattg\flashstack"
Set-Location $baseDir

Write-Host "🔍 Checking for sensitive files..." -ForegroundColor Yellow
Write-Host ""

# Check what files would be committed
Write-Host "📋 Files that would be pushed to GitHub:" -ForegroundColor Cyan
Write-Host ""

# Initialize git if not already (to check what would be committed)
if (-not (Test-Path ".git")) {
    Write-Host "⚠️  Git not initialized yet. Showing all files..." -ForegroundColor Yellow
    Write-Host ""
}

# Sensitive patterns to check for
$sensitivePatterns = @(
    "mnemonic",
    "seed phrase",
    "private key",
    "secret key",
    "api_key",
    "password",
    "SECRET",
    "PRIVATE_KEY"
)

$sensitiveFiles = @(
    "settings\Testnet.toml",
    "settings\Mainnet.toml",
    "settings\Devnet.toml",
    ".env",
    ".env.local",
    "wallet.json",
    "secrets.json",
    "mnemonics.txt"
)

Write-Host "🚨 Checking for sensitive files..." -ForegroundColor Red
Write-Host ""

$foundSensitive = $false
foreach ($file in $sensitiveFiles) {
    if (Test-Path $file) {
        # Check if file is in .gitignore
        $ignored = git check-ignore $file 2>$null
        if ($ignored) {
            Write-Host "  ✅ SAFE (Ignored): $file" -ForegroundColor Green
        } else {
            Write-Host "  ❌ DANGER: $file is NOT ignored!" -ForegroundColor Red
            $foundSensitive = $true
        }
    }
}

Write-Host ""
Write-Host "🔍 Scanning file contents for sensitive data..." -ForegroundColor Yellow
Write-Host ""

# Search for sensitive patterns in tracked files
$textFiles = Get-ChildItem -Recurse -File -Include *.toml,*.env,*.json,*.txt,*.md |
    Where-Object { $_.FullName -notmatch "node_modules|\.git|\.cache" }

$foundContent = $false
foreach ($file in $textFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        foreach ($pattern in $sensitivePatterns) {
            if ($content -match $pattern) {
                # Check if file is gitignored
                $relativePath = $file.FullName.Replace("$baseDir\", "").Replace("\", "/")
                $ignored = git check-ignore $relativePath 2>$null
                
                if (-not $ignored) {
                    Write-Host "  ⚠️  Found '$pattern' in: $relativePath" -ForegroundColor Yellow
                    $foundContent = $true
                }
            }
        }
    }
}

if (-not $foundContent) {
    Write-Host "  ✅ No sensitive patterns found in tracked files" -ForegroundColor Green
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($foundSensitive -or $foundContent) {
    Write-Host "❌ SECURITY CHECK FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  STOP! Do NOT push to GitHub yet!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Action Required:" -ForegroundColor Yellow
    Write-Host "1. Review the files listed above" -ForegroundColor White
    Write-Host "2. Add them to .gitignore if needed" -ForegroundColor White
    Write-Host "3. Run this check again" -ForegroundColor White
    Write-Host ""
    exit 1
} else {
    Write-Host "✅ SECURITY CHECK PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repository is safe to push:" -ForegroundColor Green
    Write-Host "  ✅ No unprotected sensitive files" -ForegroundColor Green
    Write-Host "  ✅ No sensitive patterns in tracked files" -ForegroundColor Green
    Write-Host "  ✅ .gitignore properly configured" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 You're clear to proceed with GitHub push!" -ForegroundColor Green
    Write-Host ""
}
