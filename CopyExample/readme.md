# Deploy multiple Virtual Machines using Copy and CopyIndex
This template will take -instancecount parameter and iterate through the resources that's declared.

# Deploy with PowerShell:

````powershell

New-AzureRMResourceGroupDeployment -Name 'copyexample' `
                                   -ResourceGroup (New-AzureRmResourceGroup -Name 'CopyExample' -Location 'west europe').ResourceGroupName `
                                   -TemplateURI 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/CopyExample/azuredeploy.json'`
                                   -username azureadmin `
                                   -instancecount 5 `
                                   -location 'west europe' `
                                   -Verbose
````
