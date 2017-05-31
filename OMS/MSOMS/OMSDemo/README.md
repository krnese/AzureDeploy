# Microsoft Operations Management Suite

Your time is precious, so here's a set of ARM templates that will deploy all of the OMS services, fully integrated, with running VM workloads attached to it.

### How to deploy

The main template will deploy resources into two different resource groups, and you can use the following PoweShell example to deploy:
	
	# Create 2 resource groups, for mgmt and workload
	
	$MgmtRg = New-AzureRmResourceGroup -Name mgmtRg -Location westeurope -Verbose
	$WorkloadRg = New-AzureRmResourceGroup -Name workloadRg -Location westeurope -Verbose
	
	# Define parameters for template deployment
	
	$OMSWorkspaceName = 'myOmsWorkspace'
	$OMSWorkspaceRegion = 'West Europe'
	$OMSRecoveryVaultName = 'myRecoveryVault'
	$OMSRecoveryVaultRegion = 'West Europe'
	$OMSAutomationName = 'MyAutomationAccount'
	$OMSAutomationRegion = 'West Europe'
	$azureAdmin = 'yourUser@domain.com'
	$Platform = 'Windows' # Note that Linux isn't fully supported yet
	$userName = 'azureadmin'
	$vmNameSuffix = 'workload'
	$instanceCount = '4'
	$DSCJobGuid = (New-Guid)
	$DSCJobGuid2 = (New-Guid)
	$DSCJobGuid3 = (New-Guid)
	
	# Deploy template
	
	New-AzureRmResourceGroupDeployment -Name myDemo `
	                                   -ResourceGroupName $MgmtRg.ResourceGroupName `
	                                   -TemplateFile c:\azuredeploy\oms\msoms\omsdemo\azuredeploy.json `
	                                   -vmResourceGroup $WorkloadRg.ResourceGroupName `
	                                   -omsRecoveryVaultName $OMSRecoveryVaultName `
	                                   -omsRecoveryVaultRegion $OMSRecoveryVaultRegion `
	                                   -omsWorkspaceName $OMSWorkspaceName `
	                                   -omsWorkspaceRegion $OMSWorkspaceRegion `
	                                   -omsAutomationAccountName $OMSAutomationName `
	                                   -omsAutomationRegion $OMSAutomationRegion `
	                                   -vmNameSuffix $vmNameSuffix `
	                                   -userName $userName `
	                                   -platform $platform `
	                                   -instanceCount $instanceCount `
	                                   -azureAdmin $azureAdmin `
	                                   -DSCJobGuid $DSCJobGuid `
	                                   -DSCJobGuid2 $DSCJobGuid2 `
	                                   -DSCJobGuid3 $DSCJobGuid3 `
	                                   -verbose 


### Post Deployment

Navigate to [Azure Portal](https://portal.azure.com) and find the newly created dashboard, which will have the following naming convention *AzureMgmt(uniqueString(deployment().name))*:

![media](./images/dashboard.png)