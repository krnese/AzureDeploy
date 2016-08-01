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
$subscriptionId = 'a99e517f-8c60-46d3-b17f-f7fb94a5f45'
$OMSWorkspaceId = '89815b96-d7f5-472a-b6d4-5a9b6a53645c'
$OMSWorkspaceKey = 'JlQGoA4s3L3/kxZFkQjHsMLUVa1UG2V3jprplGS4F4b+kaX/n+EFn4Y/CMCp+K3epHMOMSY8YuH8GKief5R/SQ=='
$OMSWorkspaceName = 'knomsla'
$OMSResourceGroupName = 'knoms'
$OMSRecoveryVault = 'knrecovery'

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

$location = $vault.Location
Set-AzureRmRecoveryServicesVaultContext -Vault $vault

$con = Get-AzureRmSiteRecoveryProtectionContainer

if ([string]::IsNullOrEmpty($con) -eq $true)

{
    Write-Output "ASR Recovery Vault isn't completely configured yet. No data to ingest at this point"
}
else {

$DRServer = Get-AzureRmSiteRecoveryServer

$heartbeat = ([datetime]$DRServer.LastHeartbeat).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
	$Table = @()
foreach ($c in $con) {
    $protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity -ProtectionContainer $c

    if ($protectionentity.ReplicationProvider -eq "InMageAzureV2") {
        foreach ($entity in $protectionEntity) {
            $sx = New-Object PSObject -Property @{
            VMName = $entity.FriendlyName;
            ResourceGroup = $ResourceGroup;
            RecoveryVault = $vault.Name;
            ProtectionState = $entity.ProtectionStateDescription;
            ReplicationHealth = $entity.ReplicationHealth;
            ReplicationProvider = $entity.ReplicationProvider;
            ActiveLocation = $entity.ActiveLocation;
            TestFailoverStateDescription = $entity.TestFailoverDescription
	    }
	    $table = $table += $sx
 
      $jsonTable = ConvertTo-Json -InputObject $table
	    }
    
	$jsonTable
 
    $logType = "ASRDiscovery1"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable -logType $logType
 }
 else {



	foreach($entity in $protectionEntity) { 
	    $sx = New-Object PSObject -Property @{
	        ResourceGroup = $ResourceGroup;
            RecoveryVault = $vault.Name;      
            VMName = $entity.FriendlyName;
	        ProtectionStatus = $entity.ProtectionStatus; 
	        ReplicationProvider = $entity.ReplicationProvider;
	        ActiveLocation = $entity.ActiveLocation;
            ReplicationHealth = $entity.ReplicationHealth;
            Disks = $entity.Disks.name;
            TestFailoverStateDescription = $entity.TestFailoverStateDescription;
            ProtectionContainerId = $entity.ProtectionContainerId;
            SiteRecoveryServerLastHeartbeat = $heartbeat;
            SiteRecoveyServerConnectionStatus = $drserver.Connected;
            SiteRecoveryServerProviderVersion = $drserver.ProviderVersion;
            SiteRecoveryServerServerVersion = $drserver.ServerVersion;
            SiteRecoveryServer = $DRServer.FriendlyName
             
	    }
	    $table = $table += $sx
 
      $jsonTable = ConvertTo-Json -InputObject $table
	   }
    $jsontable
    $logType = "ASRDiscovery1"
Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable -logType $logType
    }
   }
   }


# Fetching information from protected Machines 

#$RecoveryVaultLog = Get-AzureRmLog -ResourceId $ResourceId -StartTime $timestamp.AddDays(-13)

#$recoveryVm = Get-AzureRmSiteRecoveryVM -ProtectionContainer $con | where-object {$_.RecoveryAzureStorageAccount -ne $null }

