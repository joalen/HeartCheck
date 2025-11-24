$secrets = Get-Content "secrets-raw.json" | ConvertFrom-Json

$flatJson = @{}
foreach ($secret in $secrets) {
    $flatJson[$secret.key] = $secret.value
}

$flatJson | ConvertTo-Json | Out-File "secrets.json" -Encoding utf8
Write-Host "Converted secrets to Flutter format!" -ForegroundColor Green