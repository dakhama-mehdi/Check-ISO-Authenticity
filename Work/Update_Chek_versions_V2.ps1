
<#

# mirroir :
 https://mirror.math.princeton.edu/pub/fedora-archive/fedora/linux/releases/
 https://mirror.lt.ucsc.edu/almalinux/
 https://vault.almalinux.org/

 Original : 
 https://download.fedoraproject.org/pub/fedora/linux/releases/

#>

function Get-LinuxVersions {

    param(
        [string]$Name,
        [string]$Url,
        [string]$Regex = '^\d+(\.\d+)?/$'
    )

    try {
        
        if ($Name -eq "Debian") {
        $wc = New-Object System.Net.WebClient
        $root = $wc.DownloadString($Url)
        } 
        else {
        $root = Invoke-WebRequest -Uri $url -UseBasicParsing
        }

        if ($name -eq 'Kali') {
        $versions = $root.Links.href | Where-Object {
         $_ -match '^kali-202\d+\.\d+(\.\d+)?/$'
        } | Sort-Object -Unique

        }
        elseif ($name -eq "Ubuntu") {
        $versions = $root.Links.href | Where-Object {
        $_ -match '^\d+\.\d+(\.\d+)?/$'
        } | Sort-Object -Unique    
        }
        elseif ($name -eq "Debian") {
        $versions = $root -split "`r?`n" | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>debian(?:-[a-z]+)?-(?<Version>\d+\.\d+\.\d+)-amd64-netinst\.iso)$') {
        $Matches.Version
        } 
        } | Sort-Object Version -Unique 
        
        } 
        elseif ($Name -eq "Fedora") {

        $versions = $root.Links.href |  Where-Object { $_ -match '^\d+/$' } |
        ForEach-Object { [int]($_.TrimEnd('/')) } |
        Where-Object { $_ -ge 30 }
        }
        elseif ($Name -eq "OpenSuse") {
        $versions = $root.Links.href |
        Where-Object {
        $_ -match '^\./\d+(\.\d+)+/$'
        } |
        ForEach-Object {
        $_ -replace '^\.','' -replace '/$',''
        }
        }
        elseif ($Name -eq "OracleLinux") {
        $versions = $root.Links.href | Where-Object {
        $_ -match 'OracleLinux-(R(?:[8-9]|\d{2,})-U\d+)-Server-x86_64\.checksum$'
        } | Sort-Object -Unique
        }
        else {
        $versions = $root.Links.href | Where-Object {
            $_ -match $Regex
        }  | ForEach-Object {
                $_.TrimEnd('/')
            } | Sort-Object -Unique
        }

        [PSCustomObject]@{
            Name     = $Name
            Url      = $Url
            Versions = @($versions)
        }
        }
    catch {

        [PSCustomObject]@{
            Name     = $Name
            Url      = $Url
            Versions = @()
        }
    }
}
function Get-HashFromVersions {
    param(
        [string]$SourceName,
        [string]$BaseUrl,
        [string[]]$Versions
    )

    $results = @()

    #$SourceName = "Linuxmint"
    #$BaseUrl = "https://mirrors.edge.kernel.org/linuxmint/stable"
    #$Versions = $current.Versions
        
    foreach ($dir in $Versions) {
   
        $version = $dir.TrimEnd("/")

        if     ($SourceName -eq "Ubuntu" -or $SourceName -eq "Kali") {
        $sumUrl  = "$baseUrl$dir`SHA256SUMS"
        }
        elseif ($SourceName -eq "Debian") {
        $sumUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
        }   
        elseif ($SourceName -eq "Linuxmint") {
        $sumUrl  = "$BaseUrl/$dir/sha256sum.txt"
        }
        elseif ($SourceName -eq "OracleLinux") {
        $sumUrl  = "$BaseUrl/$dir"

        $Version = if($dir -match 'OracleLinux-(R\d+-U\d+)-Server'){
         $Matches[1] -replace '-','.' -replace 'R','' -replace 'U',''
        }
        }
        else {
        if ($SourceName -eq "Fedora_Workstation") {
        $isoUrl = "$baseUrl$dir`/Workstation/x86_64/iso/"
        } 
        elseif ($SourceName -eq "Fedora_Server") {
        $isoUrl = "$baseUrl$dir`/Server/x86_64/iso/"
        }
        elseif ($SourceName -eq "FreeBsd") {
        $isoUrl  = "$BaseUrl/$version/"
        }
        else {
        $isoUrl  = "$BaseUrl/$version/isos/x86_64/"
        }
        
        try {
            $page = Invoke-WebRequest -Uri $isoUrl -UseBasicParsing
        }
        catch {
            Write-Warning "Impossible d'acceder  $isoUrl"
            continue
        }
        
        if ($SourceName -eq "FreeBsd") {
        $checkFile = $page.Links.href | Where-Object {
            $_ -match '^CHECKSUM\.SHA256.*amd64$'
            } | Select-Object -First 1
        } 
        else {
        $checkFile = $page.Links.href | Where-Object {
            $_ -like "*CHECKSUM"
        } | Select-Object -First 1
        }

        if (-not $checkFile) {
            Write-Warning "CHECKSUM introuvable pour Rocky $version"
            continue
        }

        $sumUrl = "$isoUrl$checkFile"

        }
        try {
            $content = (New-Object System.Net.WebClient).DownloadString($sumUrl)
        }
        catch {
            Write-Warning "Impossible de telecharger $sumUrl"
            continue
        }

        if (-not $content) {
        continue
        }

        $items = $content -split "`r?`n" | ForEach-Object {

            $line = $_.Trim()

            if ($SourceName -eq "Ubuntu" -or $SourceName -eq "Kali" -or $SourceName -eq "Linuxmint" -or $SourceName -eq "Oraclelinux" ) {
            $pattern = "^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>.+\.iso)$"
            } 
            elseif ($SourceName -eq "Debian") {
            $pattern = "^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>debian(?:-[a-z]+)?-(?<Version>\d+\.\d+\.\d+).+?\.iso)$"
            }
            elseif ($sourceName -eq "Fedora_Workstation" -or $sourceName -eq "Fedora_Server" -or $SourceName -eq "FreeBsd") {
            $pattern = '^SHA256 \((?<Name>.+\.iso)\) = (?<Hash>[a-fA-F0-9]{64})$'
            }
            else {
            $pattern = "^SHA256\s+\((?<Name>$SourceName-.+x86_64.+\.iso)\)\s+=\s+(?<Hash>[a-fA-F0-9]{64})$"
            }

            if ($line -match $pattern) {
                [PSCustomObject]@{
                    Name       = $Matches.Name.Trim()
                    OS         = $SourceName
                    Version    = $version
                    SHA256     = $Matches.Hash.ToLower()
                    TrustLevel = "Official"
                }
            }
        }

        $results += $items
    }

    return ($results | Sort-Object SHA256 -Unique)
}
function Get-HashOpensuse {
        param(
        [string]$SourceName,
        [string]$BaseUrl,
        [string[]]$Versions
        )        
        $resultsdir = @()

        foreach ($dir in $Versions) {

        $version = $dir.TrimEnd("/")

        $checksumFiles = $page = $isoUrl = $null

        $paths = @(
        "offline/",
        "installer/iso/",
        "iso/"
         )

        foreach ($path in $paths){

        $isoUrl = "$BaseUrl$version/$path"

        try{
        $page = Invoke-WebRequest -Uri $isoUrl -UseBasicParsing -ErrorAction SilentlyContinue
        #break
        }
        catch{
        #Write-Warning "error"
        continue
        }
        
        $checksumFiles = $page.Links.href | Where-Object {
        $_ -match 'x86_64.*\.iso\.sha256$' -and
        $_ -notmatch 'pxe|net'
        } |
        ForEach-Object {
        $_ -replace '^\.',''
         }
       
        foreach($checksumFile in $checksumFiles){

        $sumUrl = $isoUrl + $checksumFile

        $content = (New-Object System.Net.WebClient).DownloadString($sumUrl)

        $items = $content -split "`r?`n" | ForEach-Object {

            if($_ -match '^(?<Hash>[a-fA-F0-9]{64})\s+\*?(?<Name>.+\.iso)$'){

                [PSCustomObject]@{
                    Name       = $Matches.Name.Trim()
                    OS         = "openSUSE"
                    Version    = $dir
                    SHA256     = $Matches.Hash.ToLower()
                    TrustLevel = "Official"
                }
            }
        }
         $resultsdir += $items
        }
        }
        }
        
        return ($resultsdir | Sort-Object SHA256 -Unique)
}
function Update-HashIndex {

    param(
        [array]$Items,
        [string]$HashDir = ".\Database\hash"
    )

    if (-not (Test-Path $HashDir)) {
        New-Item -Path $HashDir -ItemType Directory -Force | Out-Null
    }

    $validItems = $Items | Where-Object {
        $_.SHA256 -match '^[a-fA-F0-9]{64}$'
    }

    $groups = $validItems | Group-Object {
        $_.SHA256.Substring(0,1).ToLower()
    }

    foreach ($group in $groups) {

        $filePath = Join-Path $HashDir "$($group.Name).json"

        if (Test-Path $filePath) {
            $existing = @(Get-Content $filePath -Raw | ConvertFrom-Json)
        }
        else {
            $existing = @()
        }

        # sÃ©curitÃ© : virer les anciens objets cassÃ©s avec value/count
        $existing = $existing | Where-Object {
            $_.SHA256 -match '^[a-fA-F0-9]{64}$'
        }

        $newItems = @($group.Group)

        $merged = @($existing + $newItems) |
            Sort-Object SHA256 -Unique

        @($merged) |
            ConvertTo-Json -Depth 5 |
            Out-File $filePath -Encoding utf8 -Force
    }
}


