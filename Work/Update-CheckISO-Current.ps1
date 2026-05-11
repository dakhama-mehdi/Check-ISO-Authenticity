$databasePath = ".\Database\Update-Data.json"

# Chek New Kali
$sumUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"

try {
    $wc = New-Object System.Net.WebClient
    $content = $wc.DownloadString($sumUrl)
}
catch {
    Write-Warning "Impossible de télécharger : $sumUrl"
    return
}

$resultKali = $content -split "`r?`n" | ForEach-Object {

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

#Check Update Ubunutu
$baseUrl = "https://releases.ubuntu.com/releases/"

$root = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing

$dirs = $root.Links.href | Where-Object {
    $_ -match '^\d+\.\d+(\.\d+)?/$'
} | Sort-Object -Unique

$resultsUbuntu = foreach ($dir in $dirs) {

    $version = $dir.TrimEnd("/")
    $sumUrl  = "$baseUrl$dir`SHA256SUMS"

    Write-Host $sumUrl

    $wc = New-Object System.Net.WebClient
    $content = $wc.DownloadString($sumUrl)

    if (-not $content) {
        continue
    }

    $content -split "`n" | ForEach-Object {

    if ($_ -match '^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>.+\.iso)$') {
        [PSCustomObject]@{
            Name       = $matches.Name.Trim()
            OS         = "Ubuntu"
            #Version    = "12.04.1"
            SHA256     = $matches.Hash.ToLower()
            TrustLevel = "Official"
        }
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
$database = @($database) + @($resultKali) + @($resultsUbuntu)

$unique = $database | Sort-Object SHA256 -Unique

# Sauvegarde
$unique | ConvertTo-Json -Depth 5 | Set-Content $databasePath -Encoding UTF8

Write-Host "Base mise à jour : $($result.Count) entrées ajoutées"
