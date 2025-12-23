$files = @(
    "C:\Users\mattg\flashstack\contracts\dex-aggregator-receiver.clar",
    "C:\Users\mattg\flashstack\contracts\yield-optimization-receiver.clar",
    "C:\Users\mattg\flashstack\contracts\collateral-swap-receiver.clar"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $content = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($file, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Fixed: $file"
}

Write-Host "All files converted to Unix line endings"
