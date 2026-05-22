
function Convert-HashIndexToOSLibrary {

    param(
        [string]$HashDir = "C:\temp\Database\hash",
        [string]$OutputDir = "C:\temp\Database\os"
    )

    if (-not (Test-Path $HashDir)) {
        throw "HashDir not found: $HashDir"
    }

    if (-not (Test-Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    }

    # Nettoyer les anciens fichiers OS
    Get-ChildItem $OutputDir -Filter "*.json" -ErrorAction SilentlyContinue |
        Remove-Item -Force

    $allItems = foreach ($file in Get-ChildItem $HashDir -Filter "*.json") {

        Write-Host "Reading $($file.Name)"

        $content = Get-Content $file.FullName -Raw

        if ([string]::IsNullOrWhiteSpace($content)) {
            continue
        }

        $json = $content | ConvertFrom-Json

        foreach ($item in @($json)) {
            if ($item.SHA256 -match '^[a-fA-F0-9]{64}$' -and $item.OS) {
                $item
            }
        }
    }

    $groups = $allItems | Group-Object OS

    foreach ($group in $groups) {

        $osName = $group.Name.ToLower()
        $safeName = $osName -replace '[^a-z0-9\-]+', '-'
        $filePath = Join-Path $OutputDir "$safeName.json"

        $data = $group.Group |
            Sort-Object SHA256 -Unique

        @($data) |
            ConvertTo-Json -Depth 5 |
            Out-File $filePath -Encoding utf8 -Force

        Write-Host "Created $filePath : $($data.Count) entries"
    }

    $stats = [PSCustomObject]@{
    TotalHashes        = $allItems.Count
    TotalDistributions = $groups.Count
    LastUpdate         = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
}

$stats |
    ConvertTo-Json |
    Out-File ".\Work\stats.json" -Encoding utf8 -Force

Write-Host "Stats generated"
}

Convert-HashIndexToOSLibrary `
    -HashDir ".\Database\hash" `
    -OutputDir ".\Database\os"
