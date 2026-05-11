New-Item -ItemType Directory -Path ".\Database" -Force | Out-Null

$data = @(
    [PSCustomObject]@{
        Name       = "test.iso"
        OS         = "Test"
        Version    = "1.0"
        SHA256     = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        TrustLevel = "Test"
    }
)

$data |
ConvertTo-Json -Depth 4 |
Set-Content ".\Database\CheckISO.json" -Encoding utf8
