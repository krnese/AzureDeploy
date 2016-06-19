<#
.Synopsis
   Runbook for OMS ASR Log Ingestion
.DESCRIPTION
   This Runbook will ingest ASR related logs to OMS Log Analytics. 

.EXAMPLE for creating a unique storage accounts per VM
   .<placeholder>

.EXAMPLE for enabling protection using an existing storage account
   .<placeholder>
#>


# Set Error Action Preference

$ErrorActionPreference = "Stop"

#region Azure login
# Logon to Azure and set the subscription context

$credential = Get-AutomationPSCredential -Name 'AzureCredentials'
$subscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionID'
$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$OMSWorkspaceName = Get-AutomationVariable -Name 'OMSWorkspaceName'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
$OMSRecoveryVault = Get-AutomationVariable -Name 'OMSRecoveryVault'

try
    {
        Add-AzureRmAccount -Credential $credential 
        Select-AzureRmSubscription -SubscriptionId $subscriptionId      
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
                     -Name $OMSRecoveryVault -ResourceGroupName $OMSResourceGroupName
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


Set-AzureRmSiteRecoveryVaultSettings -ARSVault $vault

$con = Get-AzureRmSiteRecoveryProtectionContainer

if ([string]::IsNullOrEmpty($con) -eq $true)

{
    Write-Output "ASR Recovery Vault isn't completely configured yet. No data to ingest at this point"
}
else {

$protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity `
                    -ProtectionContainer $con


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


#Log type is name of the event type that is being submitted 
$logType = "ASRProtectionStatus"
#endregion


	#Post the data to the endpoint 
	Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable -logType $logType
}
#endregion

#Finish up with a sleep for 10 mins

