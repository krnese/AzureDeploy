# Azure Resource Manager Inside-Out

>This training material is developed by Hybrid CAT, with the intention to onboard customers and the community to Azure Resource Manager template authoring and management, targeting both Azure and Azure Stack
>![alt text](media/cat.png "Hybrid CAT")

>For questions or feedback, contact **krnese@microsoft.com**

### Before you begin

The objective of this training is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

## Lab 1 - Azure portal and Azure PowerShell 

During this excercise, you will become familiar with the Azure portal and explore its management capabilities, and customize the settings to fit your needs

#### 1.1 Exploring Azure using the portal

1. From your computer, use your preferred browser and navigate to [Azure portal](https://azure.portal.com)
2. Sign in with your credentials that has acess to an Azure subscription (Admin access is required to complete the labs)
3. When logged in, explore the options you have available in the portal and familiarize yourself with the structure. Verify that by drilling further in for each object you selects, which should open new blades
![alt text](media/portal.png "Azure portal")

4. Close all the open blades and proceed to part 2.


#### 1.2 Create Resource Group using Azure portal

1. In the portal, click on *New*,search for *Resource Group*, and click *Create*
2.  Assign a name for the resource group, the location that will store the metadata and click *Create*
![alt text](media/rg.png "New Resource Group")

3. Notice that you get a notification in the upper right once the deployment has completed. This is where you can track your deployments, so you can see if they are completed successfully, or are failing

![alt text](media/notification.png "Azure notifications")

#### 1.3 Customizing the Azure portal

1. In the Azure portal on the main page, click on **+New dashboard**, assign a name and click **Done customizing**
![alt text](media/dashboard1.png "New dashboard")

2. Next, navigate to the resource group you created earlier by clicking on **More services**, **Resource groups**, and click on it. 
3. In the upper right of the resource group blade, you should see a pin which let you pin this particular resource to the dashboard you just created. Click on **Pin to dashboard** and go back to the main your dashboard

![alt text](media/dashboard2.png "Customized dashboard")

#### 4 - Exploring Azure using PowerShell

1. Log on to Azure using PowerShell with the following cmdlet

		Add-AzureRmAccount 

You will be prompted for the credentials and be routed to your default subscription when logged in.

2. To get a list of all subscriptions you have access to, run the following cmdlet

		Get-AzureRmSubscription

3. Select the preferred subscription using this cmdlet

		Select-AzureRmSubscription -subscriptionId [the subscription id of the subscription]

4. You can always verify the subscription you are logged into by executing

		Get-AzureRmContext

5. Ensure you are logged into the subscription where you have created the resource group, and retrieve the resource group using the following cmdlet

		Get-AzureRmResourceGroup -Name [name of your resource group]

6. Create a new resource group using PowerShell with this cmdlet

		New-AzureRmResourceGroup -Name [name of the resource group] -Location [your preferred location, like "West Europe", East US" etc]


You have now completed the basics in **lab 1**, by familiarizing yourself with the Azure portal and Azure PowerShell module, which will be essential as you proceed with the labs


## Lab 2 - Getting started with ARM templates

In this lab, you will learn the basics of Resource Manager templates, and create a reusable template.
You will learn and explore more about the capabilities of ARM templates, how they work, are idempotent and declarative. 

As a comparison to *imperative*, which you might be used to if you are familiar with Azure *Classic*, you can deploy a new virtual machine following the example script below:

		# Connect to your Azure subscription
		
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
		
		# Create a new Azure Resource Grou
		
		$RG = New-AzureRmResourceGroup -Name $RGname -Location $location -Verbose
		
		# Create Storage
		
		
		$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGname -Name $StorageName -Type $StorageType -Location $Location 
		
		# Create Network
		
		$PIP = New-AzureRmPublicIpAddress -Name $vnicName -ResourceGroupName $RGname -Location $Location -AllocationMethod Dynamic
		$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $vNetSubnetAddressPrefix
		$vNET = New-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $RGname -Location $Location -AddressPrefix $vNetAddressPrefix -Subnet $SubnetConfig
		$Interface = New-AzureRmNetworkInterface -Name $vnicName -ResourceGroupName $RGname -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id
		
		# Create Compute
		
		# Setup local VM object
		
		$Credential = Get-Credential
		$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize 
		$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $credential -ProvisionVMAgent -EnableAutoUpdate
		$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
		$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $interface.Id 
		$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd" 
		$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption fromImage 
		
		# Deploy the VM in Azure
		
		New-AzureRmVM -ResourceGroupName $RGname -Location $Location -VM $VirtualMachine
		
Now try to rerun the exact script. What happened?

#### Creating a resource manager template for storage accounts

1. Start by creating a resource manager template that will create a storage account. Open your preferred JSON editor (Visual Studio or Visual Studio Code), and create a template similar to the example below

		{
    	"$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    	"contentVersion": "1.0.0.0",
    	"resources": [
        	{
        	    "apiVersion": "2015-05-01-preview",
        	    "type": "Microsoft.Storage/storageAccounts",
        	    "name": "myfirststorage01",
        	    "location": "East US",
        	    "tags": {
        	    },
        	    "properties":{
        	        "accountType": "Standard_LRS"
        	    }
        	}
    	],
    	"outputs": {
    		}
		}

2. Save the template to a folder on your machine and try to do a deployment using PowerShell with the following cmdlets

		New-AzureRmResourceGroupDeployment -Name storageTest `
										   -ResourceGroupname <name of your existing resource group> `
										   -TemplateFile <directory where you saved your .json file> `
										   -Verbose

Did the template succeed? If no, why not? What was the error?

#### Adding parameters

3. The template was designed to be static with hard coded values for each property. A storage account in Azure has to have a unique name, which cause the deployment to fail. To mitigate this, we will add two parameters to the template, so the user can determine the storage account name and the location of it. Add two parameters to the template as shown below, and reflect these parameters in the resource section

		{
	    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
	    "contentVersion": "1.0.0.0",
	    "parameters": {
	        "storageName": {
	            "type": "string"            
	        },
	        "location": {
	            "type": "string"
	        }
	    },
	    "resources": [
	        {
	            "apiVersion": "2015-05-01-preview",
	            "type": "Microsoft.Storage/storageAccounts",
	            "name": "[parameters('storageName')]",
	            "location": "[parameters('location')]",
	            "tags": {
	            },
	            "properties":{
	                "accountType": "Standard_LRS"
	            }
	        }
	     ],
	    "outputs": {	        
	    	}
	    }

4. Save the template to a folder on your machine, and try to do a new deployment using PowerShell

		New-AzureRmResourceGroupDeployment -Name storageTest `
                                  		   -ResourceGroupname <name of your existing resource group> `
                                   		   -TemplateFile <directory where you saved your .json file> `
										   -storageName <a name for your storage account>
										   -location <your preferred location>
                                           -Verbose

Did the deployment succeed? If not, what was the error?

#### Adding variables

5. Since storage account names need to be unique, it is risky to 'guess' a name for your deployment and risk that the entire deployment will fail just because of that.
This is where we can take advantage of variables in the ARM template, which represent values that will help to simplify the language and expressions used in the template, and also contains values and settings we don't want to expose to the user who need to deploy this template.
To guarantee that the storage will successfully deploy now, we will add the following variable to the template and use the **uniqueString** function to generate - a unique name for the storage account.
Follow the example below to add a uniqueString to the variables section, and remove the parameter for storageName

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "location": {
		            "type": "string"
		        }
		    },
		    "variables": {
		        "storageName": "[uniqueString('storage')]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-05-01-preview",
		            "type": "Microsoft.Storage/storageAccounts",
		            "name": "[variables('storageName')]",
		            "location": "[parameters('location')]",
		            "tags": {
		            },
		            "properties":{
		                "accountType": "Standard_LRS"
		            }
		        }
		    ],
		    "outputs": {		        
		    }
		}

