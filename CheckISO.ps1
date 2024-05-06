﻿

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
			
			#$url = 'https://www.heidoc.net/php/myvsdump_search.php?fulltext=&sha1=' + $hach.hash + '&filetype=&architecture=&language=&mindate=1998-04-22T20%3A11&maxdate=2024-03-14T23%3A11'
			
			#$var = Invoke-WebRequest $url -ErrorVariable acces -ErrorAction SilentlyContinue
			
			# En-têtes HTTP nécessaires pour la requête
			
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
			
			# Données du formulaire
			$body = "search=" + $hach.hash		
			# Envoi de la requête POST
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
	#region Binary Data
	$formCheckISOAuthenticity.Icon = [System.Convert]::FromBase64String('
AAABAAcAQEAAAAEAIAAoQgAAdgAAADAwAAABACAAqCUAAJ5CAAAoKAAAAQAgAGgaAABGaAAAICAA
AAEAIACoEAAAroIAABgYAAABACAAiAkAAFaTAAAUFAAAAQAgALgGAADenAAAEBAAAAEAIABoBAAA
lqMAACgAAABAAAAAgAAAAAEAIAAAAAAAAEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+fbN4Pvqz
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pvqz
eD59AAAAAAAAAAAAAAAAAAAAALN4PvezeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+9wAAAAAAAAAAAAAAALN4PgSzeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD4DAAAAAAAAAACzeD4Bs3g+/LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD75AAAAAAAAAAAAAAAAAAAAALN4Pq+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g///Pq4v//////////////////////////////////////////////////
////////////////////////////////////8+ri/7N4P/+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
wQAAAAAAAAAAAAAAAAAAAACzeD4rs3g++7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv/Us5P/////////////
/////////////////////////////////////////////////////////////////////////9Sz
k/+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PkMAAAAAAAAAAAAAAAAAAAAAAAAAALN4PpWzeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/uIFL//z69///////////////////////////////////////////////
//////////////////////////////z69/+4gUv/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PrEAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Ss3g+7LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv/iy7X/////////
///////////////////////////////////////////////////////////////////iy7X/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4PvOzeD4fAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pmmz
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/wpNl////////////////////////////////////////////////
////////////////////////////wpNl/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD5xAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Cs3g+zLN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7Ls3g+AwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4
PjazeD78s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD75s3g+LgAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+lLN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+fgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ALN4Pg+zeD7ls3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+0LN4PgUAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+TbN4Pv2zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/rN4PjcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAACzeD56s3g++bN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g++7N4PpwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAALN4PiGzeD60s3g+6rN4Pv6zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/rN4PuqzeD61s3g+JQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD61s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pr4A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAs3g+7bN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD72AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv2zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/wAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAACzeD7/s3g+/7N4Pv+zeD7/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////+zeD7/s3g+/7N4Pv+zeD7/AAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAALN4Pv+zeD7/s3g+/7N4Pv//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAs3g+/7N4Pv+zeD7/s3g+////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+/7N4Pv//////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AACzeD7/s3g+/7N4Pv+zeD7/////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ALN4Pv+zeD7/s3g+/7N4Pv//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
s3g+/7N4Pv+zeD7/s3g+////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+/7N4Pv//////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACz
eD7/s3g+/7N4Pv+zeD7/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4
Pv+zeD7/s3g+/7N4Pv//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+
/7N4Pv+zeD7/s3g+////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+/7N4Pv//////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/
s3g+/7N4Pv+zeD7/////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+z
eD7/s3g+/7N4Pv//////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4
Pv+zeD7/s3g+////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////+z
eD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+/7N4Pv//////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+
/7N4Pv+zeD7/////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////7N4
Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/
s3g+/7N4Pv//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////s3g+
/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD78s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+6rN4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAALN4PquzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+tAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Zs3g+qrN4
PuezeD78s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pvyz
eD7ns3g+q7N4PhwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAA////////////////////////////////////////////////////////////
/////////////////////////8AAAAAAAAADwAAAAAAAAAOAAAAAAAAAAYAAAAAAAAADwAAAAAAA
AAPAAAAAAAAAA+AAAAAAAAAH4AAAAAAAAAfwAAAAAAAAD/AAAAAAAAAP+AAAAAAAAB/8AAAAAAAA
P/wAAAAAAAA//gAAAAAAAH//AAAAAAAA/////////////wAAAAAAAP//AAAAAAAA//8AAAAAAAD/
/wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//
AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA//8A
AAAAAAD//wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAA
AAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA//8AAAAAAAD//wAAAAAAAP//AAAA
AAAA//8AAAAAAAD//wAAAAAAAP//AAAAAAAA////////////////////////////////////////
//////////////8oAAAAMAAAAGAAAAABACAAAAAAAIAlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4PmyzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PlQAAAAAs3g+AbN4PvqzeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
PtcAAAAAs3g+BbN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4PtsAAAAAAAAAALN4PtqzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pr4AAAAAAAAAALN4Plez
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv/avqL/////////////////////////////////////////////////////////////////0KuH
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4PksAAAAAAAAAALN4PgGzeD7Is3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+8iFX//v39////////////////////////////////////
///////////////////69vL/tX1F/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+uQAAAAAAAAAAAAAAAAAAAACzeD42s3g+/bN4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/6NbF////////
///////////////////////////////////////////////dw6r/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD71s3g+IwAAAAAAAAAAAAAA
AAAAAAAAAAAAs3g+nbN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/uYRP//////////////////////////////////////////////////////+3
gEr/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD53AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+FLN4PuyzeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4PsyzeD4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4
PmOzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g++bN4Pi4AAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAALN4PgGzeD67s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+iAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Xs3g+trN4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD63s3g+EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Js3g+
kLN4PuSzeD78s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/LN4PuSzeD6Qs3g+CQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAACzeD6Ss3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+kgAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7ns3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+5wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACz
eD7/s3g+/7V8Q///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////7V8Q/+zeD7/s3g+
/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAACzeD7/s3g+/7V8Q///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////7V8Q/+z
eD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8
Q///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/
s3g+/7V8Q///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////7V8Q/+zeD7/s3g+/wAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AACzeD7/s3g+/7V8Q///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////7V8Q/+zeD7/
s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////7V8
Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+
/7V8Q///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7V8Q///////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACz
eD7/s3g+/7V8Q///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////7V8Q/+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD78s3g+/7V8Q///////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////7V8Q/+zeD7/s3g+
/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7ns3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+5wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAACzeD6Ss3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+kgAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD4Js3g+kLN4PuSzeD78s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/LN4PuSz
eD6Qs3g+CQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////////AAD///////8AAP///////wAA
////////AACAAAAAAAEAAAAAAAAAAQAAAAAAAAABAACAAAAAAAEAAIAAAAAAAQAAgAAAAAADAADA
AAAAAAMAAOAAAAAABwAA4AAAAAAHAADwAAAAAA8AAPAAAAAAHwAA+AAAAAAfAAD///////8AAP//
/////wAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAA
AAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAA
AB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAA
HwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA+AAAAAAfAAD4AAAAAB8AAPgAAAAAHwAA////////
AAD///////8AAP///////wAAKAAAACgAAABQAAAAAQAgAAAAAABAGgAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAs3g+urN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PqoA
AAAAs3g+A7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7xAAAAALN4PgGzeD7u
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/z6qF////////
///////////////////////////////////////////////KoHj/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+4QAAAAAAAAAAs3g+dLN4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7V8RP/59PD/////////////////
///////////////////////////17uf/s3lA/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4PngAAAAAAAAAALN4PgezeD7cs3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/07GP////////////////////////////////
////////////z6qG/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4PtuzeD4HAAAAAAAAAAAAAAAAs3g+S7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv6zeD5CAAAA
AAAAAAAAAAAAAAAAAAAAAACzeD6vs3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD6ZAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAs3g+HLN4PvKzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7gs3g+DQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACz
eD5ms3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+TgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4PpSzeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD6JAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ALN4Pv+zeD7/s3g+////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4
Pv//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////7N4Pv+zeD7/
s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////+zeD7/s3g+/7N4Pv8AAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAs3g+/7N4Pv+zeD7/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/
s3g+////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////s3g+/7N4
Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv//////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////7N4Pv+zeD7/s3g+/wAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAACzeD7/s3g+/7N4Pv//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4
Pv+zeD7/////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////+zeD7/
s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////s3g+/7N4Pv+zeD7/AAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv//////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////+zeD7/s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAALN4Pv+zeD7/s3g+////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/
s3g+/7N4Pv//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////7N4
Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv8A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/AAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD6us3g+/rN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD79s3g+owAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAD//////wAAAP//////AAAA//////8AAAD//////wAAAIAAAAABAAAA
AAAAAAEAAAAAAAAAAQAAAIAAAAABAAAAgAAAAAEAAADAAAAAAwAAAOAAAAAHAAAA4AAAAAcAAADw
AAAADwAAAP//////AAAA8AAAAA8AAADwAAAADwAAAPAAAAAPAAAA8AAAAA8AAADwAAAADwAAAPAA
AAAPAAAA8AAAAA8AAADwAAAADwAAAPAAAAAPAAAA8AAAAA8AAADwAAAADwAAAPAAAAAPAAAA8AAA
AA8AAADwAAAADwAAAPAAAAAPAAAA8AAAAA8AAADwAAAADwAAAPAAAAAPAAAA8AAAAA8AAADwAAAA
DwAAAPAAAAAPAAAA8AAAAA8AAADwAAAADwAAAP//////AAAA//////8AAAD//////wAAACgAAAAg
AAAAQAAAAAEAIAAAAAAAgBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAACzeD7Ws3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+zrN4Pv6zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD73s3g+w7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv/exa3/9e7m//Xu5v/17ub/9e7m//Xu
5v/17ub/9e7m//Xu5v/cwqf/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4PsWzeD43s3g+/bN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/8eccv//////
/////////////////////////////////////8WYbP+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7+s3g+PQAAAACzeD6ds3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/+bTwP/s3c7/7N3O/+zdzv/s3c7/7N3O/+zdzv/k0Lz/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PpwAAAAAAAAAALN4PhWzeD7ss3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7ks3g+EAAAAAAAAAAAAAAAALN4
PmKzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/rN4PksAAAAA
AAAAAAAAAAAAAAAAAAAAALN4PqOzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD6jAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD5ls3g+7LN4Pv2z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PvyzeD7rs3g+YgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ALN4PsOzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7CAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////s3g+
/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
s3g+/7N4Pv//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////s3g+/7N4Pv8AAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////+zeD7/
s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4Pv+zeD7/////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////7N4Pv+zeD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv//////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACz
eD7/s3g+////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAALN4Pv+zeD7/////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////7N4Pv+z
eD7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv//////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////s3g+/7N4Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4
Pv+zeD7/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////7N4Pv+zeD7/AAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAs3g+/7N4Pv//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////s3g+/7N4
Pv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALN4PsOzeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+
ZbN4PuyzeD79s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD78s3g+67N4PmIAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////////////////AAAAAAAAAAAAAAAAAAAAAIAA
AAGAAAABwAAAA+AAAAf/////4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAA
B+AAAAfgAAAH4AAAB+AAAAfgAAAH4AAAB+AAAAfgAAAH//////////8oAAAAGAAAADAAAAABACAA
AAAAAGAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAs3g+1LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7Us3g+27N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7ds3g+YbN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv/DlGf/////////////////////////////////w5Rn/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD5ts3g+AbN4PsizeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/1reY////////////
///////////Wt5j/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4PsmzeD4DAAAAALN4PjCz
eD77s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4Pv+zeD7/s3g++LN4PisAAAAAAAAAAAAAAACzeD54s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
s3g+eQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AACzeD5Xs3g+/LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD78s3g+WgAAAAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////////////
//////////////////////////////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAA
AAAAAACzeD7/s3g+////////////////////////////////////////////////////////////
//////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////
////////////////////////////////////////////////////////////////////////////
//+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////////
//////////////////////////////////////////////////////+zeD7/s3g+/wAAAAAAAAAA
AAAAAAAAAACzeD7/s3g+////////////////////////////////////////////////////////
//////////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////
////////////////////////////////////////////////////////////////////////////
//////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////////
//////////////////////////////////////////////////////////+zeD7/s3g+/wAAAAAA
AAAAAAAAAAAAAACzeD7/s3g+////////////////////////////////////////////////////
//////////////////////////////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+
////////////////////////////////////////////////////////////////////////////
//////////+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD7/s3g+////////////////////////
//////////////////////////////////////////////////////////////+zeD7/s3g+/wAA
AAAAAAAAAAAAAAAAAACzeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/wAAAAAAAAAAAAAAAAAAAACzeD5X
s3g+/LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD78s3g+WgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////AAAAAAAA
AAAAAAAAAAAAAACAAAEAwAADAP///wDAAAMAwAADAMAAAwDAAAMAwAADAMAAAwDAAAMAwAADAMAA
AwDAAAMAwAADAMAAAwDAAAMAwAADAP///wD///8AKAAAABQAAAAoAAAAAQAgAAAAAACQBgAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+9rN4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
PvWzeD72s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/////////////////////////////////s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+9bN4Pt6zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv/avaH/
/////////////////////9m8n/+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7hs3g+VbN4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4
Pv+zeD7/s3g+/7N4PlgAAAAAs3g+urN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD6zAAAAAAAAAACzeD4is3g+5bN4Pv+zeD7/
s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+6bN4PhsA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+BLN4Ps+zeD79s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/LN4Ps4AAAAAAAAAAAAAAACzeD4F
s3g+/9S0k//kz7v/5M+7/+TPu//kz7v/5M+7/+TPu//kz7v/5M+7/+TPu//kz7v/5M+7/+TPu//U
s5L/s3g+/7N4PgcAAAAAAAAAALN4PgWzeD7/59TC////////////////////////////////////
/////////////////////////////+bTwP+zeD7/s3g+BwAAAAAAAAAAs3g+BbN4Pv/n1ML/////
////////////////////////////////////////////////////////////5tPA/7N4Pv+zeD4H
AAAAAAAAAACzeD4Fs3g+/+fUwv//////////////////////////////////////////////////
///////////////m08D/s3g+/7N4PgcAAAAAAAAAALN4PgWzeD7/59TC////////////////////
/////////////////////////////////////////////+bTwP+zeD7/s3g+BwAAAAAAAAAAs3g+
BbN4Pv/n1ML/////////////////////////////////////////////////////////////////
5tPA/7N4Pv+zeD4HAAAAAAAAAACzeD4Fs3g+/+fUwv//////////////////////////////////
///////////////////////////////m08D/s3g+/7N4PgcAAAAAAAAAALN4PgWzeD7/59TC////
/////////////////////////////////////////////////////////////+bTwP+zeD7/s3g+
BwAAAAAAAAAAs3g+BbN4Pv/UtJP/5M+7/+TPu//kz7v/5M+7/+TPu//kz7v/5M+7/+TPu//kz7v/
5M+7/+TPu//kz7v/1LOS/7N4Pv+zeD4GAAAAAAAAAAAAAAAAs3g+z7N4Pv2zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD78s3g+zgAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAD///AAAAAAAAAAAAAAAAAAAAAAAIAAEACAABAA///wAIAAMACAABAA
gAAQAIAAEACAABAAgAAQAIAAEACAABAAgAAQAIAAEADAADAA///wACgAAAAQAAAAIAAAAAEAIAAA
AAAAQAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAs3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/
////////////////////////////////s3g+/7N4Pv+zeD7/s3g+/7N4Pv8AAAAAs3g+97N4Pv+z
eD7/s3g+/7+OXv//////////////////////v45d/7N4Pv+zeD7/s3g+/7N4PvcAAAAAAAAAALN4
Pn6zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD53AAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAACzeD4Bs3g+9LN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+z
eD7/s3g+/7N4PvWzeD4Ds3g+BbN4Pv/q2cn/8+ri//Pq4v/z6uL/8+ri//Pq4v/z6uL/8+ri//Pq
4v/z6uL/8+ri/+rZyf+zeD7/s3g+CbN4PgWzeD7/8+vi////////////////////////////////
///////////////////////z6+L/s3g+/7N4PgmzeD4Fs3g+//Pr4v//////////////////////
////////////////////////////////8+vi/7N4Pv+zeD4Js3g+BbN4Pv/z6+L/////////////
//////////////////////////////////////////Pr4v+zeD7/s3g+CbN4PgWzeD7/8+vi////
///////////////////////////////////////////////////z6+L/s3g+/7N4PgmzeD4Fs3g+
//Pr4v//////////////////////////////////////////////////////8+vi/7N4Pv+zeD4J
s3g+BbN4Pv/z6+L///////////////////////////////////////////////////////Pr4v+z
eD7/s3g+CbN4PgWzeD7/6tnJ//Pq4v/z6uL/8+ri//Pq4v/z6uL/8+ri//Pq4v/z6uL/8+ri//Pq
4v/q2cn/s3g+/7N4PgkAAAAAs3g+4rN4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+/7N4Pv+zeD7/s3g+
/7N4Pv+zeD7/s3g+/7N4PuOzeD4B//8AAAAAAAAAAAAAgAEAAIABAAD//wAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAA==')
	#endregion
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
