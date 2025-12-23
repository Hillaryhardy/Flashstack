# FlashStack Repository Cleanup Script
# This script organizes files into proper directories for a clean GitHub repository

Write-Host "🧹 FlashStack Repository Cleanup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\mattg\flashstack"
Set-Location $baseDir

Write-Host "📁 Moving PowerShell scripts to /scripts..." -ForegroundColor Yellow

# Move PowerShell scripts
$psFiles = @(
    "deploy-testnet.ps1",
    "fix-all-mocks.ps1",
    "fix-contracts.ps1",
    "fix-line-endings.ps1",
    "post-deploy.ps1",
    "quick-check.ps1",
    "save-addresses.ps1",
    "test-flashstack.ps1"
)

foreach ($file in $psFiles) {
    if (Test-Path $file) {
        Move-Item $file "scripts\" -Force
        Write-Host "  ✅ Moved $file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $file not found" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "📁 Moving test Clarity scripts to /scripts..." -ForegroundColor Yellow

# Move test .clar scripts
$clarTestFiles = @(
    "admin-tests-quick.clar",
    "admin-tests.clar",
    "advanced-receiver-tests.clar",
    "quick-test-script.clar"
)

foreach ($file in $clarTestFiles) {
    if (Test-Path $file) {
        Move-Item $file "scripts\" -Force
        Write-Host "  ✅ Moved $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📁 Moving archive/history files to /docs/archive..." -ForegroundColor Yellow

# Move archive files
$archiveFiles = @(
    "ACHIEVEMENT_SUMMARY.md",
    "ADMIN_TEST_RESULTS.md",
    "ADVANCED_RECEIVER_FIXES.md",
    "ANNOUNCEMENT_PACKAGE_SUMMARY.md",
    "ANNOUNCEMENT_TEMPLATES.md",
    "BUG_FIXES_SUMMARY.md",
    "COMPLETE_SUCCESS.md",
    "COMPLETE_TEST_RESULTS.md",
    "COMPREHENSIVE_TESTS.md",
    "DEPLOYMENT_CHECKLIST.md",
    "DEPLOY_NOW.md",
    "DIRECT_TEST_LINKS.md",
    "FEE_MECHANISM.md",
    "FINAL_TEST_RESULTS.md",
    "KB-TESTING-SESSION-DEC7.md",
    "QUICK_TEST_GUIDE.md",
    "RECEIVER_TESTING_GUIDE.md",
    "SUCCESS.md",
    "SUPER_QUICK_TESTS.md",
    "TESTING_PROGRESS.md",
    "TESTING_SUMMARY.md",
    "TESTNET_CONTRACTS.md",
    "TESTNET_DEPLOYMENT.md",
    "TESTNET_SETUP.md",
    "TESTNET_SUCCESS.md",
    "TEST_RESULTS.md",
    "VERIFICATION.md"
)

foreach ($file in $archiveFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs\archive\" -Force
        Write-Host "  ✅ Moved $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📁 Moving blog content to /docs/blog..." -ForegroundColor Yellow

if (Test-Path "TECHNICAL_BLOG_POST.md") {
    Move-Item "TECHNICAL_BLOG_POST.md" "docs\blog\" -Force
    Write-Host "  ✅ Moved TECHNICAL_BLOG_POST.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "📁 Moving marketing content to /docs/06-community/marketing..." -ForegroundColor Yellow

$marketingFiles = @(
    "SOCIAL_MEDIA_POSTS.md"
)

foreach ($file in $marketingFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs\06-community\marketing\" -Force
        Write-Host "  ✅ Moved $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📁 Moving grant application to /docs/03-grants..." -ForegroundColor Yellow

if (Test-Path "GRANT_APPLICATION.md") {
    Move-Item "GRANT_APPLICATION.md" "docs\03-grants\" -Force
    Write-Host "  ✅ Moved GRANT_APPLICATION.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "📁 Moving developer docs to /docs/02-technical..." -ForegroundColor Yellow

if (Test-Path "DEVELOPER_DOCUMENTATION.md") {
    Move-Item "DEVELOPER_DOCUMENTATION.md" "docs\02-technical\" -Force
    Write-Host "  ✅ Moved DEVELOPER_DOCUMENTATION.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "📁 Keeping these in root (essential files):" -ForegroundColor Yellow
Write-Host "  ✅ README.md" -ForegroundColor Green
Write-Host "  ✅ LICENSE" -ForegroundColor Green
Write-Host "  ✅ CHANGELOG.md" -ForegroundColor Green
Write-Host "  ✅ CONTRIBUTING.md" -ForegroundColor Green
Write-Host "  ✅ .gitignore" -ForegroundColor Green
Write-Host "  ✅ START_HERE.md" -ForegroundColor Green
Write-Host "  ✅ QUICKSTART.md" -ForegroundColor Green
Write-Host "  ✅ PROJECT_SUMMARY.md" -ForegroundColor Green
Write-Host "  ✅ DEPLOYMENT.md" -ForegroundColor Green
Write-Host "  ✅ Clarinet.toml" -ForegroundColor Green
Write-Host "  ✅ package.json" -ForegroundColor Green
Write-Host "  ✅ vitest.config.js" -ForegroundColor Green
Write-Host "  ✅ tsconfig.json" -ForegroundColor Green

Write-Host ""
Write-Host "✨ Cleanup complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 New structure:" -ForegroundColor Yellow
Write-Host ""
Write-Host "flashstack/" -ForegroundColor White
Write-Host "├── .github/           (workflows, templates)" -ForegroundColor DarkGray
Write-Host "├── contracts/         (smart contracts)" -ForegroundColor DarkGray
Write-Host "├── docs/              (documentation)" -ForegroundColor DarkGray
Write-Host "│   ├── archive/       (test results, summaries)" -ForegroundColor DarkGray
Write-Host "│   ├── blog/          (blog posts)" -ForegroundColor DarkGray
Write-Host "│   └── 03-grants/     (grant applications)" -ForegroundColor DarkGray
Write-Host "├── scripts/           (deployment & test scripts)" -ForegroundColor DarkGray
Write-Host "├── tests/             (test files)" -ForegroundColor DarkGray
Write-Host "├── README.md" -ForegroundColor DarkGray
Write-Host "├── CONTRIBUTING.md" -ForegroundColor DarkGray
Write-Host "└── ... (other essentials)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "🚀 Ready to:" -ForegroundColor Green
Write-Host "  1. Review the changes"
Write-Host "  2. Run: git init"
Write-Host "  3. Run: git add ."
Write-Host "  4. Run: git commit -m 'Initial commit: FlashStack v1.0'"
Write-Host "  5. Create GitHub repo and push!"
Write-Host ""
