$Cred = Get-Credential `
            -Message 'Provide Azure Subscription Administrator Credentials'

# Replace with your own Azure Subscription ID
$AzureSubscriptionID = 'ec8ddce6-2ecb-45b3-b3e6-d370e8863b99'

Login-AzureRmAccount `
    -Credential $Cred `
    -SubscriptionId $AzureSubscriptionID

# Replace with your own values
$ResourceGroupName = 'KNOMS'
$ResourceGroupLocation = 'West Europe'

# Local path to the ARM Template. Replace with your own value
$TemplateFile = 'C:\users\kristian\documents\github\azuredeploy\oms\azuredeploy.json'

# Create GUIDs for the jobs
$JobGUID1 = [System.Guid]::NewGuid().toString()
$JobGUID2 = [System.Guid]::NewGuid().toString()

# Provide service account credentials for account that has Subscription Administrator permissions
$AzureServiceAccount = Get-Credential `
                                -Message 'Provide Azure Subscription Service Account Administrator Credentials'

#Set the parameter values for the template. Replace values with your own
$Params = @{
    omsLogAnalyticsWorkspaceName                           = 'OMSLogAnalytics6'
    omsLogAnalyticsWorkspaceLocation                       = 'West Europe'
    omsLogAnalyticsWorkspaceSku                            = 'Free'
    omsLogAnalyticsEnableCapacitySolution                  = 'True'
    omsLogAnalyticsEnableSecurityAndAuditSolution          = 'True'
    omsLogAnalyticsEnableSystemUpdateAssessmentSolution    = 'True'
    omsLogAnalyticsEnableAntimalwareAssesmentSolution      = 'True'
    omsLogAnalyticsEnableLogManagementSolution             = 'True'
    omsLogAnalyticsEnableChangeTrackingSolution            = 'True'
    omsLogAnalyticsEnableSQLAssessmentSolution             = 'True'
    omsLogAnalyticsEnableADAssessmentSolution              = 'True'
    omsLogAnalyticsEnableAlertManagementSolution           = 'True'
    omsLogAnalyticsEnableAutomationSolution                = 'True'
    omsLogAnalyticsEnableWireDataSolution                  = 'True'
    omsLogAnalyticsEnableSiteRecoverySolution              = 'True'
    omsLogAnalyticsEnableBackupSolution                    = 'True'
    omsLogAnalyticsEnableSurfaceHubSolution                = 'True'
    omsLogAnalyticsEnableNetworkPerformanceMonitorSolution = 'True'
    omsLogAnalyticsEnableContainersSolution                = 'True'
    omsLogAnalyticsEnableAzureNetworkAnalyticsSolution     = 'True'
    omsLogAnalyticsEnableADReplicationSolution             = 'True'
    omsLogAnalyticsEnableOffice365Solution                 = 'True'
    omsAutomationAccountName                               = 'OMSAutomation10'
    omsAutomationAccountLocation                           = 'West Europe'
    omsAutomationSku                                       = 'Basic'
    runbookJobIdSetOMSAutomationVariable                   = $JobGUID1
    runbookJobIdSetOMSLogAnalyticsIntelligencePack         = $JobGUID2
    azureServiceAccountUserName                            = $AzureServiceAccount.UserName
    azureServiceAccountPassword                            = $AzureServiceAccount.GetNetworkCredential().Password
}

# Create Resource Group
New-AzureRmResourceGroup `
    -Name $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Verbose `
    -Force `
    -ErrorAction Stop 


# Start Deployment
New-AzureRmResourceGroupDeployment `
    -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterObject $Params `
    -Force `
    -Verbose