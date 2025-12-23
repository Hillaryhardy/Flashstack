# Fix FlashStack Contracts - Remove Old Duplicates

Write-Host "Removing old duplicate receivers with errors..." -ForegroundColor Yellow

# Remove old broken versions
$oldFiles = @(
    "C:\Users\mattg\flashstack\contracts\yield-optimizer-receiver.clar",
    "C:\Users\mattg\flashstack\contracts\liquidation-bot-receiver.clar"
)

foreach ($file in $oldFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        $fileName = Split-Path $file -Leaf
        Write-Host "Removed: $fileName" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Testing compilation..." -ForegroundColor Cyan
clarinet check

Write-Host ""
Write-Host "Done! Old problematic files removed." -ForegroundColor Green