$Table2 = @()
    foreach ($c in $con) {
    $recoveryVm = Get-AzureRmSiteRecoveryVM -ProtectionContainer $c | where-object {$_.ProtectionStatus -eq "Protected"}
	foreach($rVm in $recoveryVm) { 
        
       if ($rvm.ReplicationProvider -eq "InMageAzureV2")
       {

            $vnetInfo = "None"
            $vnetRgName = "None"
            $storageInfo = "None"
            $storageRgName = "None"
            $storageName = "None"
            
            $sx2 = New-Object PSObject -Property @{
	        VMName = $rVm.FriendlyName;
            vNetName = $vnetInfo;
            vNetResourceGroup = $vnetRgName;
            StorageResourceGroup = $storageRgName;
            StorageAccount = $storageName;
            ReplicationHealth = $rVm.ReplicationHealth;
            RecoveryAzureVMSize = $rVm.RecoveryAzureVMSize;
            RecoveryAzureVMName = $rVm.RecoveryAzureVMName;
            ActiveLocation = $rVm.ActiveLocation;
            TestFailoverStateDescription = $rVm.TestFailoverStateDescription;
            ReplicationProvider = $rVm.ReplicationProvider;
            ProtectionStatus = $rVm.ProtectionStatus             
	            }
        
	    $table2 = $table2 += $sx2 
 
      $jsonTable2 = ConvertTo-Json -InputObject $table2

      $logType2 = "ASRProtection1"      
            
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable2 -logType $logType2
                   }         
        else {

        $vnetInfo = $rVm.SelectedRecoveryAzureNetworkId.split("/")

        $vnetRgName = $vnetInfo[4]

        $vnetName = $vnetInfo[8]

        $storageInfo = $rVm.RecoveryAzureStorageAccount.split("/")

        $storageRgName = $storageInfo[4]

        $storageName = $storageInfo[8]

	    $sx2 = New-Object PSObject -Property @{
	        VMName = $rVm.FriendlyName;
            vNetName = $vnetName;
            vNetResourceGroup = $vnetRgName;
            StorageResourceGroup = $storageRgName;
            StorageAccount = $storageName;
            ReplicationHealth = $rVm.ReplicationHealth;
            RecoveryAzureVMSize = $rVm.RecoveryAzureVMSize;
            RecoveryAzureVMName = $rVm.RecoveryAzureVMName;
            ActiveLocation = $rVm.ActiveLocation;
            TestFailoverStateDescription = $rVm.TestFailoverStateDescription;
            ReplicationProvider = $rVm.ReplicationProvider;
            ProtectionStatus = $rVm.ProtectionStatus             
	            }
	    $table2 = $table2 += $sx2
 
      $jsonTable2 = ConvertTo-Json -InputObject $table2
	        
	$jsonTable2
        
$logType2 = "ASRProtection1"

Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable2 -logType $logType2
            }
        }
    }
        
    
  
# Fetching information from ASR Jobs

$jobs = Get-AzureRmSiteRecoveryJob

	# Format Jobs into a table.
	$Table3 = @()
	foreach($job in $jobs) { 
    $starttime = ([datetime]$job.StartTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
    if ($job.EndTime -eq $null)
    { "Ignore"}
    else {
    $endtime = ([datetime]$job.EndTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
    }

	    $sx3 = New-Object PSObject -Property @{
	        JobName = $job.DisplayName;
            JobType = $job.JobType;
            State = $job.State;
            StateDescription = $job.StateDescription;
            TargetObjectName = $job.TargetObjectName;
            TargetObjectType = $job.TargetObjectType;
            AllowedActions = $job.AllowedActions;
            Errors = $job.Errors;
            Tasks = $job.Tasks;
            StartTime = $starttime;
            EndTime = $endtime;
            ID = $job.ID;             
	    }
	    $table3 = $table3 += $sx3
 
      $jsonTable3 = ConvertTo-Json -InputObject $table3
	}
	$jsonTable3

$logType3 = "ASRJobHistory1"

Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable3 -logType $logType3

# Capacity planning

$vmSize = Get-AzureRmVMSize -Location $location

$currentUsage = Get-AzureRmVMUsage -Location $location
$currentStorage = Get-AzureRmStorageUsage 
$allvms = Get-AzureRmVM | measure

                                     
$Table4  = @()
foreach ($c in $con) {
    $recoveryVmSize = Get-AzureRmSiteRecoveryVM -ProtectionContainer $c
        foreach ($vmSize in $recoveryVmSize) { 
            $sizeobj = Get-AzureRmVMSize -location $location | where-object {$_.Name -eq $vmSize.RecoveryAzureVmSize }
            $usage = Get-AzureRmVMUsage -Location $location 
                $sx4  = `
                New-Object PSObject -Property @{ 
                                   'NumberOfCores'        = $sizeobj.NumberOfCores;
                                   'VMName'             = $vmsize.FriendlyName;
                                   'VMSize'       = $vmsize.RecoveryAzureVMSize;
                                   'AzureSubscriptionVMCoresInUse' = $usage[1].CurrentValue;
                                   'AzureSubscriptionVMCoresTotalLimit' = $usage[1].Limit;
                                   'AzureSubscriptionVMsInUse' = $usage[2].CurrentValue;
                                   'AzureSubscriptionVMsTotalLimit' = $usage[2].Limit;
                                   'AzureSubscriptionStandard_DScoresTotalLimit' = $usage[4].Limit;
                                   'AzureSubscriptionStandard_DcoresTotalLimit' = $usage[5].Limit;
                                   'AzureSubscriptionStandard_AcoresTotalLimit' = $usage[6].Limit;
                                   'RecoveryVaultRegion' = $location;
                                   'CurrentVMsAcrossSubscription' = $allvms.Count;
                                   'CurrentStorageAccountsAcrossSubscription' = $currentStorage.CurrentValue;
                                   'StorageAccountLimit' = $currentStorage.Limit
                                   }
                       $table4 = $table4 += $sx4
                $jsonTable4 = ConvertTo-Json -InputObject $Table4
            }
        }
$jsontable4


$logType4 = "ASRCapacityPlanning1"

Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable4 -logType $logType4



#$logType5 = "ASRRecommendations"

#Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable5 -logType $logType5

#$logtype6 = "ASRVMware1"

#Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $arm4 -logType $logtype6