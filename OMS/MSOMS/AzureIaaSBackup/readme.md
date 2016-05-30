# Enable OMS Backup on Azure IaaS Virtual Machines with ARM Template

This template will enable Azure IaaS VM Backup using Backup and Site Recovery (OMS) RP in Azure

## Deploy using Azure Portal
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2FAzureDeploy%2Fmaster%2FOMS%2FMSOMS%2FAzureIaaSBackup%2Fazuredeploy.json) 

## Deploy using PowerShell:
````powershell
New-AzureRmResourceGroupDeployment -name backup `
                                   -ResourceGroupName OMSRG `
                                   -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/AzureIaaSBackup/azuredeploy.json' `
                                   -vaultname 'recovery' `
                                   -vmResourceGroupName MyRG `
                                   -vmName myVM `
                                   -policyName 'DefaultPolicy' `
                                   -Verbose
````                                   