$sources = @(
    @{ Name = "Rocky-Pub"; Url = "https://dl.rockylinux.org/pub/rocky/" },
    @{ Name = "Kali"; Url = "https://old.kali.org/kali-images/" },
    @{ Name = "Ubuntu"; Url = "https://releases.ubuntu.com/releases/" },
    @{ Name = "AlmaLinux"; Url = "https://repo.almalinux.org/almalinux/" },
    @{ Name = "Debian"; Url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS" },
    @{ Name = "Fedora"; Url = "https://download.fedoraproject.org/pub/fedora/linux/releases/" },
    @{ Name = "Linuxmint"; Url = "https://mirrors.edge.kernel.org/linuxmint/stable/" },
    @{ Name = "FreeBsd"; Url = "https://download.freebsd.org/releases/ISO-IMAGES/" },
    @{ Name = "OpenSuse"; Url = "https://download.opensuse.org/distribution/leap/" },
    @{ Name = "Oraclelinux"; Url = "https://linux.oracle.com/security/gpg/archive.html" }
    
)

$current = foreach ($source in $sources) {

        Get-LinuxVersions `
        -Name $source.Name `
        -Url $source.Url
}

$indexPath = ".\Database\index\linux_versions.json"

if (-not (Test-Path $indexPath)) {

    $current | ConvertTo-Json -Depth 10 | Out-File $indexPath -Encoding utf8
    Write-Host "Premier index cree"
    $changes = $current
}

else {

$old = Get-Content $indexPath -Raw | ConvertFrom-Json

$changes = foreach ($item in $current) {

    $oldItem = $old | Where-Object {
        $_.Name -eq $item.Name
    }

    if ($null -eq $oldItem) {

        [PSCustomObject]@{
            Name        = $item.Name
            Status      = "NewSource"
            Versions = @($item.Versions)
        }
        continue
    }

    $newVersions = $item.Versions | Where-Object {
        $_ -notin $oldItem.Versions
    }

    if ($newVersions.Count -gt 0) {

        [PSCustomObject]@{
            Name        = $item.Name
            Status      = "Updated"
            Versions = @($newVersions)
        }
    }
}

$current | ConvertTo-Json -Depth 10 | Out-File $indexPath -Encoding utf8
}

if ($changes) {

$changes

$resultsHash = @()

foreach ($change in $changes) {
    
    switch ($change.Name) {
        "Rocky-Pub" {
            $resultsHash += Get-HashFromVersions `
                -SourceName "Rocky" `
                -BaseUrl "https://dl.rockylinux.org/pub/rocky" `
                -Versions $change.Versions
        }
        "AlmaLinux" {
            $resultsHash += Get-HashFromVersions `
                -SourceName "AlmaLinux" `
                -BaseUrl "https://repo.almalinux.org/almalinux/" `
                -Versions $change.Versions
        }
        "Ubuntu"    {
            $resultsHash += Get-HashFromVersions `
            -SourceName "Ubuntu" `
            -BaseUrl "https://releases.ubuntu.com/releases/" `
            -Versions $change.Versions
        }
        "Kali"      {
            $resultsHash += Get-HashFromVersions `
                -SourceName "Kali" `
                -BaseUrl "https://old.kali.org/kali-images/" `
                -Versions $change.Versions
        }
        "Debian"    {
            $resultsHash += Get-HashFromVersions `
                -SourceName "Debian" `
                -BaseUrl "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS" `
                -Versions $change.Versions
        }
        "Fedora"    {
            $resultsHash += Get-HashFromVersions `
                -SourceName "Fedora_Workstation" `
                -BaseUrl "https://download.fedoraproject.org/pub/fedora/linux/releases/" `
                -Versions $change.Versions

            $resultsHash += Get-HashFromVersions `
                -SourceName "Fedora_Server" `
                -BaseUrl "https://download.fedoraproject.org/pub/fedora/linux/releases/" `
                -Versions $change.Versions
    }
        "Linuxmint"    {
            $resultsHash += Get-HashFromVersions `
                -SourceName "Linuxmint" `
                -BaseUrl "https://mirrors.edge.kernel.org/linuxmint/stable/" `
                -Versions $change.Versions
        }
        "OpenSuse"    {
            $resultsHash += Get-HashOpensuse `
                -SourceName "OpenSuse" `
                -BaseUrl "https://download.opensuse.org/distribution/leap/" `
                -Versions $change.Versions
        }
        "FreeBsd"    {
             $resultsHash += Get-HashFromVersions `
                -SourceName "FreeBsd" `
                -BaseUrl "https://download.freebsd.org/releases/ISO-IMAGES/" `
                -Versions $change.Versions
        }
        "Oraclelinux"    {
             $resultsHash += Get-HashFromVersions `
                -SourceName "Oraclelinux" `
                -BaseUrl "https://linux.oracle.com/security/gpg" `
                -Versions $change.Versions
        }
}
}

if ($resultsHash) {
Update-HashIndex -Items $resultsHash -HashDir ".\Database\hash"
}
}

