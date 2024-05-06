

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
Version : 1.1 05/2024
#>


#----------------------------------------------
#region Application Functions
#----------------------------------------------

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Show-newcheckiso_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formCheckISOAuthenticity = New-Object 'System.Windows.Forms.Form'
	$log = New-Object 'System.Windows.Forms.RichTextBox'
	$labelSelectISO = New-Object 'System.Windows.Forms.Label'
	$menustrip1 = New-Object 'System.Windows.Forms.MenuStrip'
	$combobox = New-Object 'System.Windows.Forms.ComboBox'
	$labelHashAlgo = New-Object 'System.Windows.Forms.Label'
	$buttonPath = New-Object 'System.Windows.Forms.Button'
	$path = New-Object 'System.Windows.Forms.TextBox'
	$buttonCheckISO = New-Object 'System.Windows.Forms.Button'
	$fileToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$exitToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$languageToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$englishToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$francaisToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$aboutToolStripMenuItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$openfiledialog1 = New-Object 'System.Windows.Forms.OpenFileDialog'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$formCheckISOAuthenticity_Load={
		#TODO: Initialize Form Controls here
		loadform
	}
	
	
	$buttonCheckISO_Click={
		#TODO: Place custom script here
		if (!$path.Text)
		{
			
			[System.Windows.Forms.MessageBox]::Show($xmldata.action.erreur1.InnerText, 'Check ISO')
		}
		else
		{
			$log.Text = $inprogress		
			start-sleep -Seconds 2		
			start-job -name 'SHA-calc' -scriptblock { Get-FileHash -path $using:path.Text -Algorithm $using:combobox.Text }		
			# Attendre que le travail soit terminé avec une attente flexible
			do
			{
				for ($i = 0; $i -lt 10; $i++)
				{
					[System.Windows.Forms.Application]::DoEvents()
					Start-Sleep -Milliseconds 1000 # Attendre 100 millisecondes entre chaque itération
					$log.Text += ".."
					[System.Windows.Forms.Application]::DoEvents()
				}
				
				$result = (Get-Job 'SHA-calc').State
			}
			until ($result -eq 'Completed')
			
			$hach = Receive-Job SHA-calc
			Remove-Job -name SHA-calc
			
			$log.Text = $hach.hash
			$log.Clear()
			$log.AppendText($text1 + $hach.hash)
	
			# Necessary HTTP headers for the request			
			$headers = @{
				"Accept"					   = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
				"Accept-Encoding"			   = "gzip, deflate, br"
				"Accept-Language"			   = "fr,en-US;q=0.9,en;q=0.8,es;q=0.7,fr-FR;q=0.6"
				"Cache-Control"			       = "max-age=0"
				"Content-Type"				   = "application/x-www-form-urlencoded"
				"Cookie"					   = "cf_clearance=f_.YpBpka.unfZUZNdQnQAjcjzQ9FdDihWgkIzUJQrw-1710459284-1.0.1.1-9aJRM41O_tBmhqQI2R_UpugWKht0ECFOrgh8dsekYLrtKome4LWnG13qhhO1Ke4b7qRyOO0OzB37cHP65_gWLQ"
				"Origin"					   = "https://files.rg-adguard.net"
				"Referer"					   = "https://files.rg-adguard.net/search"
				"User-Agent"				   = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36 Edg/122.0.0.0"
				"Sec-Fetch-Dest"			   = "document"
				"Sec-Fetch-Mode"			   = "navigate"
				"Sec-Fetch-Site"			   = "same-origin"
				"Sec-Fetch-User"			   = "?1"
				"Upgrade-Insecure-Requests"    = "1"
			}
			
			# Form data
			$body = "search=" + $hach.hash		
			# Sending the POST request
			$response = Invoke-WebRequest -Uri "https://files.rg-adguard.net/search" -Method POST -Headers $headers -Body $body -ErrorVariable acces -ErrorAction SilentlyContinue
			if ($acces)
			{
				$failed = $acces.message
				[System.Windows.Forms.MessageBox]::Show("Check ISO `r`n`r`n$failed `r`n`r`nplease check connection", 'About Check ISO')			
			}
			else
			{			
				$pattern = 'href="https://files.rg-adguard.net/file/[a-zA-Z0-9-]+">([^<]+)</a>'
				
				if ($response.Content -match $pattern)
				{
					$isoName = $matches[1]
					$log.SelectionColor = 'Green'
					$log.AppendText("`r`n" + "`r`n" + "Source : " + $isoName)
				}
				else
				{
					$log.SelectionColor = 'red'
					$log.AppendText("`r`n" + "`r`n" + $script:noresult)
				}			
			}
			
		}	
		
	}
	
	#region Control Helper Functions
	function Update-ComboBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ComboBox.
		
		.DESCRIPTION
			Use this function to dynamically load items into the ComboBox control.
		
		.PARAMETER ComboBox
			The ComboBox control you want to add items to.
		
		.PARAMETER Items
			The object or objects you wish to load into the ComboBox's Items collection.
		
		.PARAMETER DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER Append
			Adds the item(s) to the ComboBox without clearing the Items collection.
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red" -Append
			Update-ComboBox $combobox1 "White" -Append
			Update-ComboBox $combobox1 "Blue" -Append
		
		.EXAMPLE
			Update-ComboBox $combobox1 (Get-Process) "ProcessName"
		
		.NOTES
			Additional information about the function.
	#>
		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ComboBox]
			$ComboBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]
			$DisplayMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ComboBox.Items.Clear()
		}
		
		if ($Items -is [Object[]])
		{
			$ComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ComboBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ComboBox.Items.Add($obj)
			}
			$ComboBox.EndUpdate()
		}
		else
		{
			$ComboBox.Items.Add($Items)
		}
		
		$ComboBox.DisplayMember = $DisplayMember
	}
	#endregion
	
	$combobox_SelectedIndexChanged={
		#TODO: Place custom script here
		
	}
	
	$buttonPath_Click={
		#TODO: Place custom script here
		$openfiledialog1.Filter = 'Image (*.ISO)|*.ISO'
		$openfiledialog1.Title = 'Sélectionner le fichier à ouvrir'
		$openfiledialog1.FileName = ''
		$openfiledialog1.ShowDialog()	
		$path.Text = $openfiledialog1.FileName
	}
	
	$log_TextChanged={
		#TODO: Place custom script here
		
	}
	
	$englishToolStripMenuItem_Click={
		#TODO: Place custom script here
		$labelSelectISO.Text = "Select ISO"
		$labelHashAlgo.Text = "Hash Algo"
		$buttonCheckISO.Text = "Check ISO"
		$script:noresult = "No result Found"
		$script:inprogress = "Hash calc in progress "
		$script:text1 = "Hash is :"
	}
	
	$francaisToolStripMenuItem_Click={
		#TODO: Place custom script here
		$labelSelectISO.Text = "Selectionner votre ISO"
		$labelHashAlgo.Text = "Algo de Hash"
		$buttonCheckISO.Text = "Vérifier ISO"
		$script:noresult = "Pas de résultat trouver"
		$script:inprogress = "Calcul Hash en cours"
		$script:text1 = "Hash est :"
	}
	
	function loadform
	{
		$syslang = (Get-WinSystemLocale).name
		
		switch -Wildcard ($syslang)
		{
			"en-*"  { & $englishToolStripMenuItem_Click }
			"es-*"  { & $espanaToolStripMenuItem_Click }
			"fr-*"  { & $francaisToolStripMenuItem_Click }
			Default { & $englishToolStripMenuItem_Click }
		}
		
		$comboBox.Items.Insert(0, "SHA1");
		$comboBox.Items.Insert(1, "SHA256");
		$comboBox.Items.Insert(2, "MD5");
		$comboBox.Items.Insert(3, "SHA512");
		$comboBox.Items.Insert(4, "MACTripleDES");
		$comboBox.SelectedIndex = 0;
		
	}
	$exitToolStripMenuItem_Click={
		#TODO: Place custom script here
		$formCheckISOAuthenticity.Close()
	}
	
	$aboutToolStripMenuItem_Click={
		#TODO: Place custom script here
		[System.Windows.Forms.MessageBox]::Show("Developped By : Dakhama Mehdi `r`nThanks to : It-connect.fr `r`n`Version 1.1 `r`nRelease   05/2024`r`nMicrosoft Windows NT 10.0.17763`r`n.NET V4.8.0", 'Check ISO')
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formCheckISOAuthenticity.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$log.remove_TextChanged($log_TextChanged)
			$combobox.remove_SelectedIndexChanged($combobox_SelectedIndexChanged)
			$buttonPath.remove_Click($buttonPath_Click)
			$buttonCheckISO.remove_Click($buttonCheckISO_Click)
			$formCheckISOAuthenticity.remove_Load($formCheckISOAuthenticity_Load)
			$exitToolStripMenuItem.remove_Click($exitToolStripMenuItem_Click)
			$englishToolStripMenuItem.remove_Click($englishToolStripMenuItem_Click)
			$francaisToolStripMenuItem.remove_Click($francaisToolStripMenuItem_Click)
			$aboutToolStripMenuItem.remove_Click($aboutToolStripMenuItem_Click)
			$formCheckISOAuthenticity.remove_Load($Form_StateCorrection_Load)
			$formCheckISOAuthenticity.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$formCheckISOAuthenticity.SuspendLayout()
	$menustrip1.SuspendLayout()
	#
	# formCheckISOAuthenticity
	#
	$formCheckISOAuthenticity.Controls.Add($log)
	$formCheckISOAuthenticity.Controls.Add($labelSelectISO)
	$formCheckISOAuthenticity.Controls.Add($menustrip1)
	$formCheckISOAuthenticity.Controls.Add($combobox)
	$formCheckISOAuthenticity.Controls.Add($labelHashAlgo)
	$formCheckISOAuthenticity.Controls.Add($buttonPath)
	$formCheckISOAuthenticity.Controls.Add($path)
	$formCheckISOAuthenticity.Controls.Add($buttonCheckISO)
	$formCheckISOAuthenticity.AutoScaleDimensions = '8, 17'
	$formCheckISOAuthenticity.AutoScaleMode = 'Font'
	$formCheckISOAuthenticity.ClientSize = '497, 344'
	$formCheckISOAuthenticity.Margin = '5, 5, 5, 5'
	$formCheckISOAuthenticity.MinimizeBox = $False
	$formCheckISOAuthenticity.Name = 'formCheckISOAuthenticity'
	$formCheckISOAuthenticity.StartPosition = 'CenterScreen'
	$formCheckISOAuthenticity.Text = 'Check ISO Authenticity v 1.1'
	$formCheckISOAuthenticity.add_Load($formCheckISOAuthenticity_Load)
	#
	# log
	#
	$log.Anchor = 'Top, Bottom, Left, Right'
	$log.Location = '13, 189'
	$log.Margin = '4, 4, 4, 4'
	$log.Name = 'log'
	$log.ReadOnly = $True
	$log.Size = '471, 142'
	$log.TabIndex = 49
	$log.Text = ''
	$log.add_TextChanged($log_TextChanged)
	#
	# labelSelectISO
	#
	$labelSelectISO.AutoSize = $True
	$labelSelectISO.BackColor = 'Transparent'
	$labelSelectISO.Font = 'Arial, 14pt'
	$labelSelectISO.ForeColor = 'Desktop'
	$labelSelectISO.Location = '8, 50'
	$labelSelectISO.Margin = '4, 0, 4, 0'
	$labelSelectISO.Name = 'labelSelectISO'
	$labelSelectISO.Size = '112, 32'
	$labelSelectISO.TabIndex = 48
	$labelSelectISO.Text = 'Select iso'
	$labelSelectISO.UseCompatibleTextRendering = $True
	#
	# menustrip1
	#
	$menustrip1.ImageScalingSize = '20, 20'
	[void]$menustrip1.Items.Add($fileToolStripMenuItem)
	[void]$menustrip1.Items.Add($languageToolStripMenuItem)
	[void]$menustrip1.Items.Add($aboutToolStripMenuItem)
	$menustrip1.Location = '0, 0'
	$menustrip1.Name = 'menustrip1'
	$menustrip1.Padding = '8, 3, 0, 3'
	$menustrip1.Size = '497, 30'
	$menustrip1.TabIndex = 47
	$menustrip1.Text = 'menustrip1'
	#
	# combobox
	#
	$combobox.Anchor = 'Top, Right'
	$combobox.DropDownStyle = 'DropDownList'
	$combobox.FormattingEnabled = $True
	$combobox.Location = '311, 137'
	$combobox.Margin = '4, 4, 4, 4'
	$combobox.Name = 'combobox'
	$combobox.Size = '173, 25'
	$combobox.TabIndex = 46
	$combobox.add_SelectedIndexChanged($combobox_SelectedIndexChanged)
	#
	# labelHashAlgo
	#
	$labelHashAlgo.Anchor = 'Top'
	$labelHashAlgo.Location = '186, 140'
	$labelHashAlgo.Margin = '4, 0, 4, 0'
	$labelHashAlgo.Name = 'labelHashAlgo'
	$labelHashAlgo.Size = '117, 26'
	$labelHashAlgo.TabIndex = 45
	$labelHashAlgo.Text = 'Hash Algo'
	$labelHashAlgo.UseCompatibleTextRendering = $True
	#
	# buttonPath
	#
	$buttonPath.Anchor = 'Top, Right'
	$buttonPath.BackColor = 'Transparent'
	$buttonPath.BackgroundImageLayout = 'Center'
	$buttonPath.FlatAppearance.BorderColor = 'White'
	$buttonPath.FlatStyle = 'Popup'
	#region Binary Data
	$buttonPath.Image = [System.Convert]::FromBase64String('
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAALGPC/xhBQAAAAlwSFlz
AAAOvAAADrwBlbxySQAAApBJREFUOE+tj8lPE1EAh1/SRA8mhngw4URQ3CjIWlp2C0EJUFoWFVFA
Ci5ggnjpgX+AhIQQMcF4QBNuxEMrKYbSasEWBlrg7L5BF0qBlkoi0vLzvcdAlXh0ki+Zyfy+782Q
/3Jpm7WbrdoWmCemsehZw5J3Ha7ldbh9AXhWgvD6g/D5A1hZDWDCJqC9rR0P7nduijohjQ2NaKLY
Z+ax6Nv4i6WVEFz+ENyrIXjXfmDGuQB22N3bdyDqhDQ33QRDcCwgHNk5QATb4Qh+bYfxc2ubHjLH
t7daWqOBhus3wHgjOPFtObCLN4CvlC/0dz571vHJvYaPrlVY7bN8yyKiTkh93TUwzJMCPPRT93D7
N+jns98I4rsvyINj1im+ZRFRJ+RK7WUwRi02zH/wYIEy/57hxhzF+Y7y1oVZygvTJN/WX62LBmqq
qsF49OQZ9GOTGDHbYXw1jdHXAoyUEcsUDCYbnr+04uHjp3zLIqJOiEZViX9SqY5y4F2NpioaUJWV
40/UFSpUqzV8VEtPY7BnJqrKK/Y3ok5IaclFMMoulcJqtcLpdHIcDgeH3QuCgBy5AnKZbH8r6oQU
FRSCUVJUDIvFgsL8Aiiy5LDb7bDZbDw6Pj6Owrx85GbnQEm3xReU0UCuIhuMgpxcmOkwIzUNyVIp
TCYTjEYj9Ho9hoeHkU2j8kwZ8liEHiLqhGSmpW/J0tL5wGAw4PTJBJyIj+fS0NAQBgcHMTAwgJSk
ZKRIk5CVngEFDYk6ITFHY+4ln0uMZKSk8vGe1N/fj97eXvT09KC7uxtnaPhswimcT5Sy0A5Vj+wW
CDkmkUjK4uLiqru6urRUaOvr6+ugdNJAB3vW6XRNscdjNYckEjWD7pWEkMO/AYgbFZ9X8PurAAAA
AElFTkSuQmCC')
	#endregion
	$buttonPath.Location = '406, 83'
	$buttonPath.Margin = '4, 4, 4, 4'
	$buttonPath.Name = 'buttonPath'
	$buttonPath.Size = '65, 30'
	$buttonPath.TabIndex = 44
	$buttonPath.UseCompatibleTextRendering = $True
	$buttonPath.UseVisualStyleBackColor = $True
	$buttonPath.add_Click($buttonPath_Click)
	#
	# path
	#
	$path.Location = '8, 87'
	$path.Margin = '5, 5, 5, 5'
	$path.Name = 'path'
	$path.ReadOnly = $True
	$path.Size = '365, 23'
	$path.TabIndex = 43
	#
	# buttonCheckISO
	#
	$buttonCheckISO.BackColor = 'Control'
	$buttonCheckISO.Cursor = 'Default'
	$buttonCheckISO.Location = '8, 131'
	$buttonCheckISO.Margin = '4, 4, 4, 4'
	$buttonCheckISO.Name = 'buttonCheckISO'
	$buttonCheckISO.Size = '110, 35'
	$buttonCheckISO.TabIndex = 42
	$buttonCheckISO.Text = 'Check ISO'
	$buttonCheckISO.UseCompatibleTextRendering = $True
	$buttonCheckISO.UseVisualStyleBackColor = $False
	$buttonCheckISO.add_Click($buttonCheckISO_Click)
	#
	# fileToolStripMenuItem
	#
	[void]$fileToolStripMenuItem.DropDownItems.Add($exitToolStripMenuItem)
	$fileToolStripMenuItem.Name = 'fileToolStripMenuItem'
	$fileToolStripMenuItem.Size = '44, 24'
	$fileToolStripMenuItem.Text = 'File'
	#
	# exitToolStripMenuItem
	#
	$exitToolStripMenuItem.Name = 'exitToolStripMenuItem'
	$exitToolStripMenuItem.Size = '108, 26'
	$exitToolStripMenuItem.Text = 'Exit'
	$exitToolStripMenuItem.add_Click($exitToolStripMenuItem_Click)
	#
	# languageToolStripMenuItem
	#
	[void]$languageToolStripMenuItem.DropDownItems.Add($englishToolStripMenuItem)
	[void]$languageToolStripMenuItem.DropDownItems.Add($francaisToolStripMenuItem)
	$languageToolStripMenuItem.Name = 'languageToolStripMenuItem'
	$languageToolStripMenuItem.Size = '86, 24'
	$languageToolStripMenuItem.Text = 'Language'
	#
	# englishToolStripMenuItem
	#
	$englishToolStripMenuItem.Name = 'englishToolStripMenuItem'
	$englishToolStripMenuItem.Size = '137, 26'
	$englishToolStripMenuItem.Text = 'English'
	$englishToolStripMenuItem.add_Click($englishToolStripMenuItem_Click)
	#
	# francaisToolStripMenuItem
	#
	$francaisToolStripMenuItem.Name = 'francaisToolStripMenuItem'
	$francaisToolStripMenuItem.Size = '137, 26'
	$francaisToolStripMenuItem.Text = 'Français'
	$francaisToolStripMenuItem.add_Click($francaisToolStripMenuItem_Click)
	#
	# aboutToolStripMenuItem
	#
	$aboutToolStripMenuItem.Name = 'aboutToolStripMenuItem'
	$aboutToolStripMenuItem.Size = '62, 24'
	$aboutToolStripMenuItem.Text = 'About'
	$aboutToolStripMenuItem.add_Click($aboutToolStripMenuItem_Click)
	#
	# openfiledialog1
	#
	$openfiledialog1.FileName = 'openfiledialog1'
	$menustrip1.ResumeLayout()
	$formCheckISOAuthenticity.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formCheckISOAuthenticity.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formCheckISOAuthenticity.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formCheckISOAuthenticity.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formCheckISOAuthenticity.ShowDialog()

} #End Function

#Call the form
Show-newcheckiso_psf | Out-Null

# SIG # Begin signature block
# MIIJWgYJKoZIhvcNAQcCoIIJSzCCCUcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbDYdJPq1L16Kh8M5SVkEEbE+
# c0OgggY5MIIGNTCCBB2gAwIBAgIQfyoncvKt5Fb0z2kmX2l/szANBgkqhkiG9w0B
# AQsFADBWMQswCQYDVQQGEwJQTDEhMB8GA1UEChMYQXNzZWNvIERhdGEgU3lzdGVt
# cyBTLkEuMSQwIgYDVQQDExtDZXJ0dW0gQ29kZSBTaWduaW5nIDIwMjEgQ0EwHhcN
# MjMxMTAyMDY1MzI1WhcNMjQxMTAxMDY1MzI0WjBbMQswCQYDVQQGEwJGUjEPMA0G
# A1UEBwwGVG91bG9uMQswCQYDVQQLDAJJVDEWMBQGA1UECgwNTWVoZGkgRGFraGFt
# YTEWMBQGA1UEAwwNTWVoZGkgRGFraGFtYTCCAaIwDQYJKoZIhvcNAQEBBQADggGP
# ADCCAYoCggGBALo0Pr3nqdSiJanBJgyOlBDxUPwY5p7JzVWVuVzUi0C4VDqbIG05
# IxilvAbKPIEt7pearp2NTjXdodrLHCV7l5qVGQ1khSNXpq4i+8lz3UCl/XZLtrnG
# 1cZnZ0R8bYD4dM6i2T//5IJA2pXtz4wiN5JAUFkiXFQuulXWm4YRxWnxmiUkU3dd
# wAdIaAtdOwDFywQLsO985w3eHX2cSTFuBU0M0E/zGK999kZ+GLRRm8YtH5jbZvrj
# keWAxov/7OdRZxE8aXg1djbckLAzzJ9DmIzcbpfd9QlUy0CfO05cjCMb7Y7MCfmO
# QfBPUagDkjaUl5Nad98u7ySUiriIG59gXHvG7oMthourKHGtcoHtTtj2VpVhFs93
# TQnlmne7tONCk2eVsR5xNlLgQ2DTwYZXXC2dtWVnQ/Ceb2NIj1T42X8sOHmc7I+j
# xMgTFSNVORT/cF+g+6lpcRjhTSjkM4PhZNdbrftm+eWngy60sFFDbRQkWf8WX3yS
# 8mhWp8BX4C1dmwIDAQABo4IBeDCCAXQwDAYDVR0TAQH/BAIwADA9BgNVHR8ENjA0
# MDKgMKAuhixodHRwOi8vY2NzY2EyMDIxLmNybC5jZXJ0dW0ucGwvY2NzY2EyMDIx
# LmNybDBzBggrBgEFBQcBAQRnMGUwLAYIKwYBBQUHMAGGIGh0dHA6Ly9jY3NjYTIw
# MjEub2NzcC1jZXJ0dW0uY29tMDUGCCsGAQUFBzAChilodHRwOi8vcmVwb3NpdG9y
# eS5jZXJ0dW0ucGwvY2NzY2EyMDIxLmNlcjAfBgNVHSMEGDAWgBTddF1MANt7n6B0
# yrFu9zzAMsBwzTAdBgNVHQ4EFgQUUwER2v3kzQRPffXLVZ5AOq1uR8MwSwYDVR0g
# BEQwQjAIBgZngQwBBAEwNgYLKoRoAYb2dwIFAQQwJzAlBggrBgEFBQcCARYZaHR0
# cHM6Ly93d3cuY2VydHVtLnBsL0NQUzATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNV
# HQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIBAGIkSoJ9ORJUN+ZYcDWJXvg7
# DsCywgCVdVzfUjO/AsVvxuAElVzA8km0LHlSMya+x10MX6livZgtXaneqtnGHsaB
# t7Edp0GNIP8pabHlLdxh1CYuqylZh9yIumvokr+SwX+S+8GQqwn6zR6o/FvvpdmI
# fbNJdoKBPkxgHyksH4hyhOIDdDiqZkRLAUvlSQEIa+N+yZNjMGmSKX/SEHyg3HZ2
# OPMdKg6+zSqnPBfiLsfD/Y+Jq1X08Nm8vLdiS1wXb7CsHv2E3lvSV+SiL4au4Psf
# J5fNItcZIHmdZScP2mfEEQrfwKr86yZPgnHXA1o7WjhCle98OtI+nwG4M/g8Rf4t
# uXGlxEo+dS7dDqdaYBAfa4UBz9HcQYYAP964cHwX104xYmI0rGcqyciaDmGXnEjW
# kPbef6Z6HEIPAFEFWKgNZeUdHQ+QBIL3eiJaysgQ/TWQwC5nFJY8oIagz/xnYXnL
# kKe8IQKbbeTCUNqqvy2LpYAwPDhYvuki3v072B2G+sDHsc7v3Q+3bgwCrYC6DDVS
# gjf+ZL2ovLpS9W1JxtJwKvSKCsmasR6ELYgJNSMwqAM2E6H2ouc2a5VTZ89+vpg6
# Fy8AexgbdjWYAFxcErh+9/Oht2WTbTmoOX/ek+GbLOyhQs8cY9jjlhUS2vJqaW3i
# R35a4z/4yPaUEWgfntHXMYICizCCAocCAQEwajBWMQswCQYDVQQGEwJQTDEhMB8G
# A1UEChMYQXNzZWNvIERhdGEgU3lzdGVtcyBTLkEuMSQwIgYDVQQDExtDZXJ0dW0g
# Q29kZSBTaWduaW5nIDIwMjEgQ0ECEH8qJ3LyreRW9M9pJl9pf7MwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFN5P8rCDo1YTp1y3nKDDRL4c1si/MA0GCSqGSIb3DQEBAQUABIIBgAqe
# pu0SJyzTFd+8h4qCCO6c3LQ/U19gF9YXlbmakisEddZ6XJMVtBl0qhNtNZoRpBOy
# 2ijqi26lUpoNovKh14ePwO2BdM4529YQook2DMmxw8CmXr8QK10V2VY+UcK8HBwL
# 9fz4lNAnpcZfzPW5duCk34MinTraTtlVGo5mNVKGHj4ynBIY7Bp6gB+6f4Qdb2lm
# cSmKBJ1JEK1cERvfw0G00fpu0JlvzCr1IwCDqvlNG86ilsz1kI3soklYXH6YN+Cg
# p38UhUlmtp8YvZse80U+Ua9uR/7g93H3Ky4kt9rH8PU4VgeS/wHJOnWmn2LhZcMb
# zlZ33IIcAqOWnnXBvM9X1dpptlHuuQkg/KG2cl9XhlnS+mfoz1Bg5uBYxZL0hVr8
# 8VnA3ABhT2NI2feNpjlxHD+cZrciIUfDyfBeC83O+pzHcbqYesgAvQ71sz2Y1s5v
# pdXpcsS9E1RZ5YBwkLIrDxgvoYkXZj71GEZbooAEck++tXaDsPLOeeHlkyHdeg==
# SIG # End signature block
