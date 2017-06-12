# Lab 1 - Imperative vs. Declarative

>Last updated: 6/12/2017

>Author: krnese

### Azure Resource Manager - Demystified

### Before you begin

The objective of this hackathon is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell modules

### Lab 1 - Imperative vs Declarative 

### Objectives

In this lab, you explore the difference between imperative vs declarative, to better understand the power and capabilities of Resource Manager and templates

### Imperative

The following PowerShell snippet will demonstrate how you can create and deploy core IaaS resources in Azure, in an *imperative* way:


		# Connect to your Azure subscription
		Login-AzureRmAccount
		
		# Add some variables that you will use as you move forward
		
		$RGname = ""
		$Location = ""
		
		# Storage
		
		$StorageName = ""
		$StorageType = "Standard_LRS"
		
		# Network
		
		$vnicName = "vmvNic"
		$Subnet1Name = "Subnet1"
		$vNetName = "MyVnet"
		$vNetAddressPrefix = "192.168.0.0/16"
		$vNetSubnetAddressPrefix = "192.168.0.0/24"
		
		# Compute
		
		$VMName = ""
		$ComputerName = $VMName
		$VMSize = "Standard_A2"
		$OSDiskName = $VMName + "osDisk"
		
		# Create a new Resource Group
		
		$RG = New-AzureRmResourceGroup -Name $RGname -Location $location -Verbose
		
		# Create Storage
				
		$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGname -Name $StorageName -Type $StorageType -Location $Location 
		
		# Create Network
		
		$PIP = New-AzureRmPublicIpAddress -Name $vnicName -ResourceGroupName $RGname -Location $Location -AllocationMethod Dynamic
		$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $vNetSubnetAddressPrefix
		$vNET = New-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $RGname -Location $Location -AddressPrefix $vNetAddressPrefix -Subnet $SubnetConfig
		$Interface = New-AzureRmNetworkInterface -Name $vnicName -ResourceGroupName $RGname -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id
		
		# Create Compute
		
		## Creating VM Profile
		
		$Credential = Get-Credential
		$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize 
		$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $credential -ProvisionVMAgent -EnableAutoUpdate
		$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
		$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $interface.Id 
		$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd" 
		$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption fromImage 
		
		# Deploy
		
		New-AzureRmVM -ResourceGroupName $RGname -Location $Location -VM $VirtualMachine
		
Now try to rerun the exact script. What happens?

### Declarative

