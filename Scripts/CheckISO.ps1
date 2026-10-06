<#
.SYNOPSIS
    This PowerShell script checks the hash of a Microsoft ISO file and verifies its authenticity.

.DESCRIPTION
    This script generates a GUI to facilitate the process of verifying Microsoft ISO files. 
    It allows the user to select an ISO file, calculates its hash, and compares it with the official Microsoft hash to verify the integrity and authenticity of the image. 
    This ensures that the ISO file has not been tampered with and is genuine.


.EXAMPLE
    .\CheckIso.ps1 
    This command runs the script with the specified ISO path, calculates its hash, and checks it against the official Microsoft hash to ensure its authenticity.

.NOTES
    Ensure that you have internet access when running this script as it may need to retrieve the official hash values from Microsoft's servers.

.Requiest 
    Work on any Windows version. not need additional permissions.

.AUTHOR
    Dakhama Mehdi

.Realse :
Version : 3.0 05/2026
Version : 1.1 05/2024
#>

$localversion = "3.1"
Add-Type -AssemblyName PresentationFramework

#  XAML 
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Check ISO Authenticity" Height="350" Width="610"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E" Foreground="White">

        <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="35"/>     <!-- HEADER (drag + close) -->
            <RowDefinition Height="Auto"/>   <!-- MENU -->
            <RowDefinition Height="*"/>      <!-- CONTENU -->
            <RowDefinition Height="Auto"/>   <!-- FOOTER -->
        </Grid.RowDefinitions>


        <Menu Grid.Row="0" Background="#2b2b2b" Foreground="#DCDCDC" FontSize="14">
            <MenuItem Header="File">
                <Separator/>
                <MenuItem Header="Exit" Name="menuExit" FontSize="14" Foreground="Black"/>
            </MenuItem>
            <MenuItem Header="Update" Name="menuUpdate" Foreground="White"/>
            <MenuItem Header="About" Name="menuAbout" Foreground="White"/>
        </Menu>


        <StackPanel Grid.Row="2" Margin="0,20,0,0">

            <StackPanel Orientation="Horizontal"  Margin="0,0,0,10">
                <TextBox Name="txtPath" Width="450" Height="30"
                         Background="#2D2D30" BorderBrush="#3E3E42"
                         Foreground="White" Padding="5"/>

                <Button Name="btnBrowse" Content="Browse" FontSize="14"
                        Width="100" Height="30" Margin="10,0,0,0"
                        Background="#007ACC" BorderBrush="#007ACC"
                        Foreground="White"/>
            </StackPanel>

            <StackPanel Orientation="Horizontal"  Margin="0,0,0,10">
                <TextBlock Text="Hash Algo :"
                           FontSize="14" VerticalAlignment="Center" Margin="0,0,10,0"
                           Foreground="#DCDCDC"/>

                <ComboBox Name="cmbAlgo" Width="150" Height="30" Background="#2D2D30" BorderBrush="#3E3E42" Foreground="black">
                    <ComboBoxItem Content="SHA256"/>
                    <ComboBoxItem Content="SHA1"/>
                    <ComboBoxItem Content="SHA512"/>
                    <ComboBoxItem Content="MD5"/>
                </ComboBox>

             <Button Name="btnStop" Margin="120,0,0,0" Content="Stop" FontSize="14"
                 Width="100" Height="30" Background="Orange" BorderBrush="#0E639C" Foreground="White"/>

            <Button Name="btnCheck" Margin="10,0,0,0" Content="Check ISO" FontSize="14"
                 Width="100" Height="30" Background="#0E639C" BorderBrush="#0E639C" Foreground="White"/>
            </StackPanel>

            <Border BorderBrush="#3E3E42" BorderThickness="1" CornerRadius="5">
            <TextBox Name="txtLog" Height="140" Background="#1E1E1E" Foreground="#DCDCDC"
             FontFamily="Consolas" FontSize="14" AcceptsReturn="True"
             TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
             IsReadOnly="True" Padding="5" BorderThickness="0"/>
            </Border>
          
        </StackPanel>

           <TextBlock Grid.Row="3" Text="CheckISO | v$localversion"
           HorizontalAlignment="Right"
           Margin="0,5,5,0"
           FontSize="12"
           Foreground="#888888"/>

    </Grid>

</Window>
"@

#region Function
# LOAD UI 
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Controls
$txtPath  = $window.FindName("txtPath")
$btnBrowse = $window.FindName("btnBrowse")
$cmbAlgo   = $window.FindName("cmbAlgo")
$btnCheck  = $window.FindName("btnCheck")
$txtLog    = $window.FindName("txtLog")
$menuabout = $Window.FindName("menuAbout")
$menuUpdate = $Window.FindName("menuUpdate")
$btnmenuExit = $Window.FindName("menuExit")
$btnStop = $window.FindName("btnStop")

$cmbAlgo.SelectedIndex = 0

# Functions

function Search-Iso {
    param($hash)

    $body = @{ search = $hash }

    try {
        $res = Invoke-WebRequest -Uri "https://files.rg-adguard.net/search" -TimeoutSec 15 -Method POST -Body $body -UseBasicParsing
        return $res.Content
    }
    catch {
        throw "Connection error"
    }
}

