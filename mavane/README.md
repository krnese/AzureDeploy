# Deployment instructions

The following PowerShell snippet will deploy the environment end-to-end in Azure

````powershell

# Declare VM names

$IaaSVMName = "myvm01"
$SQLVMName = "mysql01"

# Defining some variables for you to retrieve info from existing workspace, to easily connect the VMs during deployment

$workspaceRg = "mgmtdemo"
$workspaceName = "demoworkspace507as2sfde3esi6"

$workspaceId = (Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $workspaceRg -Name $workspaceName).CustomerId
$workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspaceRg -Name $workspaceName).PrimarySharedKey

# TemplateUri's

$automationTemplate = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/mavane/automationSetup.json'
$vNetTemplate = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/mavane/vNet.json'
$iaasTemplate = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/mavane/managedIaaS.json'
$sqlTemplate = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/mavane/managedSql.json'

# You are good to go - let us start deploying the stuff to Azure (same rg)

# Automation account first...

$RG = New-AzureRmResourceGroup -Name AzureRG -location westeurope

New-AzureRmResourceGroupDeployment -Name AutoSetup `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateUri $automationTemplate `
                                   -Verbose

# Retrieve Automation URI and token to use as input params to VM deployments

$automationAccount = Find-AzureRmResource -ResourceGroupNameEquals $rg.ResourceGroupName -ResourceType Microsoft.Automation/automationAccounts
$endpoint = (Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $RG.ResourceGroupName -AutomationAccountName $automationAccount.Name).Endpoint
$token = (Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $RG.ResourceGroupName -AutomationAccountName $automationAccount.Name).PrimaryKey

# vNet deployment

New-AzureRmResourceGroupDeployment -Name vnet `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateUri $vNetTemplate `
                                   -Verbose

# IaaS VM deployment

New-AzureRmResourceGroupDeployment -Name IaaS `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateUri $iaasTemplate `
                                   -azureLogAnalyticsId $workspaceId `
                                   -azureLogAnalyticsKey $workspaceKey `
                                   -registrationUrl $endpoint `
                                   -registrationKey $token `
                                   -vmName $IaaSVMName `
                                   -Verbose

# SQL IaaS VM deployment

New-AzureRmResourceGroupDeployment -Name sqlIaaS `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateUri $sqlTemplate `
                                   -azureLogAnalyticsId $workspaceId `
                                   -azureLogAnalyticsKey $workspaceKey `
                                   -registrationUrl $endpoint `
                                   -registrationKey $token `
                                   -vmName $SQLVMName `
                                   -Verbose
````