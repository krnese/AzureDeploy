$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

# Getting automation variables from the Autoamtion Account

$OMSWorkspaceId = Get-AutomationVariable -Name 'asrOMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'asrOMSWorkspaceKey'
$AzureSubscriptionId = Get-AutomationVariable -Name 'asrAzureSubscriptionId'
$VaultName = Get-AutomationVariable -Name 'asrOMSVaultName'

# Authenticating with ARM Rest API

Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\Azure\2.0.1\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$obj = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]"https://login.windows.net/common"

$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
$certificate = Get-AutomationCertificate -Name 'AzureRunAsCertificate'
$TenantID =	$Conn.TenantID
$ClientID = $Conn.ApplicationID
$SubscriptionID = $Conn.SubscriptionID

$authurl="https://login.windows.net/$TenantID"
$AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authUrl

$clientcert = New-object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate"($ClientID,$certificate)
$resourceurl = "https://management.core.windows.net/"
	
$result = $AuthContext.AcquireToken($resourceurl, $clientcert)

$authHeader = @{}
$authHeader.Add('Content-Type','application\json')
$authHeader.Add('Authorization',$result.CreateAuthorizationHeader())
#havent taken care of multi page results (skip token) or error handling in general
$URI = "https://management.azure.com/subscriptions/$SubscriptionID/resources?$"+"filter=resourceType EQ 'Microsoft.RecoveryServices/vaults'&api-version=2015-11-01"
$RestResult = Invoke-RestMethod -Method Get -Headers $authHeader -Uri $URI
$Vaults = $RestResult.Value

# Selecting the OMS Recovery Vault

