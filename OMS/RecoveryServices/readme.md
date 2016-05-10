# Deploy OMS Recovery Services using ARM template
This template will create a new Recovery Services vault in Azure with a storage account

# Deploy using PowerShell:
````powershell
New-AzureRmResourceGroupDeployment -Name recoveryvaultdeployment `
                                   -ResourceGroupName (New-AzureRmResourceGroup -Name drtest -Location westeurope).ResourceGroupName `
                                   -TemplateFile C:\asr\Template\azuredeploy.json `
                                   -OMSRecoveryVaultName myvault `
                                   -Storagetype Standard_LRS `
                                   -region westeurope `
                                   -Verbose
````                                   