6. Save the template to a directory on your machine, and do a new deployment using PowerShell similar to this:

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose


#### Adding Outputs

1. Templates can also provide outputs, which can be useful in case you need to retrieve information from resources in other resource groups, or from resources in the deployment itself. We will here use the **reference** function to retrieve a particular value from the storage account in the output section. Create a template similar to the example below

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "location": {
		            "type": "string"
		        }
		    },
		    "variables": {
		        "storageName": "[uniqueString('storage')]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-05-01-preview",
		            "type": "Microsoft.Storage/storageAccounts",
		            "name": "[variables('storageName')]",
		            "location": "[parameters('location')]",
		            "tags": {
		            },
		            "properties":{
		                "accountType": "Standard_LRS"
		            }
		        }
		    ],
		    "outputs": {
		        "fqdn": {
		            "type": "string",
		            "value": "[reference(resourceId('Microsoft.Storage/storageAccounts/', variables('storageName')), '2015-05-01-preview').primaryEndpoints.blob]"
		        }
		    }
		}

2. Save the template to a directory on your machine, and do a new deployment using PowerShell similar to this:

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose

Verify that the template successfully deployed. If you didn't change the deployment name, you should not end up with another storage account since ARM and the resources are idempotent. Verify that you got the expected output.

		DeploymentName          : storageTest
		ResourceGroupName       : ARMExample
		ProvisioningState       : Succeeded
		Timestamp               : 1/11/2017 8:03:39 PM
		Mode                    : Incremental
		TemplateLink            : 
		Parameters              : 
		                          Name             Type                       Value     
		                          ===============  =========================  ==========
		                          location         String                     westeurope
		                          
		Outputs                 : 
		                          Name             Type                       Value     
		                          ===============  =========================  ==========
		                          fqdn             String                     https://zu4ll3n7x3ok6.blob.core.windows.net/
		                          
		DeploymentDebugLogLevel : 


