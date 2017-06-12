# Lab 3 - Advanced Resource Manager Template

>Last updated: 6/12/2017

>Author: krnese

## Azure Resource Manager Inside-Out

>For questions or feedback, contact **krnese@microsoft.com**

### Before you begin

The objective of this training is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

### Lab 3 - Advanced Resource Manager Templates

### Objectives

In this lab, you will work on more advanced templates, and discover some new functions that will empower you to achieve more.

**Scenario**

Recently, your organization decided to move more of their application and services to Azure. The CIO wants you to leverage the native management services in Azure, to ensure a healthy and reliable environment for the business applications. It's important that both the management services, and the workloads can be deployed at scale, since your organization is planning to enable several 100 of Azure subscriptions within the next 4 months.
The CIO does also require that any approved Azure service should be managed automatically when being deployed.
To get started, you will deploy and configure Azure Log Analytics - which is able to monitor IaaS and PaaS. Next, you will create the base templates for new IaaS and PaaS workload, that will automatically connect to Azure Log Analytics during deployment. 

#### Creating a resource manager template for Azure Log Analytisc

For you to monitor and manage your organization's Azure environments and resources, you will deploy Azure Log Analytics using a Resource Manager template.

Open your preferred JSON editor (Visual Studio or Visual Studio Code), and create a template similar to the example below

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "omsWorkspaceName": {
		            "type": "string",
		            "metadata": {
		                "description": "Assign a name for the Log Analytic Workspace Name"
		            }
		        },
		        "omsWorkspaceRegion": {
		            "type": "string",
		            "allowedValues": [
		                "eastus",
		                "westeurope",
		                "southeastasia",
		                "australiasoutheast"
		            ],
		            "metadata": {
		                "description": "Specify the region for your Workspace"
		            }
		        }
		    },
		    "variables": {
		        "securitySolution": "[concat('Security', '(', parameters('omsWorkspaceName'), ')')]",
		        "updateSolution": "[concat('Updates', '(', parameters('omsWorkspaceName'), ')')]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-11-01-preview",
		            "location": "[parameters('omsWorkspaceRegion')]",
		            "name": "[parameters('omsWorkspaceName')]",
		            "type": "Microsoft.OperationalInsights/workspaces",
		            "comments": "Log Analytics workspace",
		            "properties": {
		                "sku": {
		                    "name": "perNode"
		                }
		            },
		            "resources": [
		                {
		                    "name": "AzureActivityLog",
		                    "type": "datasources",
		                    "apiVersion": "2015-11-01-preview",
		                    "dependsOn": [
		                        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		                    ],
		                    "kind": "AzureActivityLog",
		                    "properties": {
		                        "linkedResourceId": "[concat(subscription().id, '/providers/Microsoft.Insights/eventTypes/management')]"
		                    }
		                },
		                {
		                    "apiVersion": "2015-11-01-preview",
		                    "type": "datasources",
		                    "name": "LogicalDisk1",
		                    "dependsOn": [
		                        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		                    ],
		                    "kind": "WindowsPerformanceCounter",
		                    "properties": {
		                        "objectName": "LogicalDisk",
		                        "instanceName": "*",
		                        "intervalSeconds": 10,
		                        "counterName": "Avg Disk sec/Read"
		                    }
		                }
		            ]
		        },
		        {
		            "apiVersion": "2015-11-01-preview",
		            "type": "Microsoft.OperationsManagement/solutions",
		            "name": "[variables('securitySolution')]",
		            "location": "[parameters('omsWorkspaceRegion')]",
		            "dependsOn": [
		                "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		            ],
		            "properties": {
		                "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('omsWorkspaceName'))]"
		            },
		            "plan": {
		                "name": "[variables('securitySolution')]",
		                "product": "[concat('OMSGallery/', 'Security')]",
		                "promotionCode": "",
		                "publisher": "Microsoft"
		            }
		        },
		        {
		            "apiVersion": "2015-11-01-preview",
		            "type": "Microsoft.OperationsManagement/solutions",
		            "name": "[variables('updateSolution')]",
		            "location": "[parameters('omsWorkspaceRegion')]",
		            "dependsOn": [
		                "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		            ],
		            "properties": {
		                "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('omsWorkspaceName'))]"
		            },
		            "plan": {
		                "name": "[variables('updateSolution')]",
		                "product": "[concat('OMSGallery/', 'Updates')]",
		                "promotionCode": "",
		                "publisher": "Microsoft"
		            }
		        }
		    ],
		    "outputs": {}
		}

