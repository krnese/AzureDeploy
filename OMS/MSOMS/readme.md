# Deploy Microsoft OMS in Azure with Azure Resource Manager
This template will deploy all the OMS Resources into a new Resource Group in Microsoft Azure

# Deploy using PowerShell:
````powershell
New-AzureRmResourceGroupDeployment -Name newOMS `
                                   -ResourceGroupName (New-AzureRmResourceGroup -Name OMS -Location 'westeurope').ResourceGroupName `
                                   -TemplateUri 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/azuredeploy.json' `
                                   -OMSRecoveryVaultName 'OMSRecovery' `
                                   -region 'westeurope' `
                                   -OMSLogAnalyticsWorkspaceName 'OMSLA' `
                                   -OMSAutomationAccountName 'OMSAA' `
                                   -Verbose
````                                   