function Parse-Iso {
    param($html)

    if ($html -match 'file/[a-zA-Z0-9-]+">([^<]+)</a>') {
        return $matches[1]
    }
    return $null
}

function Find-LinuxPublicIndexHash {

    param(
        [Parameter(Mandatory)]
        [string]$SHA256
    )

    $sha = $SHA256.ToLower().Trim()

    if ($sha -notmatch '^[a-f0-9]{64}$') {
        return
    }

    $prefix = $sha.Substring(0,1)

    $url = "https://raw.githubusercontent.com/dakhama-mehdi/Check-ISO-Authenticity/main/Database/hash/$prefix.json"

    try {
    $raw     = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    $content = $raw.Content.TrimStart([char]0xFEFF) | ConvertFrom-Json
    }
    catch {
    return
    }

    $match = $content | Where-Object {
        $_.SHA256.ToLower().Trim() -eq $sha
    } | Select-Object -First 1

    if ($match) {
        return "$($match.OS), Version:$($match.Version), ISO:$($match.Name), Source:$($match.TrustLevel)"
    }
}


#endregion Function
#region events
$btnBrowse.Add_Click({
    $dialog = New-Object Microsoft.Win32.OpenFileDialog
    $dialog.Filter = "ISO (*.iso)|*.iso"

    if ($dialog.ShowDialog()) {
        $txtPath.Text = $dialog.FileName
    }
})
$btnStop.Add_Click({
    $script:StopHashCalculation = $true
})
# Check
$btnCheck.Add_Click({

    if ([string]::IsNullOrWhiteSpace($txtPath.Text) -or -not (Test-Path -LiteralPath $txtPath.Text)) {
        [System.Windows.MessageBox]::Show("Invalid file")
        return
    }

    $btnCheck.IsEnabled = $false
    $out = Join-Path $env:TEMP ("checkiso_{0}.json" -f [guid]::NewGuid())
    $err = Join-Path $env:TEMP ("checkiso_{0}.err"  -f [guid]::NewGuid())

    try {
        $txtLog.Foreground = "White"
        $txtLog.Text = "Calculating hash..."

        # Le chemin passe par l'environnement : plus de souci d'apostrophes ni d'injection
        $env:CHECKISO_FILE = $txtPath.Text
        $env:CHECKISO_ALGO = $cmbAlgo.SelectedItem.Content

        $script:StopHashCalculation = $false

        $process = Start-Process powershell.exe `
            -ArgumentList '-NoProfile -Command (Get-FileHash -LiteralPath $env:CHECKISO_FILE -Algorithm $env:CHECKISO_ALGO -ErrorAction Stop).Hash' `
            -RedirectStandardOutput $out `
            -RedirectStandardError $err `
            -WindowStyle Hidden `
            -PassThru
        $null = $process.Handle
        $script:hashProcess = $process

        $start   = Get-Date
        $timeout = 600

        do {
            $window.Dispatcher.Invoke([Action]{}, "Background")
            Start-Sleep -Milliseconds 100

            $elapsed = [int]((Get-Date) - $start).TotalSeconds
            $minutes = [math]::Floor($elapsed / 60)
            $seconds = $elapsed % 60
            $txtLog.Text = "Calculating hash....... $minutes min $seconds sec"

            if ($script:StopHashCalculation -or ((Get-Date) -gt $start.AddSeconds($timeout))) {
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                $process.WaitForExit(2000) | Out-Null
                if ($script:StopHashCalculation) {
                    $txtLog.AppendText("`r`nHash calculation stopped by user")
                }
                else {
                    $txtLog.AppendText("`r`nTimeout")
                }
                return
            }
        }
        until ($process.HasExited)

        $json = Get-Content -LiteralPath $out -Raw -ErrorAction SilentlyContinue
        if ($process.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($json)) {
            $reason = (Get-Content -LiteralPath $err -Raw -ErrorAction SilentlyContinue)
            $txtLog.Foreground = "Red"
            $txtLog.Text = "Hash calculation failed.`r`n$reason"
            return
        }

        $hachfind = $json.Trim()
        $text = "Hash: $hachfind`r`nElapsed : $minutes min $seconds sec`r`n"
        $txtLog.Text = $text + "Searching..."
        $window.Dispatcher.Invoke([Action]{}, "Background")

        $html = $null
        try { $html = Search-Iso $hachfind } catch { }
        $result = Parse-Iso $html

        if (-not $result) {
            $result = Find-LinuxPublicIndexHash -SHA256 $hachfind
        }

        $txtLog.Text = $text

        if ($result) {
            $txtLog.AppendText("`r`nFound : $result")
            $txtLog.Foreground = "LightGreen"
        } else {
            $txtLog.Foreground = "Red"
            $txtLog.AppendText("`r`nNot found in databases")
        }
    }
    finally {
        Remove-Item -LiteralPath $out, $err -Force -ErrorAction SilentlyContinue
        Remove-Item Env:\CHECKISO_FILE, Env:\CHECKISO_ALGO -ErrorAction SilentlyContinue
        $btnCheck.IsEnabled = $true
    }
})


# Menu
$menuAbout.Add_Click({
    [System.Windows.MessageBox]::Show(
    "Check ISO Authenticity`nVersion $localversion`n`nDevelopped : Dakhama Mehdi`nThanks : It-Connect.fr`n@ 2026",
    "About",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information

)
   
})
$menuUpdate.Add_Click({

    try {
        $localVersion = "3.1"

        $url = "https://raw.githubusercontent.com/dakhama-mehdi/Check-ISO-Authenticity/main/Version.txt"

        $remoteVersion = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content.Trim()

        if ($remoteVersion -ne $localVersion) {
            [System.Windows.MessageBox]::Show("New version available: $remoteVersion`r`nVisit Github", "Update")
        } else {
            [System.Windows.MessageBox]::Show("You are up to date", "Update")
        }
    }
    catch {
        [System.Windows.MessageBox]::Show("Error checking update", "Update")
    }

})
$btnmenuExit.Add_Click({
$window.Close()
})
$window.Add_Closing({
    if ($script:hashProcess -and -not $script:hashProcess.HasExited) {
        Stop-Process -Id $script:hashProcess.Id -Force -ErrorAction SilentlyContinue
    }
})
#endregion events

