$databasePath = ".\Database\CheckISO.json"

$sumUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"

try {
    $wc = New-Object System.Net.WebClient
    $content = $wc.DownloadString($sumUrl)
}
catch {
    Write-Warning "Impossible de télécharger : $sumUrl"
    return
}

$result = $content -split "`r?`n" | ForEach-Object {

    $line = $_.Trim()

    if ($line -match '^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>debian(?:-[a-z]+)?-(?<Version>\d+\.\d+\.\d+)-amd64-netinst\.iso)$') {

        [PSCustomObject]@{
            Name       = $Matches.Name
            OS         = "Debian"
            Version    = $Matches.Version
            SHA256     = $Matches.Hash.ToLower()
            TrustLevel = "Official"
            #Source     = $sumUrl
            #Updated    = Get-Date
        }
    }
}

# Lecture ancienne base
if (Test-Path $databasePath) {
    $database = Get-Content $databasePath -Raw | ConvertFrom-Json
}
else {
    $database = @()
}

# Fusion
$database = @($database) + @($result)

$unique = $database | Sort-Object SHA256 -Unique

# Sauvegarde
$unique | ConvertTo-Json -Depth 5 | Set-Content $databasePath -Encoding UTF8

Write-Host "Base mise à jour : $($result.Count) entrées ajoutées"