Now, let's try to deploy the same resources, using a Resource Manager *template*. You will deploy the template below, using PowerShell cmdlets:

	{
	    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
	    "contentVersion": "1.0.0.0",
	    "parameters": {
	        "vmName": {
	            "type": "string",
	            "defaultValue": "VM",
	            "metadata": {
	                "description": "Assing a suffix for the VM you will create"
	            }
	        },        
	        "vmSize": {
	            "type": "string",
	            "defaultValue": "Standard_D1",
	            "allowedValues": [
	                "Standard_A1",
	                "Standard_A2",
	                "Standard_A3",
	                "Standard_A4",
	                "Standard_A5",
	                "Standard_A6",
	                "Standard_D1",
	                "Standard_D2",
	                "Standard_D3_v2",
	                "Standard_D4_v2",
	                "Standard_D5_v2"
	            ],
	            "metadata": {
	                "description": "Selec the vm size"
	            }
	        },        
	        "username": {
	            "type": "string",
	            "defaultValue": "azureadmin",
	            "metadata": {
	                "description": "Specify the OS username"
	            }
	        },        
	        "pwd": {
	            "type": "securestring",
	            "metadata": {
	                "description": "If Windows, specify the password for the OS username"
	            }
	        }        
	    },
	    "variables": {
	        "storageAccountName": "[toLower(concat('st', uniquestring(resourceGroup().name)))]",
	        "vNetName": "myVnet",
	        "vnetSubnetName": "subnet1",
	        "vnetID": "[resourceId('Microsoft.Network/virtualnetworks', variables('vNetName'))]",
	        "subnetRef": "[concat(variables('vnetID'),'/subnets/', variables('vNetSubnetName'))]",        
	        "osTypeWindows": {
	            "imageOffer": "WindowsServer",
	            "imageSku": "2016-Datacenter",
	            "imagePublisher": "MicrosoftWindowsServer"
	        }        
	    },
	    "resources": [
	        {
	            "type": "Microsoft.Storage/storageAccounts",
	            "apiVersion": "2017-06-01",
	            "name": "[variables('storageAccountName')]",
	            "location": "[resourceGroup().location]",
	            "sku": {
	                "name": "Standard_LRS"
	            },
	            "kind": "Storage"
	        },
	        {
	            "type": "Microsoft.Network/virtualNetworks",
	            "apiVersion": "2017-03-01",
	            "name": "[variables('vNetName')]",
	            "location": "[resourceGroup().location]",
	            "properties": {
	                "addressSpace": {
	                    "addressPrefixes": [
	                        "10.0.0.0/16"
	                    ]                    
	                },
	                "subnets": [
	                    {
	                        "name": "[variables('vnetSubnetName')]",
	                        "properties": {
	                            "addressPrefix": "10.0.0.0/24"                            
	                        }                        
	                    }
	                ]
	            }
	        },
	        {
	            "type": "Microsoft.Network/publicIPAddresses",
	            "apiVersion": "2017-04-01",
	            "name": "[concat(parameters('vmName'), 'IP')]",
	            "location": "[resourceGroup().location]",
	            "properties": {
	                "publicIPallocationmethod": "Dynamic",
	                "dnsSettings": {
	                    "domainNameLabel": "[toLower(concat(parameters('vmName')))]"
	                }
	            }
	        },
	        {
	            "type": "Microsoft.Network/networkInterfaces",
	            "apiVersion": "2017-04-01",
	            "name": "[concat(parameters('vmName'), 'nic')]",
	            "location": "[resourceGroup().location]",
	            "dependsOn": [
	                "[concat('Microsoft.Network/publicIPAddresses/', parameters('vmName'), 'IP')]",
	                "[concat('Microsoft.Network/virtualNetworks/', variables('vNetName'))]"
	            ],
	            "properties": {
	                "ipConfigurations": [
	                    {
	                        "name": "ipconfig1",
	                        "properties": {
	                            "privateIPAllocationMethod": "Dynamic",
	                            "publicIPAddress": {
	                                "id": "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('vmName'), 'IP'))]"
	                            },
	                            "subnet": {
	                                "id": "[variables('subnetRef')]"
	                            }
	                        }
	                    }
	                ]
	            }
	        },
	        {
	            "type": "Microsoft.Compute/virtualMachines",
	            "apiVersion": "2017-03-30",
	            "name": "[parameters('vmName')]",
	            "location": "[resourceGroup().location]",
	            "dependsOn": [
	                "[concat('Microsoft.Storage/StorageAccounts/', variables('storageAccountName'))]",
	                "[concat('Microsoft.Network/networkinterfaces/', parameters('vmName'), 'nic')]"
	            ],
	            "properties": {
	                "hardwareprofile": {
	                    "vmsize": "[parameters('vmSize')]"
	                },
	                "osProfile": {
	                    "computername": "[parameters('vmName')]",
	                    "adminusername": "[parameters('username')]",
	                    "adminpassword": "[parameters('pwd')]"
	                },
	                "storageProfile": {
	                    "imageReference": {
	                        "publisher": "[variables('osTypeWindows').imagePublisher]",
	                        "offer": "[variables('osTypeWindows').imageOffer]",
	                        "version": "latest",
	                        "sku": "[variables('osTypeWindows').imageSku]"
	                    },
	                    "osdisk": {
	                        "name": "osdisk",
	                        "vhd": {
	                            "uri": "[concat('http://', variables('storageAccountName'), '.blob.core.windows.net/', 'vhds', '/', 'osdisk','.vhd')]"
	                        },
	                        "caching": "readwrite",
	                        "createoption": "FromImage"
	                    }
	                },
	                "networkprofile": {
	                    "networkinterfaces": [
	                        {
	                            "id": "[resourceId('Microsoft.Network/networkinterfaces', concat(parameters('vmName'),'nic'))]"
	                        }
	                    ]
	                }
	            }
	        }
	    ],
	    "outputs": {
	        "vmEndpoint": {
	            "type": "string",
	            "value": "[reference(concat(parameters('vmName'), 'IP')).dnsSettings.fqdn]"
	        }
	    }
	}

From your PowerShell session, run the following snippet where you change the variable placeholders to something else:

	$rgName = 'myResourceGroup'
	$rgLocation = 'westeurope'
	$vmName = 'myknvm'
	$userName = 'knadmin'
	$templateUri = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/basic/declerativeIaaS.json'
	
	New-AzureRmResourceGroupDeployment -Name declarative `
	                                   -ResourceGroupName (New-AzureRmResourceGroup -Name $rgName -Location $rgLocation).ResourceGroupName `
	                                   -TemplateUri $templateUri `
	                                   -vmName $vmName `
	                                   -userName $userName `
	                                   -Verbose

Once deployed, please re-run the PowerShell snippet to perform the deployment again. What happens?

#### Proceeding to Lab 2 

You have now completed the first lab, exploring what it means to deal with immutable resources in Azure using Resource Manager templates. In the next lab, you will explore more of the basics when creating your first Resource Manager template.

[Lab 2 - Exploring Resource Manager Templates](./lab-2.md)