#  RUN 
$window.ShowDialog() | Out-Null

# SIG # Begin signature block
# MIItjAYJKoZIhvcNAQcCoIItfTCCLXkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB2yIuqIrK98idi
# v5KRvLAAReuOJqI072kM7rNMqDbmB6CCEtUwggXJMIIEsaADAgECAhAbtY8lKt8j
# AEkoya49fu0nMA0GCSqGSIb3DQEBDAUAMH4xCzAJBgNVBAYTAlBMMSIwIAYDVQQK
# ExlVbml6ZXRvIFRlY2hub2xvZ2llcyBTLkEuMScwJQYDVQQLEx5DZXJ0dW0gQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkxIjAgBgNVBAMTGUNlcnR1bSBUcnVzdGVkIE5l
# dHdvcmsgQ0EwHhcNMjEwNTMxMDY0MzA2WhcNMjkwOTE3MDY0MzA2WjCBgDELMAkG
# A1UEBhMCUEwxIjAgBgNVBAoTGVVuaXpldG8gVGVjaG5vbG9naWVzIFMuQS4xJzAl
# BgNVBAsTHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEkMCIGA1UEAxMb
# Q2VydHVtIFRydXN0ZWQgTmV0d29yayBDQSAyMIICIjANBgkqhkiG9w0BAQEFAAOC
# Ag8AMIICCgKCAgEAvfl4+ObVgAxknYYblmRnPyI6HnUBfe/7XGeMycxca6mR5rlC
# 5SBLm9qbe7mZXdmbgEvXhEArJ9PoujC7Pgkap0mV7ytAJMKXx6fumyXvqAoAl4Va
# qp3cKcniNQfrcE1K1sGzVrihQTib0fsxf4/gX+GxPw+OFklg1waNGPmqJhCrKtPQ
# 0WeNG0a+RzDVLnLRxWPa52N5RH5LYySJhi40PylMUosqp8DikSiJucBb+R3Z5yet
# /5oCl8HGUJKbAiy9qbk0WQq/hEr/3/6zn+vZnuCYI+yma3cWKtvMrTscpIfcRnNe
# GWJoRVfkkIJCu0LW8GHgwaM9ZqNd9BjuiMmNF0UpmTJ1AjHuKSbIawLmtWJFfzcV
# WiNoidQ+3k4nsPBADLxNF8tNorMe0AZa3faTz1d1mfX6hhpneLO/lv403L3nUlbl
# s+V1e9dBkQXcXWnjlQ1DufyDljmVe2yAWk8TcsbXfSl6RLpSpCrVQUYJIP4ioLZb
# MI28iQzV13D4h1L92u+sUS4Hs07+0AnacO+Y+lbmbdu1V0vc5SwlFcieLnhO+Nqc
# noYsylfzGuXIkosagpZ6w7xQEmnYDlpGizrrJvojybawgb5CAKT41v4wLsfSRvbl
# jnX98sy50IdbzAYQYLuDNbdeZ95H7JlI8aShFf6tjGKOOVVPORa5sWOd/7cCAwEA
# AaOCAT4wggE6MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFLahVDkCw6A/joq8
# +tT4HKbROg79MB8GA1UdIwQYMBaAFAh2zcsH/yT2xc3tu5C84oQ3RnX3MA4GA1Ud
# DwEB/wQEAwIBBjAvBgNVHR8EKDAmMCSgIqAghh5odHRwOi8vY3JsLmNlcnR1bS5w
# bC9jdG5jYS5jcmwwawYIKwYBBQUHAQEEXzBdMCgGCCsGAQUFBzABhhxodHRwOi8v
# c3ViY2Eub2NzcC1jZXJ0dW0uY29tMDEGCCsGAQUFBzAChiVodHRwOi8vcmVwb3Np
# dG9yeS5jZXJ0dW0ucGwvY3RuY2EuY2VyMDkGA1UdIAQyMDAwLgYEVR0gADAmMCQG
# CCsGAQUFBwIBFhhodHRwOi8vd3d3LmNlcnR1bS5wbC9DUFMwDQYJKoZIhvcNAQEM
# BQADggEBAFHCoVgWIhCL/IYx1MIy01z4S6Ivaj5N+KsIHu3V6PrnCA3st8YeDrJ1
# BXqxC/rXdGoABh+kzqrya33YEcARCNQOTWHFOqj6seHjmOriY/1B9ZN9DbxdkjuR
# mmW60F9MvkyNaAMQFtXx0ASKhTP5N+dbLiZpQjy6zbzUeulNndrnQ/tjUoCFBMQl
# lVXwfqefAcVbKPjgzoZwpic7Ofs4LphTZSJ1Ldf23SIikZbr3WjtP6MZl9M7JYjs
# NhI9qX7OAo0FmpKnJ25FspxihjcNpDOO16hO0EoXQ0zF8ads0h5YbBRRfopUofbv
# n3l6XYGaFpAP4bvxSgD5+d2+7arszgowggZHMIIEL6ADAgECAhA12OBytW+cTayv
# VHUpRhwLMA0GCSqGSIb3DQEBCwUAMFYxCzAJBgNVBAYTAlBMMSEwHwYDVQQKExhB
# c3NlY28gRGF0YSBTeXN0ZW1zIFMuQS4xJDAiBgNVBAMTG0NlcnR1bSBDb2RlIFNp
# Z25pbmcgMjAyMSBDQTAeFw0yNTExMTYxMTAwMTlaFw0yNjExMTYxMTAwMThaMG0x
# CzAJBgNVBAYTAkZSMQ8wDQYDVQQHDAZUb3Vsb24xHjAcBgNVBAoMFU9wZW4gU291
# cmNlIERldmVsb3BlcjEtMCsGA1UEAwwkT3BlbiBTb3VyY2UgRGV2ZWxvcGVyLCBE
# QUtIQU1BIE1FSERJMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAp6Ku
# m/VmkWCqAaF/3zHh9f1FuJYY2ozbXOu7mo1/Q8i1c0fE0TXpkZXLY2GZbfpj9BmH
# AAFM0IhOsPR2vdxq3jOUJUb9TICneFor6YaPpySsXR3WSE7X42kgpkkmPELovm1Y
# hwSzhJ4a+E+NWL/MU8h5JpmGVlqPJ02/ZTlMj5kcpIQtq8hoQMcUEDkGFt9IcamE
# 1yN4IHkBA5nm4jJPaos0IuS77t805992JSGWhxBxWARH+2vyltv8Rmq1pZV1lE6n
# JgrWT7Ichjw2X/A+OP68ooTzQwCIpzXb4UuUcwHEfrmP3HGMQJoj//SNC4QPMao+
# 3Z8zbevl73E3d6Kfvra1S+pWM2Ze5YCsIqAd98GUHgi5E6GiG8FQq/+d6msL7l8B
# UASCqXlcAKIjRNMHp8BrUaaW6HS9Kpc+3O3t/LUmK6X3FFiW8QsWoh4K+7YSpopa
# CQbNXmEI4xftctwBOJrEU2oqRnYiwchfjqBNlrGwVGPK1rmM0iTt5KiLTus7AgMB
# AAGjggF4MIIBdDAMBgNVHRMBAf8EAjAAMD0GA1UdHwQ2MDQwMqAwoC6GLGh0dHA6
# Ly9jY3NjYTIwMjEuY3JsLmNlcnR1bS5wbC9jY3NjYTIwMjEuY3JsMHMGCCsGAQUF
# BwEBBGcwZTAsBggrBgEFBQcwAYYgaHR0cDovL2Njc2NhMjAyMS5vY3NwLWNlcnR1
# bS5jb20wNQYIKwYBBQUHMAKGKWh0dHA6Ly9yZXBvc2l0b3J5LmNlcnR1bS5wbC9j
# Y3NjYTIwMjEuY2VyMB8GA1UdIwQYMBaAFN10XUwA23ufoHTKsW73PMAywHDNMB0G
# A1UdDgQWBBSXTmfHi9BD9GDRwk5/doNtKHBXYzBLBgNVHSAERDBCMAgGBmeBDAEE
# ATA2BgsqhGgBhvZ3AgUBBDAnMCUGCCsGAQUFBwIBFhlodHRwczovL3d3dy5jZXJ0
# dW0ucGwvQ1BTMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAN
# BgkqhkiG9w0BAQsFAAOCAgEAe+khGqwUUkFYuFRsrvenX2/a+PIt2Tu9d3VoW6Or
# MX3YLpe7S2CgFkXwEi2Siq5KiD1labP9jsh/3G1ZQwwlnPv8dB7ocl/nOrQ9OZex
# GVE1r7IO6VYVa5F7XuJ/KadKLEbQSs1BpBVhESo1ZYr6w9NCLuO9q2Sh3H5MktET
# D6sB+g1TFOYMdwYl8eAawgI2kGPe3dRQSoumP0mHkm3x5SIwRCW+08md5uyzCIui
# 85WmcNPtM1QCqjkSpfdFGYPsnf/BO9NATpZkqFxhXwa9+PqseX+mofCIL49guCXG
# kU4RpeRHcUie14oYkxvBw7VUO4MT6wYbS2C3j2nyoAV4XqqNMfrhZIBJG5haj2RB
# V46bMJ+DsW6hxlm3lIlCaJT2pLbbk79OP+Bk0HIdC9mAbKzcqaZpBpn4+ljrcx7/
# X7OHv4XTCCDWwlZbaogy4Wci6TiSjjfpfXK5N/eJTEEh2w4qoYTTrR61ptkVnTUT
# vGRfPnVtS/3aOm2v4UahtOc/ygcL0A/J85r1e6CEeOaTm9eJbHoNdwNIYaZ81VlX
# /V/MoJgFCtioYOKiTf2Rdq7XrEEHLU2YGwCqJyKYz9tz10yXBcMW6/+gX+PGqAYz
# eKg5jbKLdi9lVrKspQUXAPHdcl6VJMXy799J0lbsQeJNgBVy6HWxOWvdLBGX3hPE
# 3aYwgga5MIIEoaADAgECAhEAmaOACiZVO2Wr3G6EprPqOTANBgkqhkiG9w0BAQwF
# ADCBgDELMAkGA1UEBhMCUEwxIjAgBgNVBAoTGVVuaXpldG8gVGVjaG5vbG9naWVz
# IFMuQS4xJzAlBgNVBAsTHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEk
# MCIGA1UEAxMbQ2VydHVtIFRydXN0ZWQgTmV0d29yayBDQSAyMB4XDTIxMDUxOTA1
# MzIxOFoXDTM2MDUxODA1MzIxOFowVjELMAkGA1UEBhMCUEwxITAfBgNVBAoTGEFz
# c2VjbyBEYXRhIFN5c3RlbXMgUy5BLjEkMCIGA1UEAxMbQ2VydHVtIENvZGUgU2ln
# bmluZyAyMDIxIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnSPP
# BDAjO8FGLOczcz5jXXp1ur5cTbq96y34vuTmflN4mSAfgLKTvggv24/rWiVGzGxT
# 9YEASVMw1Aj8ewTS4IndU8s7VS5+djSoMcbvIKck6+hI1shsylP4JyLvmxwLHtSw
# orV9wmjhNd627h27a8RdrT1PH9ud0IF+njvMk2xqbNTIPsnWtw3E7DmDoUmDQiYi
# /ucJ42fcHqBkbbxYDB7SYOouu9Tj1yHIohzuC8KNqfcYf7Z4/iZgkBJ+UFNDcc6z
# okZ2uJIxWgPWXMEmhu1gMXgv8aGUsRdaCtVD2bSlbfsq7BiqljjaCun+RJgTgFRC
# tsuAEw0pG9+FA+yQN9n/kZtMLK+Wo837Q4QOZgYqVWQ4x6cM7/G0yswg1ElLlJj6
# NYKLw9EcBXE7TF3HybZtYvj9lDV2nT8mFSkcSkAExzd4prHwYjUXTeZIlVXqj+ea
# YqoMTpMrfh5MCAOIG5knN4Q/JHuurfTI5XDYO962WZayx7ACFf5ydJpoEowSP07Y
# aBiQ8nXpDkNrUA9g7qf/rCkKbWpQ5boufUnq1UiYPIAHlezf4muJqxqIns/kqld6
# JVX8cixbd6PzkDpwZo4SlADaCi2JSplKShBSND36E/ENVv8urPS0yOnpG4tIoBGx
# VCARPCg1BnyMJ4rBJAcOSnAWd18Jx5n858JSqPECAwEAAaOCAVUwggFRMA8GA1Ud
# EwEB/wQFMAMBAf8wHQYDVR0OBBYEFN10XUwA23ufoHTKsW73PMAywHDNMB8GA1Ud
# IwQYMBaAFLahVDkCw6A/joq8+tT4HKbROg79MA4GA1UdDwEB/wQEAwIBBjATBgNV
# HSUEDDAKBggrBgEFBQcDAzAwBgNVHR8EKTAnMCWgI6Ahhh9odHRwOi8vY3JsLmNl
# cnR1bS5wbC9jdG5jYTIuY3JsMGwGCCsGAQUFBwEBBGAwXjAoBggrBgEFBQcwAYYc
# aHR0cDovL3N1YmNhLm9jc3AtY2VydHVtLmNvbTAyBggrBgEFBQcwAoYmaHR0cDov
# L3JlcG9zaXRvcnkuY2VydHVtLnBsL2N0bmNhMi5jZXIwOQYDVR0gBDIwMDAuBgRV
# HSAAMCYwJAYIKwYBBQUHAgEWGGh0dHA6Ly93d3cuY2VydHVtLnBsL0NQUzANBgkq
# hkiG9w0BAQwFAAOCAgEAdYhYD+WPUCiaU58Q7EP89DttyZqGYn2XRDhJkL6P+/T0
# IPZyxfxiXumYlARMgwRzLRUStJl490L94C9LGF3vjzzH8Jq3iR74BRlkO18J3zId
# mCKQa5LyZ48IfICJTZVJeChDUyuQy6rGDxLUUAsO0eqeLNhLVsgw6/zOfImNlARK
# n1FP7o0fTbj8ipNGxHBIutiRsWrhWM2f8pXdd3x2mbJCKKtl2s42g9KUJHEIiLni
# 9ByoqIUul4GblLQigO0ugh7bWRLDm0CdY9rNLqyA3ahe8WlxVWkxyrQLjH8ItI17
# RdySaYayX3PhRSC4Am1/7mATwZWwSD+B7eMcZNhpn8zJ+6MTyE6YoEBSRVrs0zFF
# IHUR08Wk0ikSf+lIe5Iv6RY3/bFAEloMU+vUBfSouCReZwSLo8WdrDlPXtR0gicD
# nytO7eZ5827NS2x7gCBibESYkOh1/w1tVxTpV2Na3PR7nxYVlPu1JPoRZCbH86gc
# 96UTvuWiOruWmyOEMLOGGniR+x+zPF/2DaGgK2W1eEJfo2qyrBNPvF7wuAyQfiFX
# LwvWHamoYtPZo0LHuH8X3n9C+xN4YaNjt2ywzOr+tKyEVAotnyU9vyEVOaIYMk3I
# eBrmFnn0gbKeTTyYeEEUz/Qwt4HOUBCrW602NCmvO1nm+/80nLy5r0AZvCQxaQ4x
# ghoNMIIaCQIBATBqMFYxCzAJBgNVBAYTAlBMMSEwHwYDVQQKExhBc3NlY28gRGF0
# YSBTeXN0ZW1zIFMuQS4xJDAiBgNVBAMTG0NlcnR1bSBDb2RlIFNpZ25pbmcgMjAy
# MSBDQQIQNdjgcrVvnE2sr1R1KUYcCzANBglghkgBZQMEAgEFAKB8MBAGCisGAQQB
# gjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCCQ6xahtVkJpwORdyb5
# nuc8UxSOaSexp76scIVXkQSzwDANBgkqhkiG9w0BAQEFAASCAYBvC1TwYVM3/Wdo
# aKPVAnJrCqvesCuzSLVNnw52IliO5/9KE1d2yPM5hWanIKmOfORMRMhhXnpaRlUE
# 9QLPn0V/OYqkPLuUdTTe6AzNR0ca1g7mPlMAGN3aX59bn3Qp5ForTIYXfS2iZ5bg
# YqQcXnvpZnqGuQWKL3hsHB9oTusryQQiFRk4x2uPM6Z35fq8lheVwpFXoz2+11r7
# p65BuKx3IQMvj26xQBNJh0z0PERMDX2hFfcEMedXm6I03LANfNoS9Vee+YJsbYNA
# M4tqxWUircyuoe7suWBlDkP2RpYQvLCOxx0F/aAd8oCYljG1Ah9IPuMvjt2SMbAu
# IRCPl6zEMuWf33kpEdHSUmWLFv2jGc4+Th+LFisS4cr15vmga29bwbM2F3SrImCH
# S6Itv7nb6WmsABkvDSNTR1IEjMHsytSHKR1o83g0O9yWC6Ah6iDcZCYcPZlvKST2
# OGDv54syKSAoSZ5FtuAZvfWDUfzkuyaUd8juggJmifEFM8geRgehghd2MIIXcgYK
# KwYBBAGCNwMDATGCF2IwghdeBgkqhkiG9w0BBwKgghdPMIIXSwIBAzEPMA0GCWCG
# SAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEBBglghkgBhv1sBwEwMTAN
# BglghkgBZQMEAgEFAAQgtQMQR1bk47DnXlcrBsacUOzDqwuz25143GZuCgTClecC
# EBLb/43t8oS1+jXx+xbS1bkYDzIwMjYxMDA2MTIxNTA2WqCCEzowggbtMIIE1aAD
# AgECAhAIT9wzT35FTtvDD4/5khg1MA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQg
# VHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEw
# HhcNMjYwODA1MDAwMDAwWhcNMzcxMTA0MjM1OTU5WjBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFNIQTI1
# NiBSU0E0MDk2IFRpbWVzdGFtcCBSZXNwb25kZXIgMjAyNiAxMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAtnum8sn+zUr41JtMZbP9OMYw+HwJDpG5xkIu
# /lqcfNYmMX81YmsUiHLbh9ykpeWBGKTLhYBrAN9Tdg/QEzG32XcObmgIblnr0CoQ
# 3WSAeDZ6nH6X6VkFyYkJw3QBJREwvm4UhLzSxmwPA7cFKRTEOMsmEEj6qJk/dqLE
# AL+oQYuOwE2UuiX1Vnul8YReIyWd4kgLn9gq6LNXM0UplkR6jL/QHxmb6fMoGBJY
# bnaUI7XD6cKDpekK2SVMld4iDbzeHDtOaaxldH5IxuNusQ69nd8/ZXEiB5Hbxj3R
# lK13cX1W4DlFXKdv/CEhM8Cj1vvlmvhNroyPdRGbbpBlgyf8Wdu5N6ByhFwURn0U
# 6ozlPoxN22v+fviUhP+6DR547OZnpBMWDfei1f5sVGwiiW/KQTWOK97g+4RJpPzP
# NV4VYMAwO2jM2Aty2QYPVmOQTJm0msuXnJrSbl2gf9JylpkJlWXqk1Q4LJsxz+TE
# LoQCZIljbgvTJgoPU2R12ydv8i1UqL/adelA0y7U9Pmmtbze9Xx3rtajC5SzQd1j
# gfwAwsa90v9YcSPdmeoyoBBA/27cCL237l5DTYYPDLQ4ON3OLTGWnvRb6jDrf/T7
# 5gMRfUzSLCBQfBusm9+mSWRlC/Df6S/e9Q8i13CuhzOT2Jx+V/nlbXM4QoBwlUAh
# elwwJT0CAwEAAaOCAZUwggGRMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFBTJY4ow
# LtRK+26U8+bjQH717M3iMB8GA1UdIwQYMBaAFO9vU0rp5AZ8esrikFb2L9RJ7MtO
# MA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCBlQYIKwYB
# BQUHAQEEgYgwgYUwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBdBggrBgEFBQcwAoZRaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3J0
# MF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNy
# bDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggIBAI3FOmEenVIK35msCYB+fShAsWvSYvLBItoNdAgQ2jIqrGsVsluXMJU/
# +mRebBc52s6lbKAvOVPXaizmKkMLLflEEKDZQx4CkS2t8aHPjkXha3hYZ010htFa
# 3dhNgmalH5vuWvh3tTCf4frTS7gPtGc4Z/xaPhQ2AB1mR8eEe/WbH0RWHvVIl6Vw
# Q3+g5FKNfN2N/DWJkf13w2H+2GfqEfbd35Ww8CvoYBjLNIDTadcPWdgsjsiOaK/7
# EsKJgLjUNIVgvcaFOLLQ/GlrA+0ZHJoFUbOr5SJN8zykPspXIXlpDJY/gqFUZRRO
# eab9GVgmhbdOJcD/63RhxPahFUGbckRONqMe6DYAv6/mOG0pWd3cPStsdcS7buj5
# DyniwRY8yooMH6ptx5vpP/pZzBPBeZD2U4IsthyxB5Jaa8qrOkB5z160TXiM5ADM
# spZ0TfD9MJoq0tFpFPssKRFhWeEDYPvcUuN7U7lvcdHl4ezQ3NT/7Ffs1sR1yh/L
# RbdZ3B3Vc6q2WmD8mDC0p9kzl2o73iVtS946IkEj7FkRsZGww1teYxERROC745xr
# tjvcw9ZyyUjHZWGRIpJeMNsPquCDf0fkyHtB+J4AiNZqCQk23rxh+KbpyMTNVKIt
# J5l92Svl20U9NbqMBOVYl1h54NEYLJq1/xHWFKPNK903zJZA9P2DMIIGtDCCBJyg
# AwIBAgIQDcesVwX/IZkuQEMiDDpJhjANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjUw
# NTA3MDAwMDAwWhcNMzgwMTE0MjM1OTU5WjBpMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQg
# VGltZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAtHgx0wqYQXK+PEbAHKx126NGaHS0URedTa2N
# DZS1mZaDLFTtQ2oRjzUXMmxCqvkbsDpz4aH+qbxeLho8I6jY3xL1IusLopuW2qft
# JYJaDNs1+JH7Z+QdSKWM06qchUP+AbdJgMQB3h2DZ0Mal5kYp77jYMVQXSZH++0t
# rj6Ao+xh/AS7sQRuQL37QXbDhAktVJMQbzIBHYJBYgzWIjk8eDrYhXDEpKk7RdoX
# 0M980EpLtlrNyHw0Xm+nt5pnYJU3Gmq6bNMI1I7Gb5IBZK4ivbVCiZv7PNBYqHEp
# NVWC2ZQ8BbfnFRQVESYOszFI2Wv82wnJRfN20VRS3hpLgIR4hjzL0hpoYGk81coW
# J+KdPvMvaB0WkE/2qHxJ0ucS638ZxqU14lDnki7CcoKCz6eum5A19WZQHkqUJfdk
# DjHkccpL6uoG8pbF0LJAQQZxst7VvwDDjAmSFTUms+wV/FbWBqi7fTJnjq3hj0Xb
# Qcd8hjj/q8d6ylgxCZSKi17yVp2NL+cnT6Toy+rN+nM8M7LnLqCrO2JP3oW//1sf
# uZDKiDEb1AQ8es9Xr/u6bDTnYCTKIsDq1BtmXUqEG1NqzJKS4kOmxkYp2WyODi7v
# QTCBZtVFJfVZ3j7OgWmnhFr4yUozZtqgPrHRVHhGNKlYzyjlroPxul+bgIspzOwb
# tmsgY1MCAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYE
# FO9vU0rp5AZ8esrikFb2L9RJ7MtOMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/n
# upiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3Bggr
# BgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0g
# BBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQAX
# zvsWgBz+Bz0RdnEwvb4LyLU0pn/N0IfFiBowf0/Dm1wGc/Do7oVMY2mhXZXjDNJQ
# a8j00DNqhCT3t+s8G0iP5kvN2n7Jd2E4/iEIUBO41P5F448rSYJ59Ib61eoalhnd
# 6ywFLerycvZTAz40y8S4F3/a+Z1jEMK/DMm/axFSgoR8n6c3nuZB9BfBwAQYK9FH
# aoq2e26MHvVY9gCDA/JYsq7pGdogP8HRtrYfctSLANEBfHU16r3J05qX3kId+ZOc
# zgj5kjatVB+NdADVZKON/gnZruMvNYY2o1f4MXRJDMdTSlOLh0HCn2cQLwQCqjFb
# qrXuvTPSegOOzr4EWj7PtspIHBldNE2K9i697cvaiIo2p61Ed2p8xMJb82Yosn0z
# 4y25xUbI7GIN/TpVfHIqQ6Ku/qjTY6hc3hsXMrS+U0yy+GWqAXam4ToWd2UQ1KYT
# 70kZjE4YtL8Pbzg0c1ugMZyZZd/BdHLiRu7hAWE6bTEm4XYRkA6Tl4KSFLFk43es
# aUeqGkH/wyW4N7OigizwJWeukcyIPbAvjSabnf7+Pu0VrFgoiovRDiyx3zEdmcif
# /sYQsfch28bZeUz2rtY/9TCA6TD8dC3JE3rYkrhLULy7Dc90G6e8BlqmyIjlgp2+
# VqsS9/wQD7yFylIz0scmbKvFoW2jNrbM1pD2T7m3XDCCBY0wggR1oAMCAQICEA6b
# GI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEk
# MCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAw
# MDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERp
# Z2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMY
# RGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2u
# exuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKv
# aJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/gh
# YZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOt
# yU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCR
# cKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8
# oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m
# 1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y
# 1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkl
# iWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/E
# IFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOC
# ATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/n
# upiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB
# /wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqg
# OKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEA
# cKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU
# 9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0Sb
# QyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1Rmpp
# VLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxY
# oA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0Vys
# GMNNn3O3AamfV6peKOK5lDGCA3wwggN4AgEBMH0waTELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVk
# IEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMQIQCE/cM09+
# RU7bww+P+ZIYNTANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZI
# hvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTI2MTAwNjEyMTUwNlowKwYLKoZIhvcN
# AQkQAgwxHDAaMBgwFgQUUdmr2gNJc9hPQmaspIJI5rNpxDkwLwYJKoZIhvcNAQkE
# MSIEIBkYbVPMaFGQpReB2DeDMhZ2k6Ch9Gc57v5tc4Fb0INsMDcGCyqGSIb3DQEJ
# EAIvMSgwJjAkMCIEIC2gnaf0Ex+f5y22xebpyWVnVa8EPx6nQswNISDhQev8MA0G
# CSqGSIb3DQEBAQUABIICAEbqeq/Kki7+FDyTOz0kMvwjAixC7ciDBA+5oMiJNlkm
# UHAID+WjAftSg6FMxe9BoWgAbX3SbbiQ/p1jvJRmKfVXXIallRFhDUbXkNHPx5ET
# j5/ErfuSzR4DSBgfMM7OQ1z8dQKFfHlXkUAhwkGxvF/zx1K4nKMtSiVPSMb8TEzv
# ppLFeaLhQU39O6FQB0z9LtVy0UfHlZy1eQbST3TupcQgiaQ+KEEzVvNMpRLQDJd3
# buK2MOKfxFQzbbQ5NmldYvKulhRQTJelBDPkmF+hnSejB82wuFcchhB7/Z5/T/9m
# AIUQ3jRzolEOHfq0qeyBgfej+EdhR2G3GxcJOKk6eeW/ODhdOyv5V/f8WK9MX0Kv
# OF0duz7hGYhKDGL4/dQ2PmYXbo+cxXoMb+bDcmd/ouScWAt3xOSyMsaB+1PZKQpa
# U5LqBmUWNaxiYqNgaVEpbYRn/ocLZvPDEdrAELTyDdc3ES+NKOCwtyaT6yCnDriY
# N7QfY/72Ft02uudKpBT04LYf/5rs8H9ex4fX3oIUUaMK+8Hrd66wtgKXsFMai1Bh
# lpaS5kGcIcp+6CQxreoHvHZGpooiFZxpH/5+8vvbVABuYGvfZ+Pz82r8dlDNjrrH
# gEaZCuxsODonNV4oinSFNZswOb9V5hcGCdJt46yfME15XRFmn5te3IhwwQomDMl5
# SIG # End signature block