Save the file to disk and deploy it into a new resource group using PowerShell, with a cmdlet similar to this:

		New-AzureRmResourceGroupDeployment -Name workspace `
		                                   -ResourceGroupname (New-AzureRmResourceGroup -Name Workspace -location 'westeurope').ResourceGroupName `
		                                   -TemplateFile <path to your .json> `
										   -omsWorkspaceName <name your workspace> `
										   -omsWorkspaceRegion <select preferred region> `
		                                   -Verbose

#####Note:
In the previous example, we created a Log Analytics workspace, added a few datasources, and then we added two solutions (*Updates and Security*). We had to create a resource per each solution in this case. Assuming you would expand the template in the future, to include additional solutions, the template could potentially grow very large and become hard to maintain.
In the next example, you will learn a better approach, using **copyIndex** together with **lenght** to *iterate* through an array you define using a **complex variable** in the variables section, using only a single resource.

#### Deploying multiple resources using complex variables, copyIndex + lenght

Create a template similar to the one below
	
		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "omsWorkspaceName": {
		            "type": "string",
		            "metadata": {
		                "description": "Assign a name for the Log Analytic Workspace Name"
		            }
		        },
		        "omsWorkspaceRegion": {
		            "type": "string",
		            "allowedValues": [
		                "eastus",
		                "westeurope",
		                "southeastasia",
		                "australiasoutheast"
		            ],
		            "metadata": {
		                "description": "Specify the region for your Workspace"
		            }
		        }
		    },
		    "variables": {
		        "batch1": {
		            "solutions": [
		                {
		                    "name": "[concat('Security', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "Security"
		                },
		                {
		                    "name": "[concat('AgentHealthAssessment', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "AgentHealthAssessment"
		                },
		                {
		                    "name": "[concat('ChangeTracking', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "ChangeTracking"
		                },
		                {
		                    "name": "[concat('Updates', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "Updates"
		                },
		                {
		                    "name": "[concat('AzureActivity', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "AzureActivity"
		                },
		                {
		                    "name": "[concat('AzureAutomation', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "AzureAutomation"
		                },
		                {
		                    "name": "[concat('ADAssessment', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "ADAssessment"
		                },
		                {
		                    "name": "[concat('SQLAssessment', '(', parameters('omsWorkspaceName'), ')')]",
		                    "marketplaceName": "SQLAssessment"
		                }
		            ]
		        }
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-11-01-preview",
		            "location": "[parameters('omsWorkspaceRegion')]",
		            "name": "[parameters('omsWorkspaceName')]",
		            "type": "Microsoft.OperationalInsights/workspaces",
		            "comments": "Log Analytics workspace",
		            "properties": {
		                "sku": {
		                    "name": "perNode"
		                }
		            },
		            "resources": [
		                {
		                    "name": "AzureActivityLog",
		                    "type": "datasources",
		                    "apiVersion": "2015-11-01-preview",
		                    "dependsOn": [
		                        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		                    ],
		                    "kind": "AzureActivityLog",
		                    "properties": {
		                        "linkedResourceId": "[concat(subscription().id, '/providers/Microsoft.Insights/eventTypes/management')]"
		                    }
		                },
		                {
		                    "apiVersion": "2015-11-01-preview",
		                    "type": "datasources",
		                    "name": "LogicalDisk1",
		                    "dependsOn": [
		                        "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		                    ],
		                    "kind": "WindowsPerformanceCounter",
		                    "properties": {
		                        "objectName": "LogicalDisk",
		                        "instanceName": "*",
		                        "intervalSeconds": 10,
		                        "counterName": "Avg Disk sec/Read"
		                    }
		                }
		            ]
		        },
		        {
		            "apiVersion": "2015-11-01-preview",
		            "type": "Microsoft.OperationsManagement/solutions",
		            "name": "[concat(variables('batch1').solutions[copyIndex()].Name)]",
		            "location": "[parameters('omsWorkspaceRegion')]",
		            "dependsOn": [
		                "[concat('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName'))]"
		            ],
		            "copy": {
		                "name": "solutionCopy",
		                "count": "[length(variables('batch1').solutions)]"
		            },
		            "properties": {
		                "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces', parameters('omsWorkspaceName'))]"
		            },
		            "plan": {
		                "name": "[variables('batch1').solutions[copyIndex()].name]",
		                "product": "[concat('OMSGallery/', variables('batch1').solutions[copyIndex()].marketplaceName)]",
		                "promotionCode": "",
		                "publisher": "Microsoft"
		            }
		        }
		    ],
		    "outputs": {}
		}

Save the file to disk and deploy it into the existing resource group using PowerShell, with a cmdlet similar to this:

				New-AzureRmResourceGroupDeployment -Name workspace `
                                  		   -ResourceGroupname (New-AzureRmResourceGroup -Name Workspace -location 'westeurope').ResourceGroupName `
                                   		   -TemplateFile <path to your .json> `
										   -omsWorkspaceName <name your workspace> `
										   -omsWorkspaceRegion <select preferred region> `
                                           -Verbose

