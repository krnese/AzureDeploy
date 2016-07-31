# Add diagnostic Storage Accounts for Service Fabric to OMS Log Analytics Workspace
This template will add an existing Azure Storage Account into OMS Log Analytics Workspace for monitoring, default targeting Service Fabric related logs. In addition, it will enable the Service Fabric OMS Gallery solution if not already enabled in the workspace. 

## Deploy to Azure
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FOMS%2FMSOMS%2FStorageAccount%2F%2Fazuredeploy.json) 

## Deploy using PowerShell:
````powershell

New-AzureRmResourceGroupDeployment `
                                  -Name Deployment1 `
                                  -ResourceGroupName OMSWorkspace `
                                  -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/StorageAccount/azuredeploy.json' `
                                  -omsWorkspacename myOMSworkspace `
                                  -storageaccountresourcegroupName storagerg `
                                  -storageaccountName sfstorage `
                                  -Verbose
````                                   

## Add multiple Storage Accounts to OMS Log Analytics using PowerShell:
````powershell

$storageaccounts = Get-AzureRmStorageAccount

foreach ($storage in $storageaccounts) {

  New-AzureRmResourceGroupDeployment `
                                  -Name Deployment1 `
                                  -ResourceGroupName OMSWorkspace `
                                  -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/StorageAccount/azuredeploy.json' `
                                  -OMSWorkspacename myOMSworkspace `
                                  -storageaccountname $storage.Name `
                                  -Verbose
````                                  