#### Deploy multiple resources using copyIndex()

1. You can deploy the same resource type multiple times by using the numeric **copyIndex** function. For the resource you want to create multiple times, you must define a **copy** object that specifies the number of times to iterate. Create a new template similar to the example below

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "location": {
		            "type": "string"
		        },
		        "count": {
		            "type": "int"
		        }
		    },
		    "variables": {
		        "storageName": "[toLower(concat(parameters('count'), deployment().name, uniqueString('s')))]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-05-01-preview",
		            "type": "Microsoft.Storage/storageAccounts",
		            "name": "[concat(variables('storageName'), copyIndex())]",
		            "location": "[parameters('location')]",
		            "tags": {},
		            "copy": {
		                "name": "[concat(variables('storageName'), 'blob')]",
		                "count": "[parameters('count')]"
		            },
		            "properties": {
		                "accountType": "Standard_LRS"
		            }
		        }
		    ],
		    "outputs": {
		    }
		}

2. Save the template to a directory on your machine, and do a new deployment using PowerShell similar to this:

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose

## Lab 3 - Deploying advanced workload

In this lab, you will explore the creation of a Service Fabric with ARM and deploy an application using PowerShell

Create a template similar to the one below

	{
	  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
	  "contentVersion": "1.0.0.0",
	  "parameters": {
	    "clusterName": {
	      "type": "string",
	      "defaultValue": "sfcluster01",
	      "metadata": {
	        "description": "Name of your cluster - Between 3 and 23 characters. Letters and numbers only"
	      }
	    },
	    "subnet0Prefix": {
	      "type": "string",
	      "defaultValue": "10.0.0.0/24",
	      "metadata": {
	        "description": "Specify the subnet prefix"
	      }
	    },
	    "computeLocation": {
	      "type": "string",
	      "defaultValue": "West Europe",
	      "allowedValues": [
	        "East Asia",
	        "Southeast Asia",
	        "Central US",
	        "East US",
	        "East US 2",
	        "West US",
	        "North Central US",
	        "South Central US",
	        "North Europe",
	        "West Europe",
	        "Japan West",
	        "Japan East",
	        "Brazil South",
	        "Canada Central",
	        "Canada East",
	        "West Central US",
	        "West US 2"
	      ],
	      "metadata": {
	        "description": "Select the location for your SF resources"
	      }
	    },
	    "publicIPAddressType": {
	      "type": "string",
	      "allowedValues": [
	        "Dynamic",
	        "Static"
	      ],
	      "defaultValue": "Dynamic",
	      "metadata": {
	        "description": "Select the IP allocation for the public IP address"
	      }
	    },
	    "adminUserName": {
	      "type": "string",
	      "defaultValue": "azureadmin",
	      "metadata": {
	        "description": "Remote desktop user Id"
	      }
	    },
	    "adminPassword": {
	      "type": "securestring",
	      "metadata": {
	        "description": "Remote desktop user password. Must be a strong password"
	      }
	    },
	    "addressPrefix": {
	      "type": "string",
	      "defaultValue": "10.0.0.0/16",
	      "metadata": {
	        "description": "specify vNet address prefix"
	      }
	    },
	    "dnsName": {
	      "type": "string",
	      "defaultvalue": "sfclusterdns",
	      "metadata": {
	        "description": "DNS name for your Service Fabric Cluster endpoint"
	      }
	    },
	    "overProvision": {
	      "type": "string",
	      "defaultValue": "false",
	      "metadata": {
	        "description": "true or false"
	      }
	    },
	    "vmNodeType0Name": {
	      "type": "string",
	      "defaultValue": "omssf",
	      "maxLength": 9,
	      "metadata": {
	        "description": "Specify type name"
	      }
	    },
	    "omsWorkspacename": {
	      "type": "string",
	      "defaultValue": "sfomscl01",
	      "metadata": {
	        "description": "Name of your OMS Log Analytics Workspace"
	      }
	    },
	    "omsRegion": {
	      "type": "string",
	      "defaultValue": "West Europe",
	      "allowedValues": [
	        "West Europe",
	        "East US",
	        "Southeast Asia"
	      ],
	      "metadata": {
	        "description": "Specify the Azure Region for your OMS workspace"
	      }
	    }
	  },
	  "variables": {
	    "publicIPAddressName": "[toLower(concat('pip', uniqueString(resourceGroup().Id)))]",
	    "lbName": "[concat('lbn', uniqueString(resourceGroup().Id))]",
	    "nicName": "[concat('nic', uniqueString(resourceGroup().Id))]",
	    "lbIPName": "[concat('lb', uniqueString(resourceGroup().Id))]",
	    "storageAccountType": "Standard_LRS",
	    "vmImageVersion": "latest",
	    "vmImageSku": "2012-R2-Datacenter",
	    "vmImageOffer": "WindowsServer",
	    "vmNodeType0Size": "Standard_D1_v2",
	    "vmImagePublisher": "MicrosoftWindowsServer",
	    "supportLogStorageAccountType": "Standard_LRS",
	    "nt0applicationStartPort": 20000,
	    "nt0applicationEndPort": 30000,
	    "nt0ephemeralStartPort": 49152,
	    "nt0ephemeralEndPort": 65534,
	    "nt0fabricTcpGatewayPort": 19000,
	    "nt0fabricHttpGatewayPort": 19080,
	    "subnet0Name": "Subnet-0",
	    "vmStorageAccountContainerName": "vhds",
	    "virtualNetworkName": "Vnet1",
	    "supportLogStorageAccountName": "[toLower(concat('sf', uniqueString(resourceGroup().id),'2'))]",
	    "applicationDiagnosticsStorageAccountType": "Standard_LRS",
	    "applicationDiagnosticsStorageAccountName": "[toLower(concat('oms', uniqueString(resourceGroup().id), '3' ))]",
	    "solution": "[Concat('ServiceFabric', '(', parameters('omsWorkspacename'), ')')]",
	    "solutionsecurity": "[concat('Security', '(', parameters('omsWorkspacename'), ')')]",
	    "solutionName": "ServiceFabric",
	    "securitysolution": "Security",
	    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks',variables('virtualNetworkName'))]",
	    "subnet0Ref": "[concat(variables('vnetID'),'/subnets/',variables('subnet0Name'))]",
	    "lbID0": "[resourceId('Microsoft.Network/loadBalancers', concat('LB','-', parameters('clusterName'),'-',parameters('vmNodeType0Name')))]",
	    "lbIPConfig0": "[concat(variables('lbID0'),'/frontendIPConfigurations/LoadBalancerIPConfig')]",
	    "lbPoolID0": "[concat(variables('lbID0'),'/backendAddressPools/LoadBalancerBEAddressPool')]",
	    "lbProbeID0": "[concat(variables('lbID0'),'/probes/FabricGatewayProbe')]",
	    "lbHttpProbeID0": "[concat(variables('lbID0'),'/probes/FabricHttpGatewayProbe')]",
	    "lbNatPoolID0": "[concat(variables('lbID0'),'/inboundNatPools/LoadBalancerBEAddressNatPool')]",
	    "vmStorageAccountName0": "[toLower(concat(uniqueString(resourceGroup().id), '1', '0' ))]",
	    "uniqueStringArray0": [
	      "[concat(variables('vmStorageAccountName0'), '0')]",
	      "[concat(variables('vmStorageAccountName0'), '1')]",
	      "[concat(variables('vmStorageAccountName0'), '2')]",
	      "[concat(variables('vmStorageAccountName0'), '3')]",
	      "[concat(variables('vmStorageAccountName0'), '4')]"
	    ]
	  },
	  "resources": [
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Storage/storageAccounts",
	      "name": "[variables('supportLogStorageAccountName')]",
	      "location": "[parameters('computeLocation')]",
	      "properties": {
	        "accountType": "[variables('supportLogStorageAccountType')]"
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Storage/storageAccounts",
	      "name": "[variables('applicationDiagnosticsStorageAccountName')]",
	      "location": "[parameters('computeLocation')]",
	      "properties": {
	        "accountType": "[variables('applicationDiagnosticsStorageAccountType')]"
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Network/virtualNetworks",
	      "name": "[variables('virtualNetworkName')]",
	      "location": "[parameters('computeLocation')]",
	      "properties": {
	        "addressSpace": {
	          "addressPrefixes": [
	            "[parameters('addressPrefix')]"
	          ]
	        },
	        "subnets": [
	          {
	            "name": "[variables('subnet0Name')]",
	            "properties": {
	              "addressPrefix": "[parameters('subnet0Prefix')]"
	            }
	          }
	        ]
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Network/publicIPAddresses",
	      "name": "[concat(variables('lbIPName'),'-','0')]",
	      "location": "[parameters('computeLocation')]",
	      "properties": {
	        "dnsSettings": {
	          "domainNameLabel": "[parameters('dnsName')]"
	        },
	        "publicIPAllocationMethod": "Dynamic"
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Network/loadBalancers",
	      "name": "[concat('LB','-', parameters('clusterName'),'-',parameters('vmNodeType0Name'))]",
	      "location": "[parameters('computeLocation')]",
	      "dependsOn": [
	        "[concat('Microsoft.Network/publicIPAddresses/',concat(variables('lbIPName'),'-','0'))]"
	      ],
	      "properties": {
	        "frontendIPConfigurations": [
	          {
	            "name": "LoadBalancerIPConfig",
	            "properties": {
	              "publicIPAddress": {
	                "id": "[resourceId('Microsoft.Network/publicIPAddresses',concat(variables('lbIPName'),'-','0'))]"
	              }
	            }
	          }
	        ],
	        "backendAddressPools": [
	          {
	            "name": "LoadBalancerBEAddressPool",
	            "properties": { }
	          }
	        ],
	        "loadBalancingRules": [
	          {
	            "name": "LBRule",
	            "properties": {
	              "backendAddressPool": {
	                "id": "[variables('lbPoolID0')]"
	              },
	              "backendPort": "[variables('nt0fabricTcpGatewayPort')]",
	              "enableFloatingIP": "false",
	              "frontendIPConfiguration": {
	                "id": "[variables('lbIPConfig0')]"
	              },
	              "frontendPort": "[variables('nt0fabricTcpGatewayPort')]",
	              "idleTimeoutInMinutes": "5",
	              "probe": {
	                "id": "[variables('lbProbeID0')]"
	              },
	              "protocol": "tcp"
	            }
	          },
	          {
	            "name": "LBHttpRule",
	            "properties": {
	              "backendAddressPool": {
	                "id": "[variables('lbPoolID0')]"
	              },
	              "backendPort": "[variables('nt0fabricHttpGatewayPort')]",
	              "enableFloatingIP": "false",
	              "frontendIPConfiguration": {
	                "id": "[variables('lbIPConfig0')]"
	              },
	              "frontendPort": "[variables('nt0fabricHttpGatewayPort')]",
	              "idleTimeoutInMinutes": "5",
	              "probe": {
	                "id": "[variables('lbHttpProbeID0')]"
	              },
	              "protocol": "tcp"
	            }
	          }
	        ],
	        "probes": [
	          {
	            "name": "FabricGatewayProbe",
	            "properties": {
	              "intervalInSeconds": 5,
	              "numberOfProbes": 2,
	              "port": "[variables('nt0fabricTcpGatewayPort')]",
	              "protocol": "tcp"
	            }
	          },
	          {
	            "name": "FabricHttpGatewayProbe",
	            "properties": {
	              "intervalInSeconds": 5,
	              "numberOfProbes": 2,
	              "port": "[variables('nt0fabricHttpGatewayPort')]",
	              "protocol": "tcp"
	            }
	          }
	        ],
	        "inboundNatPools": [
	          {
	            "name": "LoadBalancerBEAddressNatPool",
	            "properties": {
	              "backendPort": "3389",
	              "frontendIPConfiguration": {
	                "id": "[variables('lbIPConfig0')]"
	              },
	              "frontendPortRangeEnd": "4500",
	              "frontendPortRangeStart": "3389",
	              "protocol": "tcp"
	            }
	          }
	        ]
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-06-15",
	      "type": "Microsoft.Storage/storageAccounts",
	      "name": "[variables('uniqueStringArray0')[copyIndex()]]",
	      "location": "[parameters('computeLocation')]",
	      "properties": {
	        "accountType": "[variables('storageAccountType')]"
	      },
	      "copy": {
	        "name": "storageLoop",
	        "count": 5
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2016-03-30",
	      "type": "Microsoft.Compute/virtualMachineScaleSets",
	      "name": "[parameters('vmNodeType0Name')]",
	      "location": "[parameters('computeLocation')]",
	      "dependsOn": [
	        "[concat('Microsoft.Network/virtualNetworks/', variables('virtualNetworkName'))]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('uniqueStringArray0')[0])]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('uniqueStringArray0')[1])]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('uniqueStringArray0')[2])]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('uniqueStringArray0')[3])]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('uniqueStringArray0')[4])]",
	        "[concat('Microsoft.Network/loadBalancers/', concat('LB','-', parameters('clusterName'),'-',parameters('vmNodeType0Name')))]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('supportLogStorageAccountName'))]",
	        "[concat('Microsoft.Storage/storageAccounts/', variables('applicationDiagnosticsStorageAccountName'))]"
	      ],
	      "properties": {
	        "overprovision": "[parameters('overProvision')]",
	        "upgradePolicy": {
	          "mode": "Automatic"
	        },
	        "virtualMachineProfile": {
	          "extensionProfile": {
	            "extensions": [
	              {
	                "name": "[concat(parameters('vmNodeType0Name'),'_ServiceFabricNode')]",
	                "properties": {
	                  "type": "ServiceFabricNode",
	                  "autoUpgradeMinorVersion": false,
	                  "protectedSettings": {
	                    "StorageAccountKey1": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('supportLogStorageAccountName')),'2015-06-15').key1]",
	                    "StorageAccountKey2": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('supportLogStorageAccountName')),'2015-06-15').key2]"
	                  },
	                  "publisher": "Microsoft.Azure.ServiceFabric",
	                  "settings": {
	                    "clusterEndpoint": "[reference(parameters('clusterName')).clusterEndpoint]",
	                    "nodeTypeRef": "[parameters('vmNodeType0Name')]",
	                    "dataPath": "D:\\\\SvcFab",
	                    "durabilityLevel": "Bronze"
	                  },
	                  "typeHandlerVersion": "1.0"
	                }
	              },
	              {
	                "name": "[concat(parameters('vmNodeType0Name'),'OMS')]",
	                "properties": {
	                  "publisher": "Microsoft.EnterpriseCloud.Monitoring",
	                  "type": "MicrosoftMonitoringAgent",
	                  "typeHandlerVersion": "1.0",
	                  "autoUpgradeMinorVersion": true,
	                  "settings": {
	                    "workspaceId": "[reference(resourceId('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename')), '2015-11-01-preview').customerId]"
	                  },
	                  "protectedSettings": {
	                    "workspaceKey": "[listKeys(resourceId('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename')),'2015-11-01-preview').primarySharedKey]"
	                  }
	                }
	              },
	              {
	                "name": "[concat('VMDiagnosticsVmExt','_vmNodeType0Name')]",
	                "properties": {
	                  "type": "IaaSDiagnostics",
	                  "autoUpgradeMinorVersion": true,
	                  "protectedSettings": {
	                    "storageAccountName": "[variables('applicationDiagnosticsStorageAccountName')]",
	                    "storageAccountKey": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('applicationDiagnosticsStorageAccountName')),'2015-06-15').key1]",
	                    "storageAccountEndPoint": "https://core.windows.net/"
	                  },
	                  "publisher": "Microsoft.Azure.Diagnostics",
	                  "settings": {
	                    "WadCfg": {
	                      "DiagnosticMonitorConfiguration": {
	                        "overallQuotaInMB": "50000",
	                        "EtwProviders": {
	                          "EtwEventSourceProviderConfiguration": [
	                            {
	                              "provider": "Microsoft-ServiceFabric-Actors",
	                              "scheduledTransferKeywordFilter": "1",
	                              "scheduledTransferPeriod": "PT5M",
	                              "DefaultEvents": {
	                                "eventDestination": "ServiceFabricReliableActorEventTable"
	                              }
	                            },
	                            {
	                              "provider": "Microsoft-ServiceFabric-Services",
	                              "scheduledTransferPeriod": "PT5M",
	                              "DefaultEvents": {
	                                "eventDestination": "ServiceFabricReliableServiceEventTable"
	                              }
	                            }
	                          ],
	                          "EtwManifestProviderConfiguration": [
	                            {
	                              "provider": "cbd93bc2-71e5-4566-b3a7-595d8eeca6e8",
	                              "scheduledTransferLogLevelFilter": "Information",
	                              "scheduledTransferKeywordFilter": "4611686018427387904",
	                              "scheduledTransferPeriod": "PT5M",
	                              "DefaultEvents": {
	                                "eventDestination": "ServiceFabricSystemEventTable"
	                              }
	                            }
	                          ]
	                        }
	                      }
	                    },
	                    "StorageAccount": "[variables('applicationDiagnosticsStorageAccountName')]"
	                  },
	                  "typeHandlerVersion": "1.5"
	                }
	              }
	            ]
	          },
	          "networkProfile": {
	            "networkInterfaceConfigurations": [
	              {
	                "name": "[concat(variables('nicName'), '-0')]",
	                "properties": {
	                  "ipConfigurations": [
	                    {
	                      "name": "[concat(variables('nicName'),'-',0)]",
	                      "properties": {
	                        "loadBalancerBackendAddressPools": [
	                          {
	                            "id": "[variables('lbPoolID0')]"
	                          }
	                        ],
	                        "loadBalancerInboundNatPools": [
	                          {
	                            "id": "[variables('lbNatPoolID0')]"
	                          }
	                        ],
	                        "subnet": {
	                          "id": "[variables('subnet0Ref')]"
	                        }
	                      }
	                    }
	                  ],
	                  "primary": true
	                }
	              }
	            ]
	          },
	          "osProfile": {
	            "adminPassword": "[parameters('adminPassword')]",
	            "adminUsername": "[parameters('adminUsername')]",
	            "computernamePrefix": "[parameters('vmNodeType0Name')]"
	          },
	          "storageProfile": {
	            "imageReference": {
	              "publisher": "[variables('vmImagePublisher')]",
	              "offer": "[variables('vmImageOffer')]",
	              "sku": "[variables('vmImageSku')]",
	              "version": "[variables('vmImageVersion')]"
	            },
	            "osDisk": {
	              "vhdContainers": [
	                "[concat('https://', variables('uniqueStringArray0')[0], '.blob.core.windows.net/', variables('vmStorageAccountContainerName'))]",
	                "[concat('https://', variables('uniqueStringArray0')[1], '.blob.core.windows.net/', variables('vmStorageAccountContainerName'))]",
	                "[concat('https://', variables('uniqueStringArray0')[2], '.blob.core.windows.net/', variables('vmStorageAccountContainerName'))]",
	                "[concat('https://', variables('uniqueStringArray0')[3], '.blob.core.windows.net/', variables('vmStorageAccountContainerName'))]",
	                "[concat('https://', variables('uniqueStringArray0')[4], '.blob.core.windows.net/', variables('vmStorageAccountContainerName'))]"
	              ],
	              "name": "vmssosdisk",
	              "caching": "ReadOnly",
	              "createOption": "FromImage"
	            }
	          }
	        }
	      },
	      "sku": {
	        "name": "[variables('vmNodeType0Size')]",
	        "capacity": "5",
	        "tier": "Standard"
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2016-03-01",
	      "type": "Microsoft.ServiceFabric/clusters",
	      "name": "[parameters('clusterName')]",
	      "location": "[parameters('computeLocation')]",
	      "dependsOn": [
	        "[concat('Microsoft.Storage/storageAccounts/', variables('supportLogStorageAccountName'))]"
	      ],
	      "properties": {
	        "clientCertificateCommonNames": [ ],
	        "clientCertificateThumbprints": [ ],
	        "clusterState": "Default",
	        "diagnosticsStorageAccountConfig": {
	          "blobEndpoint": "[concat('https://',variables('supportLogStorageAccountName'),'.blob.core.windows.net/')]",
	          "protectedAccountKeyName": "StorageAccountKey1",
	          "queueEndpoint": "[concat('https://',variables('supportLogStorageAccountName'),'.queue.core.windows.net/')]",
	          "storageAccountName": "[variables('supportLogStorageAccountName')]",
	          "tableEndpoint": "[concat('https://',variables('supportLogStorageAccountName'),'.table.core.windows.net/')]"
	        },
	        "fabricSettings": [ ],
	        "managementEndpoint": "[concat('http://',reference(concat(variables('lbIPName'),'-','0')).dnsSettings.fqdn,':',variables('nt0fabricHttpGatewayPort'))]",
	        "nodeTypes": [
	          {
	            "name": "[parameters('vmNodeType0Name')]",
	            "applicationPorts": {
	              "endPort": "[variables('nt0applicationEndPort')]",
	              "startPort": "[variables('nt0applicationStartPort')]"
	            },
	            "clientConnectionEndpointPort": "[variables('nt0fabricTcpGatewayPort')]",
	            "durabilityLevel": "Bronze",
	            "ephemeralPorts": {
	              "endPort": "[variables('nt0ephemeralEndPort')]",
	              "startPort": "[variables('nt0ephemeralStartPort')]"
	            },
	            "httpGatewayEndpointPort": "[variables('nt0fabricHttpGatewayPort')]",
	            "isPrimary": true,
	            "vmInstanceCount": 5
	          }
	        ],
	        "provisioningState": "Default",
	        "reliabilityLevel": "Silver",
	        "vmImage": "Windows"
	      },
	      "tags": {
	        "resourceType": "Service Fabric",
	        "clusterName": "[parameters('clusterName')]"
	      }
	    },
	    {
	      "apiVersion": "2015-11-01-preview",
	      "location": "[parameters('omsRegion')]",
	      "name": "[parameters('omsWorkspacename')]",
	      "type": "Microsoft.OperationalInsights/workspaces",
	      "properties": {
	        "sku": {
	          "name": "Free"
	        }
	      },
	      "resources": [
	        {
	          "apiVersion": "2015-11-01-preview",
	          "name": "[concat(variables('applicationDiagnosticsStorageAccountName'),parameters('omsWorkspacename'))]",
	          "type": "storageinsightconfigs",
	          "dependsOn": [
	            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]",
	            "[concat('Microsoft.Storage/storageAccounts/', variables('applicationDiagnosticsStorageAccountName'))]"
	          ],
	          "properties": {
	            "containers": [ ],
	            "tables": [
	              "WADServiceFabric*EventTable",
	              "WADWindowsEventLogsTable",
	              "WADETWEventTable"
	            ],
	            "storageAccount": {
	              "id": "[resourceId('Microsoft.Storage/storageaccounts/', variables('applicationDiagnosticsStorageAccountName'))]",
	              "key": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('applicationDiagnosticsStorageAccountName')),'2015-06-15').key1]"
	            }
	          }
	        },
	        {
	          "apiVersion": "2015-11-01-preview",
	          "name": "Security",
	          "type": "datasources",
	          "dependsOn": [
	            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]",
	            "[concat('Microsoft.OperationsManagement/solutions/', variables('solutionsecurity'))]"
	          ],
	          "kind": "WindowsEvent",
	          "properties": {
	            "eventLogName": "Security",
	            "eventTypes": [
	              {
	                "eventType": "Error"
	              },
	              {
	                "eventType": "Warning"
	              },
	              {
	                "eventType": "Information"
	              }
	            ]
	          }
	        },
	        {
	          "apiVersion": "2015-11-01-preview",
	          "name": "System",
	          "type": "datasources",
	          "dependsOn": [
	            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]"
	          ],
	          "kind": "WindowsEvent",
	          "properties": {
	            "eventLogName": "System",
	            "eventTypes": [
	              {
	                "eventType": "Error"
	              },
	              {
	                "eventType": "Warning"
	              },
	              {
	                "eventType": "Information"
	              }
	            ]
	          }
	        },
	        {
	          "apiVersion": "2015-11-01-preview",
	          "name": "VMSS Queries2",
	          "type": "savedSearches",          
	          "dependsOn": [
	            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]"
	          ],
	          "properties": {
	            "Category": "VMSS",
	            "ETag": "*",
	            "DisplayName": "VMSS Instance Count",
	            "Query": "Type:Event Source=ServiceFabricNodeBootstrapAgent | dedup Computer | measure count () by Computer",
	            "Version": 1
	          }
	        },
	        {
	          "apiVersion": "2015-11-01-preview",
	          "name": "VMSS Queries",
	          "type": "savedSearches",
	          "dependsOn": [
	            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]"
	          ],
	          "properties": {
	            "Category": "VMSS",
	            "ETag": "*",
	            "DisplayName": "VMSS Instance Shut Down",
	            "Query": "Type:SecurityEvent EventID=4634 | select Computer",
	            "Version": 1
	          }
	        }
	      ]
	    },
	    {
	      "apiVersion": "2015-11-01-preview",
	      "location": "[parameters('omsRegion')]",
	      "name": "[variables('solution')]",
	      "type": "Microsoft.OperationsManagement/solutions",
	      "id": "[resourceId('Microsoft.OperationsManagement/solutions/', variables('solution'))]",
	      "dependsOn": [
	        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('OMSWorkspacename'))]"
	      ],
	      "properties": {
	        "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]"
	      },
	      "plan": {
	        "name": "[variables('solution')]",
	        "publisher": "Microsoft",
	        "product": "[Concat('OMSGallery/', variables('solutionName'))]",
	        "promotionCode": ""
	      }
	    },
	    {
	      "apiVersion": "2015-11-01-preview",
	      "location": "[parameters('omsRegion')]",
	      "name": "[variables('solutionsecurity')]",
	      "type": "Microsoft.OperationsManagement/solutions",
	      "id": "[resourceId('Microsoft.OperationsManagement/solutions/', variables('solutionsecurity'))]",
	      "dependsOn": [
	        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('OMSWorkspacename'))]"
	      ],
	      "properties": {
	        "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspacename'))]"
	      },
	      "plan": {
	        "name": "[variables('solutionsecurity')]",
	        "publisher": "Microsoft",
	        "product": "[Concat('OMSGallery/', variables('securitysolution'))]",
	        "promotionCode": ""
	      }
	    }
	  ],
	  "outputs": {
	    "clusterProperties": {
	      "value": "[reference(parameters('clusterName'))]",
	      "type": "object"
	    }
	  }
	}

Save the file to disk and deploy it into a new resource group. First using PowerShell, then into a new resource group using the template deployment experience in Azure portal.