# Add diagnostic Storage Accounts to OMS Log Analytics Workspace
This template will add an existing Azure Storage Account into OMS Log Analytics Workspace for monitoring. 

## Deploy to Azure
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FOMS%2FMSOMS%2FStorageAccount%2F%2Fazuredeploy.json) 

## Deploy using PowerShell:
````powershell

New-AzureRmResourceGroupDeployment `
                                  -Name Deployment1 `
                                  -ResourceGroupName OMSWorkspace `
                                  -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/StorageAccount/azuredeploy.json' `
                                  -OMSWorkspacename myOMSworkspace `
                                  -storageaccountname `
                                  -Verbose
````                                   
