# Azure ARM Template using DSC VM Extension with VM Scale Sets for provisioning scalable web servers.
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FLumagate%2FCSP-SI-Onboarding%2Fmaster%2F4%20-%20Hybrid%20Service%20Provider%20Foundation%20for%20IaaS%2FARMTemplates%2Fazuredeploy.json) 

<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Lumagate/CSP-SI-Onboarding/master/4%20-%20Hybrid%20Service%20Provider%20Foundation%20for%20IaaS/ARMTemplates/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Example template on how to deploy VM Scale Sets with a management VM, connected to a Network Security Group that will allow RDP into the machines, and prepare the Scale Sets to serve as Web Servers with DSC Extension and load balancing for port 80.

To deploy this template using AzureRM PowerShell, simply run the following cmdlet:

New-AzureRmResourceGroupDeployment -Name preview -ResourceGroupName (New-AzureRmResourceGroup -Name KNVMSS100 -Location "west europe").ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/Lumagate/CSP-SI-Onboarding/master/4%20-%20Hybrid%20Service%20Provider%20Foundation%20for%20IaaS/ARMTemplates/azuredeploy.json" -vmssName knss -resourceLocation "West Europe" -adminUsername knadmin -instanceCount 2 -mgmtstorage knstor01 -Verbose

