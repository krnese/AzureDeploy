# Deploy Azure Service Fabric Cluster and enable monitoring using OMS Log Analytics
This template will deploy an Azure Service Fabric Cluster together with an OMS Log Analytics workspace, and also add the diagnostic storage account into OMS for monitoring and insights. 

The Service Fabric solution uses Azure Diagnostics data from your Service Fabric VMs, by collecting this data from your Azure WAD tables. 
Log Analytics then reads Service Fabric framework events, including Reliable Service Events, Actor Events, Operational Events, and Custom ETW events. 
The Service Fabric solution dashboard shows you notable issues and relevant events in your Service Fabric environment.

## Deploy to Azure
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FOMS%2FMSOMS%2FServiceFabric%2F%2Fazuredeploy.json) 

## Deploy using PowerShell:
````powershell
$RG = New-AzureRmResourceGroup -Name OMSServiceFabric -Location westeurope

New-AzureRmResourceGroupDeployment `
                                  -Name Deployment1 `
                                  -ResourceGroupName $RG.ResourceGroupName `
                                  -TemplateFile 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/ServiceFabric/azuredeploy.json' `
                                  -clusterLocation westeurope `
                                  -computeLocation westeurope `
                                  -dnsName omsservicefabric `
                                  -vmStorageAccountName sf `
                                  -OMSWorkspacename OMSServiceFabric `
                                  -OMSRegion "West Europe" `
                                  -adminUserName azureadmin `
                                  -Verbose
````                                   
## Enable Service Fabric Solution in OMS Log Analytics (post deployment)
````
$OMS = Get-AzureRmOperationalInsightsWorkspace `
                                              -ResourceGroupName $RG.ResourceGroupName `
                                              -Name OMSServiceFabric
                                              
Set-AzureRmOperationalInsightsIntelligencePack `
                                              -ResourceGroupName $OMS.ResourceGroupName `
                                              -WorkspaceName $OMS.Name `
                                              -IntelligencePackName "ServiceFabric" `
                                              -Enabled $true
````
