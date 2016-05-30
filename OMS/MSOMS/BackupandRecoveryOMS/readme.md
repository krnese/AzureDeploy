# Deploy Backup and Site Recovery (OMS) using ARM template

This template will deploy Backup and Site Recovery (OMS) in your preferred Azure Region with a corresponding Storage Account so that you can easily get started with configuring of backup and recovery for your workloads, regardless of clouds, location and applications. 

## Deploy using Azure Portal


## Deploy using PowerShell:
````powershell
New-AzureRmResourceGroupDeployment -name backuprecovery `
                                   -ResourceGroupName (New-AzureRmResourceGroup -Name OMSRecovery -Location 'westeurope').ResourceGroupName `
                                   -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/BackupandRecoveryOMS/azuredeploy.json' `
                                   -OMSRecoveryVaultName 'recovery' `
                                   -OMSRecoverySku Free `
                                   -storageaccountname 'recovery' `
                                   -region westeurope `
                                   -Verbose
````                                   
