$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

# Getting automation variables from the Autoamtion Account

$OMSWorkspaceId = Get-AutomationVariable -Name 'abOMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'abOMSWorkspaceKey'
$AzureSubscriptionId = Get-AutomationVariable -Name 'abAzureSubscriptionId'
$VaultName = Get-AutomationVariable -Name 'abOMSVaultName'

# Authenticating with ARM Rest API

Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\Azure\2.0.1\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$obj = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]"https://login.windows.net/common"

$conn = Get-AutomationConnection -Name AzureRunAsConnection 
$certificate = Get-AutomationCertificate -Name 'AzureRunAsCertificate'
$tenantID =	$Conn.TenantID
$clientID = $Conn.ApplicationID
$subscriptionID = $Conn.SubscriptionID

$authurl="https://login.windows.net/$TenantID"
$authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authUrl

$clientCert = New-object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate"($ClientID,$certificate)
$resourceUrl = "https://management.core.windows.net/"
	
$result = $AuthContext.AcquireToken($resourceurl, $clientcert)

$authHeader = @{}
$authHeader.Add('Content-Type','application\json')
$authHeader.Add('Authorization',$result.CreateAuthorizationHeader())
#havent taken care of multi page results (skip token) or error handling in general
$URI = "https://management.azure.com/subscriptions/$subscriptionID/resources?$"+"filter=resourceType EQ 'Microsoft.RecoveryServices/vaults'&api-version=2015-11-01"
$restResult = Invoke-RestMethod -Method Get -Headers $authHeader -Uri $URI
$vaults = $restResult.Value

# Selecting the OMS Recovery Vault

$vault = $vaults | where-object {$_.Name -eq $vaultname }

    if ($vault.name -ne $vaultName)
    {
        write-output "Vault not found - Ingestion will be ignored"
    }
    else
    {
# Getting Backup Jobs

# Constructing the BackupJobs collection

    $uri = "https://management.azure.com" + $vault.id + "/backupJobs?api-version=2015-11-10"
    $restResult = Invoke-RestMethod -method Get -headers $authHeader -uri $URI
    $backupJobs = $restResult.value
    $backupJobs = $backupJobs.Properties
    $resourceGroupName = $vault.id.Split('/')
    $resourceGroupName = $resourceGroupName[4]
    $newJobs = (get-date).AddHours(((-1))).ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ssZ')

# Getting all the recent Backup Jobs for the selected Vault and sending it to OMS Log Analytics

    foreach ($backupJob in $backupJobs)
    {
        if ($backupJob.startTime -gt $newJobs)
        {
        $backupJobTable = @()
        $backupJobData = New-Object psobject -property @{
            JobName = $backupJob.jobType;
            Status = $backupJob.status;
            Duration = $backupJob.duration;
            TargetName = $backupJob.entityFriendlyName;
            Operation = $backupJob.operation;
            StartTime = $backupJob.startTime;
            EndTime = $backupJob.endTime;
            BackupType = $backupJob.backupManagementType;
            LogType = 'BackupJobs';
            VMVersion = $backupJob.virtualMachineVersion;
            ResourceGroupName = $resourceGroupName;
            Location = $vault.location;
            VaultName = $vault.name;
            SubscriptionId = $azureSubscriptionId;
            JobId = $backupJob.activityId
            }
        $backupJobTable += $backupJobData 

# Converting to JSON

        $JSONbackupJobTable = ConvertTo-Json -InputObject $backupJobTable

        $logType = "RecoveryServices"

# Ingesting data to OMS Log Analytics

        Send-OMSAPIIngestionData -customerId $omsWorkspaceId -sharedKey $omsWorkspaceKey -body $JSONbackupJobTable -logType $logType
        }
        else
        {
            Write-Output "No new jobs to collect."
        }
     }


# Finding protected and unprotected VMs

$backupVault = Find-AzureRmResource -ResourceType Microsoft.RecoveryServices/vaults -ResourceNameContains $vaultName

$rsVault = Get-AzureRmRecoveryServicesVault -Name $backupVault.Name -ResourceGroupName $backupVault.ResourceGroupName
Set-AzureRmRecoveryServicesVaultContext -Vault $rsVault
$azureVMs = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM
Get-AzureRmVM | where-object {$_.Location -eq $rsVault.Location} | ForEach-Object -Process {
    if ($azureVMs.FriendlyName -contains $_.Name) {
        $protected = "Protected"
    } else {
        $protected = "Unprotected"
    }
    $backupTable = @()
       $backupData = New-Object psobject -Property @{
        VMName = $_.Name;
        ProtectionStatus = $protected;
        LogType = 'IaaSBackup';
        VaultName = $rsVault.Name;
        Location = $rsVault.Location
        ResourceGroupName = $_.ResourceGroupName;
        VMId = $_.Id
    }
    $backupTable += $backupData
   
    $backupTableJson = ConvertTo-Json -InputObject $backupData
    $logType = 'RecoveryServices'

    Send-OMSAPIIngestionData -customerId $omsWorkspaceId -sharedKey $omsWorkspaceKey -body $backupTableJson -logType $logType
    
    }

}