Can you update the array to include the following json, and redploy the template?

	            {
                    "name": "[concat('ServiceFabric', '(', parameters('omsWorkspaceName'), ')')]",
                    "marketplaceName": "ServiceFabric"
                }

#### Create a virtual network using a Resource Manager template

Before we proceed to deploy workloads that will connect to the Log Analytics workspace, we will have to create a virtual network where we can connect the virtual machines. 
Use the example template below to create a virtual network with a subnet

		{
		    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "vnetName": {
		            "type": "string"
		        },
		        "subnetName": {
		            "type": "string"
		        },
		        "vnetAddress": {
		            "type": "string",
		            "defaultValue": "10.0.0.0/16"
		        },
		        "subnetAddress": {
		            "type": "string",
		            "defaultValue": "10.0.0.0/24"
		        }
		    },
		    "variables": {},
		    "resources": [
		        {
		            "type": "Microsoft.Network/virtualNetworks",
		            "apiVersion": "2017-03-01",
		            "name": "[parameters('vnetName')]",
		            "location": "[resourceGroup().location]",
		            "properties": {
		                "addressSpace": {
		                    "addressPrefixes": [
		                        "[parameters('vnetAddress')]"
		                    ]
		                },
		                "subnets": [
		                    {
		                        "name": "[parameters('subnetName')]",
		                        "properties": {
		                            "addressPrefix": "[parameters('subnetAddress')]"
		                        }
		                    }
		                ]
		            }
		        }
		    ]
		}		

