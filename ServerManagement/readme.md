# Add machines to Server Management Tool in Azure
This template will add exsiting machines to your Server Management resource in Azure, and requires that a Resource Group with a Gateway exists up front.
Simply specify the name of the machine to add, and reference the Resource Group and the Gateway server that will expose the management capabilities.

# Deploy with PowerShell:
````powershell
New-AzureRmResourceGroupDeployment -name srvmgmt -ResourceGroupName <name of RG where the machine will be located> `
                                   -gatewayName <name of gateway machine> `
                                   -gatewayresourcegroupName <name of gateway RG> `
                                   -verbose
````                                   
