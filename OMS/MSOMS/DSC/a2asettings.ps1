### Setup of A2A Coordinater

param (
        [Parameter(Mandatory=$true)]
        $AzureSubAdmin,
        [Parameter(Mandatory=$true)]
        $AzureAdminPwd,
        [Parameter(Mandatory=$true)]
        $OMSResourceGroupName,
        [Parameter(Mandatory=$true)]
        $OMSRecoveryVaultName      
      )

# Install AzureRM modules for A2A scenario

Write-Output "Now we'll download and install some required Azure PS Modules for you to proceed"

Find-module -Name AzureRm.SiteRecovery | Install-Module -Force -Verbose

Find-Module -Name AzureRm.RecoveryServices | Install-Module -Force -Verbose

find-module -Name AzureRm.RecoveryServices.Backup | Install-Module -Force -Verbose

# Login to Azure and download the vault credentials

Write-Output "We'll connect to your Azure Subscription and download the vault settings"

$AzureAdminPwd = ConvertTo-SecureString $AzureAdminPwd -AsPlainText -Force
$Admincreds = New-Object System.Management.Automation.PSCredential (“$AzureSubAdmin”, $AzureAdminPwd)

Login-AzureRmAccount -Credential $Admincreds

$vault = Get-AzureRmRecoveryServicesVault -ResourceGroupName $OMSResourceGroupName -Name $OMSRecoveryVaultName

Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault -Path "c:\a2a\"

# Creates a shortcut on the desktop to A2A setup

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("\\$env:COMPUTERNAME\C$\Users\Public\Desktop\Azure2AzureSetup.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
$Shortcut.IconLocation = "C:\A2A.ico,0"
$Shortcut.Arguments = "portal.azure.com"
$Shortcut.Save()

# Disable IE Enhanced Security

$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer

Write-Output "Restarting computer in 10 seconds to complete the setup...`n

When you log on to your machine again, join an existing Domain if required and run the A2A setup located in C:\A2A"

Start-Sleep -Seconds 10

Restart-Computer -Force

# That's it!