Save the template to disk. Deploy the template using PowerShell, to a new resource group in your preferred location. Please note the name of the subnet, vnet and the resource group you are deploying to.
	
		New-AzureRmResourceGroupDeployment -Name vNet `
		                                   -ResourceGroupName (New-AzureRmResourceGroup -Name <rg name> -Location <your location>).ResourceGroupName `
		                                   -TemplateFile <path to your .json> `
		                                   -vnetName <vNet name> `
		                                   -subnetName <subnet name> `
		                                   -Verbose



#### Create an IaaS template, attaching to Azure Log Analytics

Since your organization is frequently using both Linux and Windows, you want to create a template that supports both platforms, letting the developer decide prior to deployment. 
To support this, you will use *conditions* element with the *equals* function on the applicable resources. 

##### Create a base template

First, start with the following template in your json editor:

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

Exploring the template above, you can see that it will deploy a basic Windows VM, into a new virtual network.
We need to make several changes to this template, so it can:

* Deploy both Windows *and* Linux
* Connect to an existing virtual network
* Install the Azure Log Analytics VM extension

##### Adding parameters

Start by adding a few more parameters to the parameter section, where the user can provide input for platform, virtual network and Azure Log Analytics:

	"parameters": {
	        "vmNameSuffix": {
	            "type": "string",
	            "defaultValue": "VM",
	            "metadata": {
	                "description": "Assing a suffix for the VM you will create"
	            }
	        },
	        "platform": {
	            "type": "string",
	            "defaultValue": "Windows",
	            "allowedValues": [
	                "Windows",
	                "Linux"
	            ],
	            "metadata": {
	                "description": "Select the OS type to deploy"
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
	        "vNetName": {
	            "type": "string",
	            "defaultValue": "NWLAB",
	            "metadata": {
	                "description": "Select the virtual network to connect the VMs"
	            }
	        },
	        "vNetResourceGroupName": {
	            "type": "string",
	            "defaultValue": "NWLAB",
	            "metadata": {
	                "description": "Specify Resource Group for the corresponding vNet you selected"
	            }
	        },
	        "vnetSubnetName": {
	            "type": "string",
	            "defaultValue": "subnet1",
	            "metadata": {
	                "description": "Specify the subnet for the corresponding vNet and vNetResourceGroup you selected"
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
	        },
	        "ssh": {
	            "type": "string",
	            "metadata": {
	                "description": "If Linux, specify the SSH to use"
	            }
	        },
	        "azureLogAnalyticsWorkspaceName": {
	            "type": "string",
	            "metadata": {
	                "description": "Specify the Azure Log Analytics name"
	            }
	        },
	        "azureLogAnalyticsResourceGroupName": {
	            "type": "string",
	            "metadata": {
	                "description": "Specify the Resource Group containing your Azure Log Analytics resource"
	            }
	        }
	    },

##### Adding variables

Next, you will expand and modify the existing variables section, to add support for Linux and using an existing virtual network. Note the usage of complex variables, which we will later use when referencing the properties:

	"variables": {
	        "storageAccountName": "[toLower(concat('st', uniquestring(resourceGroup().name)))]",
	        "vnetID": "[resourceId(parameters('vnetResourceGroupName'), 'Microsoft.Network/virtualnetworks', parameters('vNetName'))]",
	        "subnetRef": "[concat(variables('vnetID'),'/subnets/', parameters('vNetSubnetName'))]",
	        "managementTypeWindows": {
	            "type": "MicrosoftMonitoringAgent"
	        },
	        "managementTypeLinux": {
	            "type": "OmsAgentForLinux"
	        },
	        "osTypeWindows": {
	            "imageOffer": "WindowsServer",
	            "imageSku": "2016-Datacenter",
	            "imagePublisher": "MicrosoftWindowsServer"
	        },
	        "osTypeLinux": {
	            "imageOffer": "UbuntuServer",
	            "imageSku": "12.04.5-LTS",
	            "imagePublisher": "Canonical"
	        }
	    },

##### Add conditions

To support *conditions*, we need to modify the virtualMachines resource. By adding *"[equals(parameters'platform'), 'Windows')]", Resource Manager will check if the condition is met during runtime, and either deploy if equals = true, or ignore if equals = false. Modify the resource to support this:

			{
	            "condition": "[equals(parameters('platform'), 'Windows')]",
	            "type": "Microsoft.Compute/virtualMachines",
	            "apiVersion": "2017-03-30",
	            "name": "[concat(parameters('vmNameSuffix'), 'wVM')]",
	            "location": "[resourceGroup().location]",
	            "dependsOn": [
	                "[concat('Microsoft.Storage/StorageAccounts/', variables('storageAccountName'))]",
	                "[concat('Microsoft.Network/networkinterfaces/', parameters('vmNameSuffix'), 'nic')]"
	            ],
	            "properties": {
	                "hardwareprofile": {
	                    "vmsize": "[parameters('vmSize')]"
	                },
	                "osProfile": {
	                    "computername": "[concat(parameters('vmNameSuffix'), 'wVM')]",
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
	                            "id": "[resourceId('Microsoft.Network/networkinterfaces', concat(parameters('vmNameSuffix'),'nic'))]"
	                        }
	                    ]
	                }
	            }
	        },

Next, we need to the same to support Linux workload, having the same logic using the "platform" parameter to make the decision:

			{
	            "condition": "[equals(parameters('platform'), 'Linux')]",
	            "type": "Microsoft.Compute/virtualMachines",
	            "apiVersion": "2017-03-30",
	            "name": "[concat(parameters('vmNameSuffix'), 'lVM')]",
	            "location": "[resourceGroup().location]",
	            "dependsOn": [
	                "[concat('Microsoft.Storage/StorageAccounts/', variables('storageAccountName'))]",
	                "[concat('Microsoft.Network/networkinterfaces/', parameters('vmNameSuffix'), 'nic')]"
	            ],
	            "properties": {
	                "hardwareprofile": {
	                    "vmsize": "[parameters('vmSize')]"
	                },
	                "osProfile": {
	                    "computername": "[concat(parameters('vmNameSuffix'), 'lVM')]",
	                    "adminusername": "[parameters('username')]",
	                    "adminpassword": "[parameters('ssh')]"
	                },
	                "storageProfile": {
	                    "imageReference": {
	                        "publisher": "[variables('osTypeLinux').imagePublisher]",
	                        "offer": "[variables('osTypeLinux').imageOffer]",
	                        "version": "latest",
	                        "sku": "[variables('osTypeLinux').imageSku]"
	                    },
	                    "osdisk": {
	                        "name": "osdisk",
	                        "vhd": {
	                            "uri": "[concat('http://', variables('storageAccountName'), '.blob.core.windows.net/', 'vhds', '/', 'osdisk', '.vhd')]"
	                        },
	                        "caching": "readwrite",
	                        "createoption": "FromImage"
	                    }
	                },
	                "networkprofile": {
	                    "networkinterfaces": [
	                        {
	                            "id": "[resourceId('Microsoft.Network/networkinterfaces', concat(parameters('vmNameSuffix'),'nic'))]"
	                        }
	                    ]
	                }
	            }
	        },

So far, we have modified the template to support both Linux and Windows. The next step would be to add an *extensions* resource type which will be a nested resource to *virtualMachines*.
Please note that the same logic for conditions need to be applied here, where the extension for Linux will follow the Linux VM, and vice versa for Windows.

##### Add VM Extensions

For Windows, add the following *extensions* resource type:

        {
            "condition": "[equals(parameters('platform'), 'Windows')]",
            "apiVersion": "2017-03-30",
            "type": "Microsoft.Compute/virtualMachines/extensions",
            "name": "[concat(parameters('vmNameSuffix'), 'wVM', '/OMS')]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('vmNameSuffix'), 'wVM')]"
            ],
            "properties": {
                "publisher": "Microsoft.EnterpriseCloud.Monitoring",
                "type": "[variables('managementTypeWindows').type]",
                "typeHandlerVersion": "1.0",
                "autoUpgradeMinorVersion": true,
                "settings": {
                    "workspaceId": "[reference(resourceId(parameters('azureLogAnalyticsResourceGroupName'), 'Microsoft.OperationalInsights/workspaces/', parameters('azureLogAnalyticsWorkspaceName')), '2015-11-01-preview').customerId]",
                    "azureResourceId": "[resourceId('Microsoft.Compute/virtualMachines/', concat(parameters('vmNameSuffix'), 'wVM'))]"
                },
                "protectedSettings": {
                    "workspaceKey": "[listKeys(resourceId(parameters('azureLogAnalyticsResourceGroupName'),'Microsoft.OperationalInsights/workspaces/', parameters('azureLogAnalyticsWorkspaceName')), '2015-11-01-preview').primarySharedKey]"
                }
            }
        },

For Linux, add the following *extensions* resource type:

        {
            "condition": "[equals(parameters('platform'), 'Linux')]",
            "apiVersion": "2017-03-30",
            "type": "Microsoft.Compute/virtualMachines/extensions",
            "name": "[concat(parameters('vmNameSuffix'), 'lVM', '/OMS')]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('vmNameSuffix'), 'lVM')]"
            ],
            "properties": {
                "publisher": "Microsoft.EnterpriseCloud.Monitoring",
                "type": "[variables('managementTypeLinux').type]",
                "typeHandlerVersion": "1.3",
                "autoUpgradeMinorVersion": true,
                "settings": {
                    "workspaceId": "[reference(resourceId(parameters('azureLogAnalyticsResourceGroupName'), 'Microsoft.OperationalInsights/workspaces/', parameters('azureLogAnalyticsWorkspaceName')), '2015-11-01-preview').customerId]",
                    "azureResourceId": "[resourceId('Microsoft.Compute/virtualMachines/', concat(parameters('vmNameSuffix'), 'lVM'))]"
                },
                "protectedSettings": {
                    "workspaceKey": "[listKeys(resourceId(parameters('azureLogAnalyticsResourceGroupName'),'Microsoft.OperationalInsights/workspaces/', parameters('azureLogAnalyticsWorkspaceName')), '2015-11-01-preview').primarySharedKey]"
                }
            }
        }

Pay attention to the *settings* and *protectedSettings* for the extensions. We're using *reference* to return an object representing a resource runtime state, which helps us to retrieve the workspace Id for Log Analytics. Further, we are using *listKeys* which will return the workspace Key. This makes it easier to onboard, as we don't have to ask for these values using parameters, but simply rather ask for the name and resource group.
To help identifying the virtual machine within Log Analytics, we are also using *resourceId*, which will return the unique identifier of an Azure resource.

##### Deploy

Modify the following PowerShell snippet to reflect the resources you have already deployed so far, for Azure Log Analytics and virtual network.

First, you will deploy *Windows* workload to a new resource group.

	$rgName = 'myResourceGroup'
	$rgLocation = 'westeurope'
	
	New-AzureRmResourceGroupDeployment -Name Windows `
	                                   -ResourceGroupName (New-AzureRmResourceGroup -Name $rgName -Location $rgLocation).ResourceGroupName `
	                                   -TemplateFile <pathToYourTemplate> `
	                                   -platform Windows `
	                                   -vmNameSuffix <vmNameSuffix `
	                                   -azureLogAnalyticsWorkspaceName <workspaceName> `
	                                   -azureLogAnalyticsResourceGroupName <workspaceRgName> `
	                                   -username <yourUsername> `
	                                   -ssh <yourSsh> `
	                                   -vNetName <existingvNetName> `
	                                   -vNetResourceGroupName <existingvNetRgName> `
	                                   -vNetSubnetName <existingvNetSubnetName> `
	                                   -Verbose

Next, deploy *Linux* workload to a new resource group

	$rgName = 'myResourceGroup'
	$rgLocation = 'westeurope'
	
	New-AzureRmResourceGroupDeployment -Name Linux `
	                                   -ResourceGroupName (New-AzureRmResourceGroup -Name $rgName -Location $rgLocation).ResourceGroupName `
	                                   -TemplateFile <pathToYourTemplate> `
	                                   -platform Linux `
	                                   -vmNameSuffix <vmNameSuffix `
	                                   -azureLogAnalyticsWorkspaceName <workspaceName> `
	                                   -azureLogAnalyticsResourceGroupName <workspaceRgName> `
	                                   -username <yourUsername> `
	                                   -ssh <yourSsh> `
	                                   -vNetName <existingvNetName> `
	                                   -vNetResourceGroupName <existingvNetRgName> `
	                                   -vNetSubnetName <existingvNetSubnetName> `
	                                   -Verbose

