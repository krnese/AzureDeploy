# Nested IaaS deployment, using separate templates for compute, storage and networking
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FBasic%2Fazuredeploy.json) 

Example template on how to deploy IaaS using multiple ARM templates.
Both storage and vnet are isolated into their own ARM templates and can be used idividually, while the "master" template (azuredeploy.json) contains the compute settings.  

To deploy this template using Azure PowerShell, simply run the following cmdlet:

New-AzureRmResourceGroupDeployment -Name Dep01 -ResourceGroupName (New-AzureRmResourceGroup -Name nested01 -Location "west europe").ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/krnese/azuredeploy/master/Basic/azuredeploy.json" -vmname AzureDemo01 -storageblobname azurestorage0001 -username azureadmin -Verbose
