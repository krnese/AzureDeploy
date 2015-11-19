# Azure ARM Template using DSC VM Extension in order to provision and configure IIS (Web server).
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FDSCExample%2Fazuredeploy.json) 


<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/krnese/AzureDeploy/master/DSCExample/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Example template on how to deploy a web server into Azure IaaS using Azure Resource Manager with DSC VM Extension

To deploy this template using AzureRM PowerShell, simply run the following cmdlet:

New-AzureRmResourceGroupDeployment -Name demodeployment -ResourceGroupName (New-AzureRmResourceGroup -Name DSCDemoRG -Location "west us").ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/DSCExample/azuredeploy.json" -vmname dscvm01 -storageblobname dscstor50 -vnetname dscvnet50 -Verbose


