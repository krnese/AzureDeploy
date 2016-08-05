# Deploy Azure Service Fabric Cluster and enable monitoring using OMS Log Analytics

## Example 1: Create Service Fabric Cluster with diagnostic storage accounts into OMS Gallery Service Fabric solution

This template will deploy an Azure Service Fabric Cluster together with an OMS Log Analytics workspace, adds the diagnostic storage account into OMS for monitoring and insights and enables the OMS Gallery Solution for Service Fabric.

The OMS Gallery Service Fabric solution uses Azure Diagnostics data from your Service Fabric VMs, by collecting this data from your Azure WAD tables. 
Log Analytics then reads Service Fabric framework events, including Reliable Service Events, Actor Events, Operational Events, and Custom ETW events. 
The Service Fabric solution dashboard shows you notable issues and relevant events in your Service Fabric environment.

## Deploy to Azure
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FOMS%2FMSOMS%2FServiceFabric%2F%2Fazuredeploy.json) 

## Deploy using PowerShell:
````powershell

$RG = New-AzureRmResourceGroup -Name ServiceFabric -Location westeurope

New-AzureRmResourceGroupDeployment `
                                  -Name Deployment `
                                  -ResourceGroupName $RG.ResourceGroupName `
                                  -TemplateUri https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/ServiceFabric/azuredeploy.json `
                                  -vmNodeType0Name knsfss `
                                  -computeLocation "West Europe" `
                                  -dnsName knsff `
                                  -vmStorageAccountName sf `
                                  -omsWorkspacename knsfws `
                                  -omsRegion "West Europe" `
                                  -omssolutionName ServiceFabric `
                                  -clusterName knomssf `
                                  -adminUserName azureadmin `
                                  -Verbose
````                                   
## Example 2: Create Service Fabric Cluster with diagnostic storage accounts into OMS Gallery Service Fabric solution, while also connecting every VM Scale Set instance to the OMS workspace using the MMA Agent Extension

This template will deploy an Azure Service Fabric Cluster together with an OMS Log Analytics workspace, adds the diagnostic storage account into OMS for monitoring and insights and enables the OMS Gallery Solution for Service Fabric. In addition, each VM Scale Set instance will get connected to the OMS Workspace.

The OMS Gallery Service Fabric solution uses Azure Diagnostics data from your Service Fabric VMs, by collecting this data from your Azure WAD tables. 
Log Analytics then reads Service Fabric framework events, including Reliable Service Events, Actor Events, Operational Events, and Custom ETW events. 
The Service Fabric solution dashboard shows you notable issues and relevant events in your Service Fabric environment.

## Deploy to Azure
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FOMS%2FMSOMS%2FServiceFabric%2F%2Fazuredeployss.json) 

## Deploy using PowerShell:
````powershell

$RG = New-AzureRmResourceGroup -Name ServiceFabric -Location westeurope

New-AzureRmResourceGroupDeployment `
                                  -Name Deployment `
                                  -ResourceGroupName $RG.ResourceGroupName `
                                  -TemplateFile C:\azuredeploy\oms\msoms\servicefabric\azuredeploy.json `
                                  -vmNodeType0Name knsfss `
                                  -computeLocation "West Europe" `
                                  -dnsName knsff `
                                  -vmStorageAccountName sf `
                                  -omsWorkspacename knsfws `
                                  -omsRegion "West Europe" `
                                  -omssolutionName ServiceFabric `
                                  -clusterName knomssf `
                                  -adminUserName azureadmin `
                                  -Verbose
````                                   
