# Lab 2 - Exploring Resource Manager Templates

>Last updated: 4/24/2017

>Author: krnese

## Azure Resource Manager Inside-Out

### Before you begin

The objective of this hackathon is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

### Lab 2 - Exploring Resource Manager Templates

### Objectives

In this lab, you will learn the basics of Resource Manager templates, and create a reusable template.
You will learn and explore more about the capabilities of ARM templates, how they work, the declarative approach, and that the Azure resources are idempotent.

**Scenario**

Your organization is pivoting over to the DevOps era, and are fairly new to Azure. 
Your company will start to leverage storage accounts in Azure for their applications, hence you need to create a reusable Resource Manager template. You want to ensure that they can successfully deploy this template every time.
Post deployment, the devs want to know the FQDN for the primary endpoint of the storage account, to be used by their web application.  

#### Creating a resource manager template for storage accounts

1. Start by creating a resource manager template that will create a storage account. Open your preferred JSON editor (Visual Studio or Visual Studio Code), and create a template similar to the example below

		{
    	"$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    	"contentVersion": "1.0.0.0",
    	"resources": [
        	{
        	    "apiVersion": "2015-06-15",
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

2. Save the template to a folder on your machine and try to do a deployment using PowerShell with the following cmdlet

		New-AzureRmResourceGroupDeployment -Name storageTest `
										   -ResourceGroupname <name of your existing resource group> `
										   -TemplateFile <directory where you saved your .json file> `
										   -Verbose

Did the template succeed? If no, why not? What was the error?

#### Adding parameters

3. The template was designed to be static with hard coded values for each property. A storage account in Azure need to have a unique name, which caused the deployment to fail. To mitigate this, we will add two parameters to the template, so the user can determine the storage account name and the location of it. Add two parameters to the template as shown below, and reflect these parameters in the resource section

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
	            "apiVersion": "2015-06-15",
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
To guarantee a level of uniqueness, we will add the following variable to the template and use the **uniqueString** function (string function that creates a deterministic hash string based on the values provided as parameters) to generate - a unique name for the storage account.
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
		            "apiVersion": "2015-06-15",
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

Did the deployment fail? If yes, what was the error?

7. To ensure that the storage account will be unique within the deployment, we will use **uniqueString** in conjunction with **deployment().name** - which will generate a unique string based on the name of the deployment. In addition, we will ensure that the string is in lower case by using the **toLower** function.

Modify your template to be similar to the example below

	{
	    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
	    "contentVersion": "1.0.0.0",
	    "parameters": {
	        "location": {
	            "type": "string"
	        }
	    },
	    "variables": {
	        "storageName": "[toLower(uniqueString(deployment().name))]"
	    },
	    "resources": [
	        {
	            "apiVersion": "2015-06-15",
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

8. Save the template to a directory on your machine, and do a new deployment using PowerShell similar to this:

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose
 

#### Adding Outputs

1. Templates can also provide outputs, which can be useful in case you need to retrieve information from resources in other resource groups, or from resources in the deployment itself. We will here use the **reference** function to retrieve a particular value from the storage account in the output section. Also, we are using **startsWith** function to verify if the storage account name starts with storage. Create a template similar to the example below, and note the output section. This will show the fqdn of the primary endpoint of the storage account that is created

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "location": {
		            "type": "string"
		        }
		    },
		    "variables": {
		        "storageName": "[concat('storage', uniqueString('storage'))]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-06-15",
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
		        },
		        "containsStorage": {
		            "type": "bool",
		            "value": "[startsWith(variables('storageName'), 'storage')]"
		        }
		    }
		}

2. Save the template to a directory on your machine, and do a new deployment using PowerShell similar to this:

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose

Verify that the template successfully deploys. If you didn't change the deployment name, you should not end up with another storage account since ARM and the resources are idempotent. Verify that you got the expected output.

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
		            "apiVersion": "2015-06-15",
		            "type": "Microsoft.Storage/storageAccounts",
		            "name": "[concat(variables('storageName'), copyIndex())]",
		            "location": "[parameters('location')]",
		            "tags": {},
		            "copy": {
		                "name": "blobCopy",
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

#### Resolving template issues

Based on the techniques you have used and learned so far, try to deploy the template below. If it fails, what are the required steps you must take to ensure a successful deployment, and limit the potential issues a user might run into when deploy a storage account using a template?

1. Copy and paste the template below into a json file that you save into a directory on your computer

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "storageName": {
		            "defaultValue": "MYSTORAGEACCOUNTINPRODUCTION",
		            "type": "string"            
		        },
		        "location": {
		            "type": "int"
		        }
		    },
		    "resources": [
		        {
		            "apiVersion": "2017-01-15",
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

2. Deploy the template using the following PowerShell cmdlets

		New-AzureRmResourceGroupDeployment -Name storageTest `
		                                   -ResourceGroupName <name of your existing resource group> `
		                                   -TemplateFile <path to your json file> `
		                                   -location <your preferred location> `
		                                   -Verbose `
										   -DeploymentDebugLogLevel All

How did you troubleshoot this template? Were you able to successfully deploy it?
Share the resolution you implemented.

#### Finalize the Resource Manager template

You are about to finalize the template, and share it with your devs. However, before you do so, you want to polish the template a bit, to make it more user friendly.

1. Copy and paste the template below into a json file that you save into a directory on your computer

		{
		    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
		    "contentVersion": "1.0.0.0",
		    "parameters": {
		        "storageNamePreFix": {
		            "type": "string",
		            "maxLength": 10,
		            "minLength": 3,
		            "metadata": {
		                "description": "Specify the pre-fix for the storage account name"
		            }
		        },
		        "location": {
		            "type": "string",
		            "metadata": {
		                "description": "Specify the Azure location for the storage account. Ex: 'eastus'"
		            }
		        },
		        "applicationEnvironment": {
		            "type": "string",
		            "defaultValue": "Test",
		            "metadata": {
		                "description": "Specify the environment for this application - for billing purposes"
		            }
		        }
		    },
		    "variables": {
		        "storageName": "[concat(parameters('storageNamePreFix'), uniqueString('storage'))]"
		    },
		    "resources": [
		        {
		            "apiVersion": "2015-06-15",
		            "type": "Microsoft.Storage/storageAccounts",
		            "name": "[variables('storageName')]",
		            "location": "[parameters('location')]",
		            "tags": {
		                "applicationEnvironment": "[parameters('applicationEnvironment')]"
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
		        },
		        "applicationEnvironment": {
		            "type": "string",
		            "value": "[parameters('applicationEnvironment')]"
		        }
		    }
		}

2. Notice what's been added. Can you limit the regions in the template to only allow *eastus* and *westeurope*? Once done, please share the template with the person next to you. If this person is able to deploy it successfully, you have completed this lab :-)
