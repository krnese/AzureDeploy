# Deployment instructions

The following PowerShell snippet will deploy the environment end-to-end in Azure

````powershell

# Defining some variables for you to retrieve info from existing workspace, to easily connect the VMs during deployment

$workspaceRg = "mgmtdemo"
$workspaceName = "demoworkspace507as2sfde3esi6"

$workspaceId = (Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $workspaceRg -Name $workspaceName).CustomerId
$workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspaceRg -Name $workspaceName).PrimarySharedKey

# You are good to go - let us start deploying the stuff to Azure (same rg)

# Automation account first...

$RG = New-AzureRmResourceGroup -Name AzureRG -location westeurope

New-AzureRmResourceGroupDeployment -Name AzureSetup `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateFile .\automationSetup.json `
                                   -Verbose

# Retrieve Automation URI and token to use as input params to VM deployments

$automationAccount = Find-AzureRmResource -ResourceGroupNameEquals $rg.ResourceGroupName -ResourceType Microsoft.Automation/automationAccounts
$endpoint = (Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $RG.ResourceGroupName -AutomationAccountName $automationAccount.Name).Endpoint
$token = (Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $RG.ResourceGroupName -AutomationAccountName $automationAccount.Name).PrimaryKey

# vNet deployment

New-AzureRmResourceGroupDeployment -Name vnet `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateFile .\vNet.json `
                                   -Verbose

# IaaS VM deployment

New-AzureRmResourceGroupDeployment -Name IaaS `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateFile .\managedIaaS.json `
                                   -azureLogAnalyticsId $workspaceId `
                                   -azureLogAnalyticsKey $workspaceKey `
                                   -registrationUrl $endpoint `
                                   -registrationKey $token `
                                   -vmName iaas10 `
                                   -Verbose

# SQL IaaS VM deployment

New-AzureRmResourceGroupDeployment -Name sqlIaaS `
                                   -ResourceGroupName $rg.ResourceGroupName `
                                   -TemplateFile .\managedSql.json `
                                   -azureLogAnalyticsId $workspaceId `
                                   -azureLogAnalyticsKey $workspaceKey `
                                   -registrationUrl $endpoint `
                                   -registrationKey $token `
                                   -vmName iaassql10 `
                                   -Verbose
````
                                   