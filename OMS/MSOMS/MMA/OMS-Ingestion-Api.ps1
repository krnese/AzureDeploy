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
        [string]$ResourceGroup='knoms',

        [Parameter(Mandatory=$false)]
        [string]$location='westeurope',

        [Parameter(Mandatory=$false)]
        [String]$recoveryvault='knrecovery',

        [Parameter(Mandatory=$false)]
        [string]$sitename='denmark'
    )

# Set Error Action Preference

$ErrorActionPreference = "Stop"

#region Azure login
# Logon to Azure and set the subscription context

$Admin = get-credential -Credential automation@kristianneseoutlook.onmicrosoft.com

try
    {
        Login-AzureRmAccount -Credential $Admin -ErrorAction Stop
        $subscriptionId = (Get-AzureRmSubscription).SubscriptionId      
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

# setting vault context

$vault = get-azurermrecoveryservicesvault -ResourceGroupName $ResourceGroup -Name $recoveryvault

Set-AzureRmSiteRecoveryVaultSettings -ARSVault $vault

$con = Get-AzureRmSiteRecoveryProtectionContainer

$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity `
                     -ProtectionContainer $con
$VMUsage = Get-AzureRmVMUsage -Location $location

$StorageUsage = Get-AzureRmStorageUsage

$resourceId = '/subscriptions/' + $subscriptionId + '/resourceGroups/' + $ResourceGroup + '/providers/Microsoft.RecoveryServices/' + 'vaults/' + $recoveryvault
Get-AzureRmLog -ResourceId $resourceId -StartTime (Get-Date).AddDays(-1)


	# Format metrics into a table.
	$Table = @()
	foreach($entity in $protectionEntity) { 
	    $sx = New-Object PSObject -Property @{
	        ResourceGroup = $ResourceGroup;
            RecoveryVault = $vault.Name;            
            VMName = $entity.FriendlyName;
	        ProtectionStatus = $entity.ProtectionStatus; 
	        RecplicationProvider = $entity.ReplicationProvider;
	        ActiveLocation = $entity.ActiveLocation;
            ReplicationHealth = $entity.ReplicationHealth;
            Disks = $entity.Disks.name;
            CurrentlyUsedCores = $VMUsage 
	    }
	    $table = $table += $sx
 
      $jsonTable = ConvertTo-Json -Depth 4 -InputObject $table
	}
	$jsonTable

#region Variables definition
# Variables definition
                     # pool name

#Update customer Id to your Operational Insights workspace ID
$customerID = 'ae899540-3db6-4ce3-885c-ec1a1f5cb15c'

#For shared key use either the primary or seconday Connected Sources client authentication key   
$sharedKey = 'X/tApjZKRL+trjKoHcZwHRfnENvGlkgHaopHQYMwrAeXgKlzP9VYe6FDavYza//fyKsclcX/ZzRBVvGhYRd5OA=='

#Log type is name of the event type that is being submitted 
$logType = "ASRProtectionStatus"
#endregion


	#Post the data to the endpoint 
	Send-OMSAPIIngestionData -customerId $customerId -sharedKey $sharedKey -body $jsonTable -logType $logType

#endregion

#Finish up with a sleep for 10 mins
Write-output "Next run $([DateTime]::Now.Add([TimeSpan]::FromMinutes(10))) UTC"
