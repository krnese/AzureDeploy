<#
.Synopsis
   Runbook for automated Hyper-V 2 Azure VM protection for Windows VMs using Hyper-V Replica on-prem and Azure Recovery Services through OMS
.DESCRIPTION
   This Runbook will enable Protection on registered VMs on your Hyper-V host that has been associated to a Recovery Vault in Azure Recovery Services (OMS).
   You need to specify ResourceGroup that contains the Recovery Vault, location for the vault, the Recovery Vault itself and the name of the Hyper-V Site.
   The Parameters for ExistingStorageAccountName and ExistingStorageResourceGroupName should only be used if you want to use an existing storage account as target for the replication.
   If you leave these blank, the script will create a unique Resource Group with storage accounts per VM that is being protected. 

.EXAMPLE for creating a unique storage accounts per VM
   .\VM-Protection-Param.ps1 -ResourceGroup <name of Vault ResourceGroup> -location <Recovery Vault location> -recoveryvauilt <Recovery Vault name> -sitename <name of Hyper-V site>

.EXAMPLE for enabling protection using an existing storage account
   .\VM-Protection-Param.ps1 -ResourceGroup <name of vault ResourceGroup> -location <Recovery vault location> -recoveryvault <Recovery vault name> -sitename <name of Hyper-V site> `
   -ExistingStorageAccountName <name of existing storage account> -ExistingStorageResourceGroupName <name of existing Resource Group for storage account>
#>

param
    (
        [Parameter(Mandatory=$false)]
        [string]$ResourceGroup='drgroup',

        [Parameter(Mandatory=$false)]
        [string]$location='westeurope',

        [Parameter(Mandatory=$false)]
        [String]$recoveryvault='hyperv',

        [Parameter(Mandatory=$false)]
        [string]$sitename='knhvsite',

        [Parameter(Mandatory=$false)]
        [string]$ExistingStorageAccountName,

        [Parameter(Mandatory=$false)]
        [string]$ExistingStorageResourceGroupName
    )

# Set Error Action Preference

$ErrorActionPreference = "Stop"

#region Azure login
# Logon to Azure and set the subscription context

$Admin = Get-AutomationPSCredential -Name AzureAdmin
$Subscription = Get-AutomationVariable -Name SubscriptionID

try
    {
        Login-AzureRmAccount -Credential $Admin -ErrorAction Stop

        Select-AzureRmSubscription -SubscriptionId $Subscription -ErrorAction Stop              
    }

catch

    {
    
        $ErrorMessage = 'Login to Azure failed beyond recognition.'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
    }
#endregion

#region Get Azure Recovery Services Vault settings

try

    {
        $vault = Get-AzureRmRecoveryServicesVault `
                     -Name $recoveryvault -ResourceGroupName $ResourceGroup
    }

catch

    {
        $ErrorMessage = 'Failed to retrieve the Recovery Services Vault'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
    }

# Creating a temp directory to store the VaultSettingsFile

$tempFileName = $env:TEMP

$FilePath = Get-AzureRmRecoveryServicesVaultSettingsFile `
                     -Vault $vault -Path $tempFileName | % FilePath # changed this to make sure we get the right filepath

Import-AzureRmSiteRecoveryVaultSettingsFile `
                     -Path $FilePath

$SiteIdentifier = Get-AzureRmSiteRecoverySite `
                     -Name $sitename | Select -ExpandProperty SiteIdentifier

Get-AzureRmRecoveryServicesVaultSettingsFile `
                     -Vault $vault -SiteIdentifier $SiteIdentifier -SiteFriendlyName $sitename -Path $tempFileName

# Get Azure Site Recovery Protection Container

$protectionContainer = Get-AzureRmSiteRecoveryProtectionContainer

# Get Recovery Policy

$policy = Get-AzureRmSiteRecoveryPolicy

#endregion 

#region Find all VMs that's currently registered on the Hyper-V host - and enable Protection with Hyper-V Replica

$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity `
                     -ProtectionContainer $protectionContainer | Where-Object {$_.FriendlyName -like "*asr*" -and $_.ProtectionStatus -eq "Unprotected"}
#endregion 

#region Enabling VM protection with unique storage account per VM

if ([string]::IsNullOrEmpty($ExistingStorageAccountName) -eq $true)
    
    {
    
    foreach ($entity in $protectionEntity)
    
        {
    
            if ($protectionEntity.ProtectionStatus -eq "Unprotected")
    
            {

                Write-Output "Found machines that aren't protected!"
			    Write-Output "Creating a new storage account"

        # Creating a unique string for Storage Account name
            $StorageResourceGroup = New-AzureRmResourceGroup -Name $entity.FriendlyName -Location $location
            $storagename = $entity.FriendlyName.Split('-')
            $storagename = $storagename
            $Length =$Length-1
            $charSet = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
            $RandomString=[String]::Join('', (4..$Length5 | % { $charSet | Get-Random -ErrorAction Stop }))
            $Storagename = $storagename[0] + $RandomString

		    $storageaccountID = New-AzureRmStorageAccount `
                     -Name $storagename.ToLower() `
                     -ResourceGroupName $StorageResourceGroup.ResourceGroupName `
                     -location $location -type 'Standard_LRS'  | Select -ExpandProperty Id 
            
            Write-Output "$storageaccountID created!"
            
            Write-Output "Enabling protection using unique storage accounts"

            Set-AzureRmSiteRecoveryProtectionEntity `
                     -ProtectionEntity $entity `
                     -Policy $Policy `
                     -Protection Enable `
                     -RecoveryAzureStorageAccountId $storageaccountID `
                     -OS Windows `
                     -OSDiskName $protectionEntity.Disks[0].Name `
                     -ErrorAction Stop

            }


            else
            
            {

                Write-Output "Protection already enabled"
            
            }
        
        }

   }
#endregion 

#region Enable VM Protection using existing storage account

else 

   {

            Write-Output "Fetching the existing storage account"
            $StorageAccountID = Get-AzureRmStorageAccount `
                     -Name $ExistingStorageAccountName `
                     -ResourceGroupName $ExistingStorageResourceGroupName | Select -ExpandProperty Id
            
            foreach ($entity in $protectionEntity)

        {
            Write-Output "Enabling protection using existing storage account"
            Set-AzureRmSiteRecoveryProtectionEntity `
                     -ProtectionEntity $entity `
                     -Policy $policy `
                     -Protection Enable `
                     -RecoveryAzureStorageAccountId $storageaccountID `
                     -OS Windows `
                     -OSDiskName $protectionEntity.Disks[0].Name `
                     -ErrorAction Stop

        }
   
   } 

#endregion 