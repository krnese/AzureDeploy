# Nested Resource Manager templates

This sample is built specifically as part of the **Azure Resource Manager - Demystified** hackathon.

### How to deploy

The main template will deploy resources into two different resource groups, and you can use the following PoweShell example to deploy:
	
	# Create 2 resource groups, for mgmt and workload
	
	$MgmtRg = New-AzureRmResourceGroup -Name mymgmtrg -Location westeurope -Verbose
	$WorkloadRg = New-AzureRmResourceGroup -Name myworkloadrg -Location westeurope -Verbose
	
	# Define parameters for template deployment - remember to change the values!
	
	$OMSWorkspaceName = 'myworkspace50'
	$OMSWorkspaceRegion = 'West Europe'
	$OMSRecoveryVaultName = 'myrecoveryvault50'
	$OMSRecoveryVaultRegion = 'West Europe'
	$OMSAutomationName = 'myautomation50'
	$OMSAutomationRegion = 'West Europe'
	$azureAdmin = 'yourUser@domain.com'
	$Platform = 'Windows'
	$userName = 'azureadmin'
	$vmNameSuffix = 'myvmwl'
	$instanceCount = '2'
	$DSCJobGuid = (New-Guid)
	$DSCJobGuid2 = (New-Guid)
	$DSCJobGuid3 = (New-Guid)
	
	# Deploy template
	
	New-AzureRmResourceGroupDeployment -Name myDemo `
	                                   -ResourceGroupName $MgmtRg.ResourceGroupName `
	                                   -TemplateUri 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/lab4/azuredeploy.json' `
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

![media](./images/dashboard-new.png)