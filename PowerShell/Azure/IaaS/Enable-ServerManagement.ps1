<# Add machines to Server Management Tool in Azure
This runbook can be triggered in Azure Automation and will automatically add machines to the server management tool
#>

param (
    $deploymentname='test',

    $computerName='mgmtdemo',
    
    $gatewayName='dsc01',

    $gatewayresourcegroupName='mgmt2016'

      )

# Log on to Azure

$cred = Get-AutomationPSCredential -Name AzureCredentials

Login-AzureRmAccount -Credential $cred

New-AzureRmResourceGroupDeployment `
                                     -Name $deploymentname `
                                     -ResourceGroupName $gatewayresourcegroupName `
                                     -TemplateUri https://raw.githubusercontent.com/krnese/AzureDeploy/master/ServerManagement/azuredeploy.json `
                                     -computerName $computerName `
                                     -gatewayName $gatewayName `
                                     -gatewayresourcegroupName $gatewayresourcegroupName `
                                     -Verbose

