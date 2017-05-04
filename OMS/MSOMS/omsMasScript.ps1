# Login-AzureRmAccount

# $wskey = Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName <workspaceRg> -Name <workspaceName>
# $ws = Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName <workspaceRg> -Name <workspaceName>

#Fake data below
$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'Network';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType

$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'Storage';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType

$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'Compute';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType

$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'Capacity';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType

$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'KeyVault';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType

$MASTest = @()
    $MASData = New-Object psobject -Property @{
    Type = 'MASDemo';
    Log = 'Fabric';
    Location = 'Oslo';
    StampName = 'knstack01';
    ResourceProvider = 'Updates';
    Version = '1.0.170331.1';
    State = 'UpToDate';
    Alerts = '0';
    Health = 'Ok'
    }
    $MASTest += $MASData
    $MASJson = ConvertTo-Json -InputObject $MASTest

    Write-Output $MASJson
    $logType = 'MASDemo'
    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $MASJson -logType $logType


# Data from API - example JSON below

$logs = '{
    "Scenario":  "Canary-Basic",
    "UseCases":  [
                     {
                         "Description":  "Create Azure Stack environment AzureStackCanaryCloud-SVCAdmin",
                         "Name":  "CreateAdminAzureStackEnv",
                         "Result":  "PASS",
                         "StartTime":  "18:29:07.1650",
                         "EndTime":  "18:29:07.3525"
                     },
                     {
                         "Description":  "Login to AzureStackCanaryCloud-SVCAdmin as service administrator",
                         "Name":  "LoginToAzureStackEnvAsSvcAdmin",
                         "Result":  "PASS",
                         "StartTime":  "18:29:07.3994",
                         "EndTime":  "18:29:08.0719"
                     },
                     {
                         "Description":  "Select the Default Provider Subscription",
                         "Name":  "SelectDefaultProviderSubscription",
                         "Result":  "PASS",
                         "StartTime":  "18:29:08.1657",
                         "EndTime":  "18:29:10.0930"
                     },
                     {
                         "Description":  "Uploads Linux image to the PIR",
                         "Name":  "UploadLinuxImageToPIR",
                         "Result":  "PASS",
                         "StartTime":  "18:29:10.2340",
                         "EndTime":  "18:29:13.4055"
                     },
                     {
                         "Description":  "Create Azure Stack environment AzureStackCanaryCloud-Tenant",
                         "Name":  "CreateTenantAzureStackEnv",
                         "Result":  "PASS",
                         "StartTime":  "18:29:13.4680",
                         "EndTime":  "18:29:13.9055"
                     },
                     {
                         "Description":  "Create a resource group ascansubscrrg748 for the tenant subscription",
                         "Name":  "CreateResourceGroupForTenantSubscription",
                         "Result":  "PASS",
                         "StartTime":  "18:29:13.9680",
                         "EndTime":  "18:29:16.5537"
                     },
                     {
                         "Description":  "Create a tenant plan",
                         "Name":  "CreateTenantPlan",
                         "Result":  "PASS",
                         "StartTime":  "18:29:16.6319",
                         "EndTime":  "18:29:23.1287"
                     },
                     {
                         "Description":  "Create a tenant offer",
                         "Name":  "CreateTenantOffer",
                         "Result":  "PASS",
                         "StartTime":  "18:29:23.1913",
                         "EndTime":  "18:29:26.2572"
                     },
                     {
                         "Description":  "Create a default managed subscription for the tenant",
                         "Name":  "CreateTenantDefaultManagedSubscription",
                         "Result":  "PASS",
                         "StartTime":  "18:29:26.3197",
                         "EndTime":  "18:29:29.3557"
                     },
                     {
                         "Description":  "Login to AzureStackCanaryCloud-Tenant as tenant administrator",
                         "Name":  "LoginToAzureStackEnvAsTenantAdmin",
                         "Result":  "PASS",
                         "StartTime":  "18:29:29.4182",
                         "EndTime":  "18:29:31.6914"
                     },
                     {
                         "Description":  "Create a subcsription for the tenant and select it as the current subscription",
                         "Name":  "CreateTenantSubscription",
                         "Result":  "PASS",
                         "StartTime":  "18:29:31.7539",
                         "EndTime":  "18:29:35.3579"
                     },
                     {
                         "Description":  "Register resource providers",
                         "Name":  "RegisterResourceProviders",
                         "Result":  "PASS",
                         "StartTime":  "18:29:35.4203",
                         "EndTime":  "18:29:53.0014"
                     },
                     {
                         "Description":  "Create a resource group canur430 for the placing the utility files",
                         "Name":  "CreateResourceGroupForUtilities",
                         "Result":  "PASS",
                         "StartTime":  "18:29:53.0795",
                         "EndTime":  "18:29:56.3025"
                     },
                     {
                         "Description":  "Create a storage account for the placing the utility files",
                         "Name":  "CreateStorageAccountForUtilities",
                         "Result":  "PASS",
                         "StartTime":  "18:29:56.3511",
                         "EndTime":  "18:29:59.7608"
                     },
                     {
                         "Description":  "Create a storage container for the placing the utility files",
                         "Name":  "CreateStorageContainerForUtilities",
                         "Result":  "PASS",
                         "StartTime":  "18:29:59.8233",
                         "EndTime":  "18:30:01.3702"
                     },
                     {
                         "Description":  "Create a DSC script resource that checks for internet connection",
                         "Name":  "CreateDSCScriptResourceUtility",
                         "Result":  "PASS",
                         "StartTime":  "18:30:01.4483",
                         "EndTime":  "18:30:01.9327"
                     },
                     {
                         "Description":  "Create a custom script resource that checks for the presence of data disks",
                         "Name":  "CreateCustomScriptResourceUtility",
                         "Result":  "PASS",
                         "StartTime":  "18:30:01.9952",
                         "EndTime":  "18:30:02.1671"
                     },
                     {
                         "Description":  "Create a data disk to be attached to the VMs",
                         "Name":  "CreateDataDiskForVM",
                         "Result":  "PASS",
                         "StartTime":  "18:30:02.2296",
                         "EndTime":  "18:30:17.0061"
                     },
                     {
                         "Description":  "Upload the canary utilities to the blob storage",
                         "Name":  "UploadUtilitiesToBlobStorage",
                         "Result":  "PASS",
                         "StartTime":  "18:30:17.0687",
                         "EndTime":  "18:30:31.5848"
                     },
                     {
                         "Description":  "Create a key vault store to put the certificate secret",
                         "Name":  "CreateKeyVaultStoreForCertSecret",
                         "Result":  "PASS",
                         "StartTime":  "18:30:31.6630",
                         "EndTime":  "18:31:26.2451"
                     },
                     {
                         "Description":  "Create a resource group canvr788 for the placing the VMs and corresponding resources",
                         "Name":  "CreateResourceGroupForVMs",
                         "Result":  "PASS",
                         "StartTime":  "18:31:26.3232",
                         "EndTime":  "18:31:28.0576"
                     },
                     {
                         "Description":  "Deploy ARM template to setup the virtual machines",
                         "Name":  "DeployARMTemplate",
                         "Result":  "PASS",
                         "StartTime":  "18:31:28.1357",
                         "EndTime":  "18:59:57.8839"
                     },
                     {
                         "Description":  "Queries for the VMs that were deployed using the ARM template",
                         "Name":  "QueryTheVMsDeployed",
                         "Result":  "PASS",
                         "StartTime":  "18:59:57.9776",
                         "EndTime":  "19:00:04.8006"
                     },
                     {
                         "Description":  "Check if the VMs deployed can talk to each other before they are rebooted",
                         "Name":  "CheckVMCommunicationPreVMReboot",
                         "Result":  "PASS",
                         "StartTime":  "19:00:04.9412",
                         "EndTime":  "19:00:43.4279"
                     },
                     {
                         "Description":  "Add a data disk from utilities resource group to the VM with private IP",
                         "Name":  "AddDatadiskToVMWithPrivateIP",
                         "StartTime":  "19:00:43.5060",
                         "EndTime":  "19:11:32.7998",
                         "Result":  "PASS",
                         "UseCase":  [
                                         {
                                             "Description":  "Stop/Deallocate the VM with private IP before adding the data disk",
                                             "Name":  "StopDeallocateVMWithPrivateIPBeforeAddingDatadisk",
                                             "Result":  "PASS",
                                             "StartTime":  "19:00:43.5529",
                                             "EndTime":  "19:05:50.5421"
                                         },
                                         {
                                             "Description":  "Attach the data disk to VM with private IP",
                                             "Name":  "AddTheDataDiskToVMWithPrivateIP",
                                             "Result":  "PASS",
                                             "StartTime":  "19:05:50.5576",
                                             "EndTime":  "19:06:27.7605"
                                         },
                                         {
                                             "Description":  "Start the VM with private IP after adding data disk and updating the VM",
                                             "Name":  "StartVMWithPrivateIPAfterAddingDatadisk",
                                             "Result":  "PASS",
                                             "StartTime":  "19:06:27.7761",
                                             "EndTime":  "19:11:32.7998"
                                         }
                                     ]
                     },
                     {
                         "Description":  "Apply custom script that checks for the presence of data disk on the VM with private IP",
                         "Name":  "ApplyDataDiskCheckCustomScriptExtensionToVMWithPrivateIP",
                         "StartTime":  "19:11:32.8310",
                         "EndTime":  "19:17:15.5977",
                         "Result":  "PASS",
                         "UseCase":  [
                                         {
                                             "Description":  "Check for any existing custom script extensions on the VM with private IP",
                                             "Name":  "CheckForExistingCustomScriptExtensionOnVMWithPrivateIP",
                                             "Result":  "PASS",
                                             "StartTime":  "19:11:32.8467",
                                             "EndTime":  "19:11:33.6637"
                                         },
                                         {
                                             "Description":  "Apply the custom script extension to the VM with private IP",
                                             "Name":  "ApplyCustomScriptExtensionToVMWithPrivateIP",
                                             "Result":  "PASS",
                                             "StartTime":  "19:11:33.6637",
                                             "EndTime":  "19:17:15.5820"
                                         }
                                     ]
                     },
                     {
                         "Description":  "Restart the VM which has a public IP address",
                         "Name":  "RestartVMWithPublicIP",
                         "StartTime":  "19:17:15.6289",
                         "EndTime":  "19:20:20.6893",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Stop/Dellocate the VM with private IP",
                         "Name":  "StopDeallocateVMWithPrivateIP",
                         "StartTime":  "19:20:20.7205",
                         "EndTime":  "19:24:56.7567",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Start the VM with private IP",
                         "Name":  "StartVMWithPrivateIP",
                         "StartTime":  "19:24:56.7879",
                         "EndTime":  "19:30:01.9203",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Check if the VMs deployed can talk to each other after they are rebooted",
                         "Name":  "CheckVMCommunicationPostVMReboot",
                         "StartTime":  "19:30:01.9672",
                         "EndTime":  "19:30:31.6268",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Delete the VM with private IP",
                         "Name":  "DeleteVMWithPrivateIP",
                         "StartTime":  "19:30:31.6581",
                         "EndTime":  "19:35:07.1909",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Delete the resource group that contains all the VMs and corresponding resources",
                         "Name":  "DeleteVMResourceGroup",
                         "StartTime":  "19:35:07.2222",
                         "EndTime":  "19:47:48.6441",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Delete the resource group that contains all the utilities and corresponding resources",
                         "Name":  "DeleteUtilitiesResourceGroup",
                         "StartTime":  "19:47:48.6910",
                         "EndTime":  "19:49:36.1204",
                         "Result":  "PASS"
                     },
                     {
                         "Description":  "Remove all the tenant related stuff",
                         "Name":  "TenantRelatedcleanup",
                         "StartTime":  "19:49:36.1516",
                         "EndTime":  "19:51:26.9513",
                         "Result":  "PASS",
                         "UseCase":  [
                                         {
                                             "Description":  "Remove all the tenant related subscriptions",
                                             "Name":  "DeleteTenantSubscriptions",
                                             "Result":  "PASS",
                                             "StartTime":  "19:49:36.1985",
                                             "EndTime":  "19:49:38.3640"
                                         },
                                         {
                                             "Description":  "Login to AzureStackCanaryCloud-SVCAdmin as service administrator to remove the subscription resource group",
                                             "Name":  "LoginToAzureStackEnvAsSvcAdminForCleanup",
                                             "Result":  "PASS",
                                             "StartTime":  "19:49:38.3640",
                                             "EndTime":  "19:49:39.4735"
                                         },
                                         {
                                             "Description":  "Delete the resource group that contains subscription resources",
                                             "Name":  "DeleteSubscriptionResourceGroup",
                                             "Result":  "PASS",
                                             "StartTime":  "19:49:39.4892",
                                             "EndTime":  "19:51:26.9357"
                                         }
                                     ]
                     }
                 ]
}'

