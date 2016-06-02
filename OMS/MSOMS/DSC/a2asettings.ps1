### Setup of A2A Coordinater

param (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,
        $OMSResourceGroupName,
        $OMSRecoveryVaultName      
      )

# Install AzureRM modules for A2A scenario

Find-module -Name AzureRm.SiteRecovery | Install-Module -Force

Find-Module -Name AzureRm.RecoveryServices | Install-Module -Force

find-module -Name AzureRm.RecoveryServices.Backup | Install-Module -Force

# Login to Azure and download the vault credentials

Login-AzureRmAccount -Credential $Admincreds

$vault = Get-AzureRmRecoveryServicesVault -ResourceGroupName $OMSResourceGroupName -Name $OMSRecoveryVaultName

Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault -Path c:\a2a\

# That's it!