$Vault = $vaults | where-object {$_.Name -eq $vaultname }

    if ($vault.name -ne $VaultName)
    {
        Write-Output "Vault not found - Nothing to ingest into Log Analytics"
    }
    else
    {

# Constructing the replicationJobs Collection

    $uri = "https://management.azure.com" + $vault.id + "/replicationJobs?api-version=2015-11-10"
    $RestResult = Invoke-RestMethod -method Get -headers $authHeader -uri $uri
    $ASRJobs = $RestResult.value
    $ASRJobs = $ASRJobs.Properties
    $ResourceGroupName = $vault.id.Split('/')
    $ResourceGroupName = $ResourceGroupName[4]
    $NewJobs = (get-date).AddHours(((-1))).ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ssZ')

# Getting all the ASR Jobs for the selected Vault and sending it to OMS Log Analytics

    foreach ($ASR in $ASRJobs)
    {
        if ($ASR.startTime -gt $NewJobs)
        {
        $JobTable = @()
        $JobData = New-Object psobject -property @{
            JobName = $asr.FriendlyName;
            State = $asr.state;
            StateDescription = $asr.stateDescription;
            Tasks = $asr.tasks;
            Errors = $asr.errors;
            StartTime = $asr.startTime;
            EndTime = $asr.endTime;
            TargetId = $asr.targetObjectId;
            TargetName = $asr.targetObjectName;
            LogType = 'Jobs';
            ResourceGroupName = $ResourceGroupName;
            Location = $vault.location;
            VaultName = $vault.name;
            SubscriptionId = $AzureSubscriptionId
            }
        $JobTable += $JobData 

# Converting to JSON

        $JSONJobTable = ConvertTo-Json -InputObject $JobTable

        $LogType = "RecoveryServices"

# Ingesting data to OMS Log Analytics

        Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $JSONJobTable -logType $LogType
        }
        else
        {
            Write-Output "No new jobs to collect."
        }
     }

# Constructing the replicationEvents pipeline

    $uri = "https://management.azure.com" + $vault.id + "/replicationEvents?api-version=2015-11-10"
    $RestResult = Invoke-RestMethod -method Get -headers $authHeader -uri $uri
    $ASREvents = $RestResult.value
    $ASREvents = $ASREvents.Properties
    $ResourceGroupName = $vault.id.Split('/')
    $ResourceGroupName = $ResourceGroupName[4]
    $NewEvents = (get-date).AddHours(((-1))).ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ssZ')

    foreach ($ASREvent in $ASREvents)
    {
        if ($ASREvent.timeofOccurrence -gt $NewEvents)
        {
        $EventTable = @()
        $EventData = New-Object psobject -property @{
            LogType = 'Events';
            Description = $ASREvent.description;
            EventType = $ASREvent.eventType;
            Severity = $ASREvent.severity;
            AffectedObject = $ASREvent.affectedObjectFriendlyName;
            TimeofOccurrence = $ASREvent.timeofOccurrence;
            RecommendedActions = $ASREvent.healtherrors.errorMessage;
            PossibleCauses = $ASREvent.healtherrors.possibleCauses;
            ResourceGroupName = $ResourceGroupName;
            Location = $vault.location;
            VaultName = $vault.name;
            SubscriptionId = $AzureSubscriptionId
            }
        $EventTable += $EventData

# Converting to JSON

        $JSONEventTable = ConvertTo-Json -InputObject $EventTable

        $LogType = "RecoveryServices"

# Ingesting data to OMS Log Analytics
       
        Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $JSONEventTable -logType $LogType
        }
        else
        {
            Write-Output "No new events to collect"
        }
     }

# Constructing the Protected/Unprotected VM collection. Will iterate and filter based on replication provider and protection status

    $uri = "https://management.azure.com" + $vault.id + "/replicationFabrics?api-version=2015-11-10"
    foreach ($ur in $uri)
    {

        $RestResult = Invoke-RestMethod -method Get -headers $authHeader -uri $ur
        $Fabrics = $RestResult.value

        foreach ($Fabric in $Fabrics)
        {
            $uri = "https://management.azure.com" + $Fabric.id + "/replicationProtectionContainers?api-version=2015-11-10"
            $RestResult = Invoke-RestMethod -Method GET -Headers $authHeader -uri $uri
            $Containers = $RestResult.value

            foreach ($Container in $Containers)
            {
                $uri = "https://management.azure.com" + $Container.id + "/replicationProtectedItems?api-version=2015-11-10"
                $RestResult = Invoke-RestMethod -Method GET -Headers $authHeader -URI $uri
                $Items = $RestResult.value
                $Items = $Items.properties

                foreach ($Item in $Items) 
                {
                    if ($item.providerSpecificDetails.instanceType -eq "InMageAzureV2" -and $item.protectionState -eq "Protected")
                    {
                        $uri = "https://management.azure.com" + $container.id + "/replicationProtectedItems/" + $item.providerSpecificDetails.vmId + "/recoveryPoints?api-version=2015-11-10"
                        $RestResult = Invoke-RestMethod -Method GET -Headers $authHeader -Uri $uri
                        $RecoveryPoints = $RestResult.value
                        $RecoveryPoints = $RecoveryPoints.properties

                        # Constructing the VMware table for protected VMs

                        $VMwareTable = @()
                        $VMwareData = New-Object psobject -Property @{
                        LogType = 'VMware';
                        VMReplicationProvider = $Item.providerSpecificDetails.instanceType;
                        ProtectionStatus = $Item.providerSpecifcDetails.vmProtectionState;
                        ReplicationHealth = $Item.replicationHealth;
                        ActiveLocation = $Item.activeLocation;
                        TestFailoverState = $Item.testFailoverState;
                        TestFailoverStateDescription = $Item.testfailoverStateDescription;
                        VMProtectionStateDescription = $Item.providerspecificdetails.vmProtectionStateDescription;
                        ResyncProgressPercentage = $Item.providerspecificdetails.resyncProgressPercentage;
                        RPOinSeconds = $Item.providerspecificdetails.rpoInSeconds;
                        CompressedDataRateInMb = $Item.providerspecificdetails.compressedDataRateInMB;
                        UncompressedDataRateInMB = $Item.providerspecificdetails.uncompressedDataRateInMB;
                        ProcessServerId = $Item.providerspecificdetails.processServerId;
                        IPAddress = $Item.providerspecificdetails.ipAddress;
                        AgentVersion = $Item.providerspecificdetails.agentVersion;
                        IsAgentUpdateRequired = $Item.providerspecificdetails.isAgentUpdateRequired;
                        LastHeartbeat = $Item.providerspecificdetails.lastHeartbeat;
                        MultiVMGroupID = $Item.providerspecificdetails.multiVMGroupId;
                        MultiVMGroupName = $item.providerspecificdetails.multiVMGroupName;
                        protectedDisks = $item.providerspecificdetails.protectedDisks;
                        DiskResized = $item.providerspecificdetails.diskResized;
                        MasterTargetId = $item.providerspecificdetails.masterTargetId;
                        SourceVMCPUCount = $item.providerspecificdetails.sourceVmCPUCount;
                        SourceVMRAMSizeInMB = $item.providerspecificdetails.sourceVmRamSizeInMB;
                        OSType = $item.providerspecificdetails.osType;
                        VHDName = $item.providerspecificdetails.vhdName;
                        OSDiskId = $item.providerspecificdetails.osDiskId;
                        AzureVMDiskDetails = $item.providerspecificdetails.azureVmDiskDetails;
                        VMName = $item.providerspecificdetails.recoveryAzureVMName;
                        VMSize = $item.providerspecificdetails.recoveryAzureVMSize;
                        AzureStorageAccount = $Item.providerSpecificDetails.RecoveryAzureStorageAccount;
                        VMNics = $item.vmNics;
                        AzureFailoverNetwork = $item.providerspecificdetails.selectedRecoveryAzureNetworkId;
                        DiscoveryType = $item.providerspecificdetails.discoveryType;
                        EnableRDPOnTarget = $item.providerspecificdetails.enableRDPOnTargetOption;
                        InfrastructureVmId = $item.providerspecificdetails.infrastructureVmId;
                        vCenterInfrastructureId = $item.providerspecificdetails.vCenterInfrastructureId;
                        VMId = $item.providerspecificdetails.vmId;
                        ProtectionStage = $item.providerspecificdetails.protectionStage;
                        SubscriptionId = $AzureSubscriptionId;
                        ResourceGroupName = $ResourceGroupName;
                        Location = $vault.location;
                        VaultName = $vault.name;
                        LastRecoveryPoint = $RecoveryPoints[-1].recoveryPointTime
                        }

                    $VMwareTable += $VMwareData

                    $JSONVMwareTable = ConvertTo-Json -InputObject $VMwareTable

                    $LogType = 'RecoveryServices'

                    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $JSONVMwareTable -logType $LogType

                    }

                    if ($item.providerSpecificDetails.instanceType -eq "HyperVReplicaAzure" -and $item.protectionState -eq "Protected")
                    
                    {
                        $uri = "https://management.azure.com" + $container.id + "/replicationProtectedItems/" + $item.providerSpecificDetails.vmId + "/recoveryPoints?api-version=2015-11-10"
                        $RestResult = Invoke-RestMethod -Method GET -Headers $authHeader -Uri $uri
                        $RecoveryPoints = $RestResult.value
                        $RecoveryPoints = $RecoveryPoints.properties

                        # Constructing the HyperV table for protected VMs

                        $HyperVTable = @()
                        $HyperVData = New-Object psobject -Property @{
                        LogType = 'HyperV';
                        VMReplicationProvider = $Item.providerSpecificDetails.instanceType;
                        ProtectionStatus = $Item.providerSpecifcDetails.vmProtectionState;
                        ReplicationHealth = $Item.replicationHealth;
                        ActiveLocation = $Item.activeLocation;
                        TestFailoverState = $Item.testFailoverState;
                        TestFailoverStateDescription = $Item.testfailoverStateDescription;
                        VMProtectionStateDescription = $Item.providerspecificdetails.vmProtectionStateDescription;
                        ResyncProgressPercentage = $Item.providerspecificdetails.resyncProgressPercentage;
                        SourceVMCPUCount = $item.providerspecificdetails.sourceVmCPUCount;
                        SourceVMRAMSizeInMB = $item.providerspecificdetails.sourceVmRamSizeInMB;
                        OSType = $item.providerspecificdetails.osType;
                        AzureVMDiskDetails = $item.providerspecificdetails.azureVmDiskDetails;
                        VMName = $item.providerspecificdetails.recoveryAzureVMName;
                        VMSize = $item.providerspecificdetails.recoveryAzureVMSize;
                        AzureStorageAccount = $Item.providerSpecificDetails.RecoveryAzureStorageAccount;
                        VMNics = $item.vmNics;
                        AzureFailoverNetwork = $item.providerspecificdetails.selectedRecoveryAzureNetworkId;
                        VMId = $item.providerspecificdetails.vmId;
                        ProtectionStage = $item.providerspecificdetails.protectionStage;
                        SubscriptionId = $AzureSubscriptionId;
                        ResourceGroupName = $ResourceGroupName;
                        Location = $vault.location;
                        VaultName = $vault.name;
                        LastRecoveryPoint = $RecoveryPoints[-1].recoveryPointTime
                        }

                    $HyperVTable += $HyperVData

                    $JSONHyperVTable = ConvertTo-Json -InputObject $HyperVTable

                    $LogType = 'RecoveryServices'

                    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $JSONHyperVTable -logType $LogType
                    
                    }

                    if ($item.providerSpecificDetails.instanceType -eq "HyperVReplicaAzure" -and $item.protectionState -ne "Protected") 

                    {
                        $uri = "https://management.azure.com" + $container.id + "/replicationProtectedItems/" + $item.providerSpecificDetails.vmId + "?api-version=2015-11-10"
                        $RestResult = Invoke-RestMethod -Method GET -Headers $authHeader -Uri $uri
                        $RecoveryPoints = $RestResult.value
                        $RecoveryPoints = $RecoveryPoints.properties

                        # Constructing the HyperV table for unprotected VMs

                        $HyperVTable = @()
                        $HyperVData = New-Object psobject -Property @{
                        LogType = 'HyperV';
                        VMReplicationProvider = $Item.providerSpecificDetails.instanceType;
                        ProtectionStatus = $Item.providerSpecifcDetails.vmProtectionState;
                        ReplicationHealth = $Item.replicationHealth;
                        ActiveLocation = $Item.activeLocation;
                        TestFailoverState = $Item.testFailoverState;
                        TestFailoverStateDescription = $Item.testfailoverStateDescription;
                        VMProtectionStateDescription = $Item.providerspecificdetails.vmProtectionStateDescription;
                        ResyncProgressPercentage = $Item.providerspecificdetails.resyncProgressPercentage;
                        SourceVMCPUCount = $item.providerspecificdetails.sourceVmCPUCount;
                        SourceVMRAMSizeInMB = $item.providerspecificdetails.sourceVmRamSizeInMB;
                        OSType = $item.providerspecificdetails.osType;
                        AzureVMDiskDetails = $item.providerspecificdetails.azureVmDiskDetails;
                        VMName = $item.providerspecificdetails.recoveryAzureVMName;
                        VMSize = $item.providerspecificdetails.recoveryAzureVMSize;
                        AzureStorageAccount = $Item.providerSpecificDetails.RecoveryAzureStorageAccount;
                        VMNics = $item.vmNics;
                        AzureFailoverNetwork = $item.providerspecificdetails.selectedRecoveryAzureNetworkId;
                        VMId = $item.providerspecificdetails.vmId;
                        ProtectionStage = $item.providerspecificdetails.protectionStage;
                        SubscriptionId = $AzureSubscriptionId;
                        ResourceGroupName = $ResourceGroupName;
                        Location = $vault.location;
                        VaultName = $vault.name;
                        #LastRecoveryPoint = $RecoveryPoints[-1].recoveryPointTime
                        }

                    $HyperVTable += $HyperVData

                    $JSONHyperVTable = ConvertTo-Json -InputObject $HyperVTable

                    $LogType = 'RecoveryServices'

                    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $JSONHyperVTable -logType $LogType
                    
                    }                    
                  }
               }
            }
         }
    }