$logsobject = ConvertFrom-Json -InputObject $logs

$logsobject.Scenario
$usecases = $logsobject.UseCases

foreach ($use in $usecases)
{
$TipTest = @()
    $TipData = New-Object psobject -Property @{
            Log = 'TipTest';
            Description = $use.Description;
            Name = $use.Name;
            StartTime = $use.StartTime;
            EndTime = $use.EndTime;
            Result = $use.Result;
            UseCase = $use.UseCase.con
    }
    $TipTest += $TipData
    $TIPJson = ConvertTo-Json -InputObject $TipTest

    Write-Output $TIPJson

    $logType = 'MASDemo'

    Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $TIPJson -logType $logType        
}

# Data from API - example JSON below

$rp = '[
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/01ee421b-1b8e-4747-bfda-e4f96e15c090",
        "name":  "01ee421b-1b8e-4747-bfda-e4f96e15c090",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "01ee421b-1b8e-4747-bfda-e4f96e15c090",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Backup controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Backup controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/2396fbd0-5830-43e3-be19-07eca694005c",
        "name":  "2396fbd0-5830-43e3-be19-07eca694005c",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "2396fbd0-5830-43e3-be19-07eca694005c",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Azure-consistent storage ring",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Azure-consistent storage ring",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/28f19270-971e-4f2c-874e-d0bf4807427d",
        "name":  "28f19270-971e-4f2c-874e-d0bf4807427d",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "28f19270-971e-4f2c-874e-d0bf4807427d",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Infrastructure management controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Infrastructure management controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/2ec6af7d-acf1-4468-9436-d40ad9d36e08",
        "name":  "2ec6af7d-acf1-4468-9436-d40ad9d36e08",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "2ec6af7d-acf1-4468-9436-d40ad9d36e08",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Load balancer multiplexer",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Load balancer multiplexer",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/46563330-b587-4032-bb83-324bb1753a52",
        "name":  "46563330-b587-4032-bb83-324bb1753a52",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "46563330-b587-4032-bb83-324bb1753a52",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Infrastructure deployment",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Infrastructure deployment",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/513c5ed9-03e6-4a26-8234-079484bbbc89",
        "name":  "513c5ed9-03e6-4a26-8234-079484bbbc89",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "513c5ed9-03e6-4a26-8234-079484bbbc89",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Azure Resource Manager",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Azure Resource Manager",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/55e0e350-58a2-4e1e-bc9b-8e48a7f7c2aa",
        "name":  "55e0e350-58a2-4e1e-bc9b-8e48a7f7c2aa",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "55e0e350-58a2-4e1e-bc9b-8e48a7f7c2aa",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Partition request broker",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Partition request broker",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/6409b9ec-c25f-49fe-b2bc-f9cfcdf77549",
        "name":  "6409b9ec-c25f-49fe-b2bc-f9cfcdf77549",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "6409b9ec-c25f-49fe-b2bc-f9cfcdf77549",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Network controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Network controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/68955da2-744b-4a08-a266-086d8194b61f",
        "name":  "68955da2-744b-4a08-a266-086d8194b61f",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "68955da2-744b-4a08-a266-086d8194b61f",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Health controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Health controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/7c694eea-3dc6-4e68-94b4-cba878b5017c",
        "name":  "7c694eea-3dc6-4e68-94b4-cba878b5017c",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "7c694eea-3dc6-4e68-94b4-cba878b5017c",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Certificate management",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Certificate management",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/8302cad9-8f1d-4f0e-abdc-bef5d20eed46",
        "name":  "8302cad9-8f1d-4f0e-abdc-bef5d20eed46",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "8302cad9-8f1d-4f0e-abdc-bef5d20eed46",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Compute controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Compute controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/8663915e-625f-42da-bb44-af1642994b2f",
        "name":  "8663915e-625f-42da-bb44-af1642994b2f",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "8663915e-625f-42da-bb44-af1642994b2f",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Infrastructure role controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Infrastructure role controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/96c9db92-86eb-4f59-a413-8345ea8fa2f8",
        "name":  "96c9db92-86eb-4f59-a413-8345ea8fa2f8",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "96c9db92-86eb-4f59-a413-8345ea8fa2f8",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Directory management",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Directory management",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/ac12c23a-5167-48e7-82ea-e8478b2f09d5",
        "name":  "ac12c23a-5167-48e7-82ea-e8478b2f09d5",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "ac12c23a-5167-48e7-82ea-e8478b2f09d5",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Active Directory Federation Services",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Active Directory Federation Services",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/d66e48b8-c39a-4a79-b715-55a166e7a201",
        "name":  "d66e48b8-c39a-4a79-b715-55a166e7a201",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "d66e48b8-c39a-4a79-b715-55a166e7a201",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Internal data store",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Internal data store",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/e8fc050c-9867-40c4-ba9c-7d738a2c176a",
        "name":  "e8fc050c-9867-40c4-ba9c-7d738a2c176a",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "e8fc050c-9867-40c4-ba9c-7d738a2c176a",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Storage controller",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Storage controller",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    },
    {
        "id":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/local/serviceHealths/6216a477-78ae-49ec-8489-ac96a37c1549/resourceHealths/f811895e-8c6b-4b51-88f2-ff1ced4e7491",
        "name":  "f811895e-8c6b-4b51-88f2-ff1ced4e7491",
        "type":  "Microsoft.InfrastructureInsights.Admin/regionHealths/serviceHealths/resourceHealths",
        "location":  "local",
        "tags":  {

                 },
        "properties":  {
                           "registrationId":  "f811895e-8c6b-4b51-88f2-ff1ced4e7491",
                           "namespace":  "Microsoft.Fabric.Admin",
                           "routePrefix":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local",
                           "resourceType":  "infraRoles",
                           "resourceName":  "Edge gateway",
                           "usageMetrics":  "",
                           "resourceLocation":  "local",
                           "resourceURI":  "/subscriptions/4ed94c7f-9fdd-41dd-beee-5c430f97d9ef/resourceGroups/system.local/providers/Microsoft.Fabric.Admin/fabricLocations/local/infraRoles/Edge gateway",
                           "rpRegistrationId":  "6216a477-78ae-49ec-8489-ac96a37c1549",
                           "systemHealthCheckSummary":  "@{failedCount=0; totalCount=0}",
                           "alertSummary":  "@{criticalAlertCount=0; warningAlertCount=0}",
                           "healthState":  "Healthy"
                       }
    }
]'

$rpdata = ConvertFrom-Json -InputObject $rp

foreach ($rpd in $rpdata)
{
   $properties = $rp.properties
   foreach ($pr in $properties) 
   {
    $RPData = @()
        $RPTable = New-Object psobject -Property @{
            Log = 'InfraRoles'
            RegistrationId = $pr.registrationId;
            Namespace = $pr.namespace;
            RoutePrefix = $pr.routeprefix;
            RpRegistrationId = $pr.rpregistrationid;
            Healthstate = $pr.healthstate;
            ResourceName = $pr.resourceName;
            ResourceType = $pr.resourcetype
            }
         $rpdata += $RPTable
         $JSONRP = ConvertTo-Json -InputObject $rpdata
         Write-Output $jsonrp
         
        $logType = 'MASDemo'
        }
        Send-OMSAPIIngestionData -customerId $ws.CustomerId -sharedKey $wskey.PrimarySharedKey -body $JSONRP -logType $logType 

        }