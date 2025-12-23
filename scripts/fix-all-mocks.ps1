# Fix all mock functions in receivers to use deterministic types

Write-Host "Fixing mock functions in all receiver contracts..." -ForegroundColor Cyan

# Fix multidex-arbitrage-receiver
$content = Get-Content "C:\Users\mattg\flashstack\contracts\multidex-arbitrage-receiver.clar" -Raw
$content = $content -replace '\(define-private \(buy-on-dex-a[^)]*\)\s+[^)]*\(ok \(/ \(\* sbtc-amount u98\) u100\)\)\)', '(define-private (buy-on-dex-a (sbtc-amount uint))
  ;; In production: Call DEX A swap function
  ;; Example: (contract-call? .alex-swap swap-tokens sbtc-token btc-token sbtc-amount min-btc)
  (ok (/ (* sbtc-amount u98) u100)) ;; Simulate 2% slippage
)'
$content = $content -replace '\(ok \(/ \(\* btc-amount u105\) u100\)\)\)\s*\n\)', '(ok (/ (* btc-amount u105) u100))) ;; Simulate selling at 5% premium
)'
Set-Content "C:\Users\mattg\flashstack\contracts\multidex-arbitrage-receiver.clar" $content
Write-Host "Fixed multidex-arbitrage-receiver" -ForegroundColor Green

# Fix yield-optimization-receiver 
$content = Get-Content "C:\Users\mattg\flashstack\contracts\yield-optimization-receiver.clar" -Raw
$content = $content -replace '\(ok true\)', '(ok u0)'
Set-Content "C:\Users\mattg\flashstack\contracts\yield-optimization-receiver.clar" $content
Write-Host "Fixed yield-optimization-receiver" -ForegroundColor Green

# Fix leverage-loop-receiver
$content = Get-Content "C:\Users\mattg\flashstack\contracts\leverage-loop-receiver.clar" -Raw
$content = $content -replace '\(ok true\)', '(ok u0)'
Set-Content "C:\Users\mattg\flashstack\contracts\leverage-loop-receiver.clar" $content
Write-Host "Fixed leverage-loop-receiver" -ForegroundColor Green

Write-Host "`nRunning clarinet check..." -ForegroundColor Cyan
Set-Location "C:\Users\mattg\flashstack"
clarinet check
