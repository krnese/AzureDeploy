# Azure Windows Server Containers 
ARM Template using Custom Script Extension to instantiate some Windows Server Containers on Windows Server 2016 - Technical Preview 4


[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FAzureContainerWeb%2Fazuredeploy.json) 

<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/krnese/AzureDeploy/master/AzureContainerWeb/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Deploy using PowerShell:


New-AzureRmResourceGroupDeployment -Name preview -ResourceGroupName (New-AzureRmResourceGroup -Name KNVMCON -Location "west europe").ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/AzureContainerWeb/azuredeploy.json" -containerhost knhost01 -containername tp4con -vmSize standard_a3 -adminaccount knadmin -storageAccountName constor100 -StorageType Standard_LRS -vNetName convnet -Verbose
