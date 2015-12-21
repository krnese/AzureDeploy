# Azure Windows Server Containers 
ARM Template using Custom Script Extension to create and install IIS within a Windows Server Container on Windows Server 2016 - Technical Preview 4:
- Spin up a new Windows Server container based on the existing image
- Install Web-Server within the newly created container
- Stop the container - and create a new container image
- Deploy a new container based on the newly created container image
- Create a static NAT rule and a firewall rule to allow traffic on port 80 to the container

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FAzureContainerWeb%2Fazuredeploy.json) 

<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/krnese/AzureDeploy/master/AzureContainerWeb/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Deploy using PowerShell:


New-AzureRmResourceGroupDeployment -Name preview -ResourceGroupName (New-AzureRmResourceGroup -Name KNVMCON -Location "west europe").ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/AzureContainerWeb/azuredeploy.json" -containerhost knhost01 -containername tp4con -vmSize standard_a3 -adminaccount knadmin -storageAccountName constor100 -StorageType Standard_LRS -vNetName convnet -Verbose
