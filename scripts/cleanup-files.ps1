# FlashStack - Repository Cleanup Script
# Removes internal notes and documentation before GitHub push

Write-Host "🧹 FlashStack Repository Cleanup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\mattg\flashstack"
Set-Location $baseDir

Write-Host "📁 Current directory: $baseDir" -ForegroundColor Yellow
Write-Host ""

# Files to delete (internal notes)
$filesToDelete = @(
    "FIXES_COMPLETE_DEC_2025.md",
    "README_UPGRADE_COMPLETE.md",
    "SETUP_COMPLETE_SUMMARY.md",
    "START_HERE_NOW.txt",
    "TESTS_FIXED.md",
    "QUICK_REFERENCE.md",
    "GITHUB_SETUP_GUIDE.md",
    "CLEANUP_PLAN.md"  # Delete this file too after running
)

Write-Host "🗑️  Deleting internal notes and documentation..." -ForegroundColor Yellow
Write-Host ""

$deletedCount = 0
foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  ✅ Deleted: $file" -ForegroundColor Green
        $deletedCount++
    } else {
        Write-Host "  ⚠️  Not found (already deleted?): $file" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  Deleted: $deletedCount files" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Remaining files in root:" -ForegroundColor Yellow
Get-ChildItem -File | Select-Object Name | Format-Table -AutoSize

Write-Host ""
Write-Host "✨ Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Your repository now has:" -ForegroundColor Cyan
Write-Host "  ✅ Clean root directory" -ForegroundColor Green
Write-Host "  ✅ Only essential documentation" -ForegroundColor Green
Write-Host "  ✅ Professional appearance" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the files listed above"
Write-Host "  2. Run: .\scripts\reorganize-repo.ps1"
Write-Host "  3. Run: git init"
Write-Host "  4. Run: git add ."
Write-Host "  5. Run: git commit -m 'Initial commit: FlashStack v1.0'"
Write-Host "  6. Push to GitHub!"
Write-Host ""
