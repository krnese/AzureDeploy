# Lab 4 - Nested Resource Manager Templates

>Last updated: 6/13/2017

>Author: krnese

### Azure Resource Manager - Demystified

>For questions or feedback, contact **krnese@microsoft.com**

### Before you begin

The objective of this training is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

### Lab 4 - Nested Resource Manager Templates

### Objectives

In this lab, you will work on nested templates and deployments, to implement best practices and instantiate more complex solutions in Azure. You'll work through different tasks, which will introduce you to new functions and techniques.

**Scenario**

Your CIO validated the work you recently did. Although he is happy about meeting his requirements, he has decided to expand the scope a bit.
Moving forward, he wants you to create a baseline for a new Azure environment, where the VM workload is entirely managed by Azure management services, but separated into its own Resource Group. Post deployment, the operations team should have access to a customized dashboard for easy access, and the environment should be highly automated with several Automation runbooks.

As you have started to become more familiar and experienced with Resource Manager and templates, you come up with the following high-level tasks you need to complete

* Since this will be production workload, you need to ensure it's entirely managed, with monitoring and backup
* You need to ensure that the operation teams have access to automation runbooks, so they can manage the workloads at scale
* You need to split the resources into two or more Resource Groups
* You don't want to end up with a gigantic template to manage, so you decided to spread the resources across multiple templates, so they can be used independently - and together
* To limit the need for documentation, you want to create a customized Azure dashboard that includes everything the operation team will need
* You want the solution to scale across Azure subscriptions, so it becomes a standard within your company


#### Examining the nested templates

The nested templates we'll work with throughout this lab, is located in this [folder](./lab4).
Please spend some time to explore the structure of each template, to see how they are constructed. The main objective of this lab, is to create the main template that will invoke the nested templates, in the right order, into the right resource groups.

If you have opened the folder, you can see we have 8 *nested* templates in total.

* **omsAutomation.json, omsWorkspace.json, and omsRecoveryServices.json**

These templates provides the foundation of the Azure management services we will be using, and represent Azure Automation, Azure Log Analytics and Azure Recovery Services (Backup & Site Recovery). 

Since we want to deploy VM workloads as part of the deployment, it's important that these services are deployed *first*. 

* **asrRunbooks.json, dscConfigs.json**

These templates provides additional artifacts related to Azure Automation and DSC. Since they take a dependency on the parent resource (Automation account), it's important that the *omsAutomation.json* has been deployed before these deployments kicks in.

* **managedVms.json**

The virtual machine workload will be deployed into a new virtual network, and attach to the management services. This means that this template should be one of the last templates being deployed.

* **managedVmsBackup.json**

You can't enable backup before the management services (Azure Backup) *and* the workload has been provisioned

* **managedVmsBackup.json**

One of the last step, once the management services and the workload have been deployed, is to enable backup on the virtual machines.

* **mgmtDashboard**

Once all the resources are deployed, a last nested template will be invoked to create an Azure dashboard for the operations team

#### Creating the main template

Let's first start with the skeleton of the main template, which contains the *resources* of the nested template deployments. You should copy the JSON below into your JSON editor, and build out the rest of the template as we proceed:

	{
	    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
	    "contentVersion": "1.0.0.0",
	    "parameters": {},
	    "variables": {},
	    "resources": [
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "omsWorkspace",
	            "dependsOn": [],
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "omsRecoveryServices",
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "omsAutomation",
	            "dependsOn": [],
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "asrRunbooks",
	            "dependsOn": [],
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "dscConfigs",
	            "dependsOn": [],
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "deployVMs",
	            "resourceGroup": "",
	            "dependsOn": [],
	            "properties": {}
	        },
	        {
	            "type": "Microsoft.Resources/deployments",
	            "apiVersion": "2017-05-10",
	            "name": "mgmtDashboards",
	            "dependsOn": [],
	            "properties": {}
	        }
	    ],
	    "outputs": {}
	}

If you look closely at the skeleton, you will notice that each deployment reflects the nested templates we're about to use, except the *managedVmsBackup.json*. When enabling backup, we will actually trigger the deployment within the nested *managedVms.json* template itself. Also, note that the resource for *deployVMs* is using the resourceGroup property, which means we will deploy the workload to a separate resource group. 

##### Adding parameters

Parameters is needed, and the parameters we'll use must be reflected in the *nested* templates too.

Add the following parameters to the template:

    "parameters": {
        "omsRecoveryVaultName": {
            "type": "string",
            "metadata": {
                "description": "Assign a name for the ASR Recovery Vault"
            }
        },
        "omsRecoveryVaultRegion": {
            "type": "string",
            "defaultValue": "West Europe",
            "allowedValues": [
                "West US",
                "East US",
                "North Europe",
                "West Europe",
                "Brazil South",
                "East Asia",
                "Southeast Asia",
                "North Central US",
                "South Central US",
                "Japan East",
                "Japan West",
                "Australia East",
                "Australia Southeast",
                "Central US",
                "East US 2",
                "Central India",
                "South India"
            ],
            "metadata": {
                "description": "Specify the region for your Recovery Vault"
            }
        },
        "omsWorkspaceName": {
            "type": "string",
            "metadata": {
                "description": "Assign a name for the Log Analytic Workspace Name"
            }
        },
        "omsWorkspaceRegion": {
            "type": "string",
            "defaultValue": "West Europe",
            "allowedValues": [
                "East US",
                "West Europe",
                "Southeast Asia",
                "Australia Southeast"
            ],
            "metadata": {
                "description": "Specify the region for your Workspace"
            }
        },
        "omsAutomationAccountName": {
            "type": "string",
            "metadata": {
                "description": "Assign a name for the Automation account"
            }
        },
        "omsAutomationRegion": {
            "type": "string",
            "defaultValue": "West Europe",
            "allowedValues": [
                "Japan East",
                "East US 2",
                "West Europe",
                "Southeast Asia",
                "South Central US",
                "North Europe",
                "Canada Central",
                "Australia Southeast",
                "Central India",
                "Japan East"
            ],
            "metadata": {
                "description": "Specify the region for your Automation account"
            }
        },
        "_artifactsLocation": {
            "type": "string",
            "defaultValue": "https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/lab4/",
            "metadata": {
                "description": "The base URI where artifacts required by this template are located"
            }
        },
        "_artifactsLocationSasToken": {
            "type": "securestring",
            "defaultValue": "",
            "metadata": {
                "description": "The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated"
            }
        },
        "azureAdmin": {
            "type": "string",
            "metadata": {
                "description": "Enter your service admin user"
            }
        },
        "azureAdminPwd": {
            "type": "securestring",
            "metadata": {
                "description": "Enter the pwd for the service admin user. The pwd is enrypted during runtime and in the Automation assets"
            }
        },
        "instanceCount": {
            "type": "int",
            "defaultValue": 2,
            "maxValue": 10,
            "metadata": {
                "description": "Specify the number of VMs to create"
            }
        },
        "vmNameSuffix": {
            "type": "string",
            "defaultValue": "VM",
            "metadata": {
                "description": "Assing a suffix for the VMs you will create"
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
            ]
        },
        "username": {
            "type": "string",
            "defaultValue": "azureadmin"
        },
        "pwd": {
            "type": "securestring"
        },
        "vmResourceGroup": {
            "type": "string"
        },
        "DSCJobGuid": {
          "type": "string"
        },
        "DSCJobGuid2": {
          "type": "string"
        },
        "DSCJobGuid3": {
          "type": "string"
        }
    },

Notice the *_artifactsLocation* parameter. This has a default value which points to the URL containing the nested templates.
To be more specific towards each template needed, we'll add the following variables to the main template.

##### Adding variables

    "variables": {
        "nestedTemplates": {
            "omsRecoveryServices": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/omsRecoveryServices.json', parameters('_artifactsLocationSasToken'))]",
            "omsAutomation": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/omsAutomation.json', parameters('_artifactsLocationSasToken'))]",
            "omsWorkspace": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/omsWorkspace.json', parameters('_artifactsLocationSasToken'))]",
            "managedVMs": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/managedVms.json', parameters('_artifactsLocationSasToken'))]",
            "asrRunbooks": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/asrRunbooks.json', parameters('_artifactsLocationSasToken'))]",
            "dscConfigs": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/dscConfigs.json', parameters('_artifactsLocationSasToken'))]",
            "mgmtDashboards": "[concat(parameters('_artifactsLocation'), '/nestedtemplates/mgmtDashboards.json', parameters('_artifactsLocationSasToken'))]"
        }
    },

This makes the template more dynamic. In case you are switching location (GitHub repo, or using a storage account), you simply change the value for the *_artifactsLocation* parameter. We're also using *_artifactsLocationSasToken* as a placeholder if ever a SAS token will be used.

##### Adding resources
###### Azure Log Analytics
Now it's time to modify the resources in the main template. We'll start with the *omsWorkspace* resource, which will trigger a nested deployment of the Azure Log Analytics resource.

        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2017-05-10",
            "name": "omsWorkspace",
            "dependsOn": [],
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('nestedTemplates').omsWorkspace]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "omsWorkspaceName": {
                        "value": "[parameters('omsWorkspaceName')]"
                    },
                    "omsWorkspaceRegion": {
                        "value": "[parameters('omsWorkspaceRegion')]"
                    }
                }
            }
        },

This resource doesn't have any dependencies, which means it will be deployed in parallel with any other resource that doesn't have a dependency in the chain of templates. 
Notice the "uri" is pointing to the omsWorkspace.json template, and we are reflecting two of the parameters declared at the top in this main template in the properties envelope.

###### Azure Recovery Services
The next resource we'll add, is the nested deployment for Azure Recovery Services.

	{
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2017-05-10",
            "name": "omsRecoveryServices",
            "dependsOn": [],            
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('nestedTemplates').omsRecoveryServices]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "omsRecoveryVaultName": {
                        "value": "[parameters('omsRecoveryVaultName')]"
                    },
                    "omsRecoveryVaultRegion": {
                        "value": "[parameters('omsRecoveryVaultRegion')]"
                    }
                }
            }
        },

This template doesn't have any dependencies, which means it will be deployed in parallel together with the Azure Log Analytics resource.

###### Azure Automation
When adding Azure Automation to the main template, we'll use multiple parameters.

	{
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2017-05-10",
            "name": "omsAutomation",
            "dependsOn": [
                "[concat('Microsoft.Resources/deployments/', 'omsRecoveryServices')]",
                "[concat('Microsoft.Resources/deployments/', 'omsWorkspace')]"
            ],
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('nestedTemplates').omsAutomation]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "omsAutomationAccountName": {
                        "value": "[parameters('omsAutomationAccountName')]"
                    },
                    "omsAutomationRegion": {
                        "value": "[parameters('omsAutomationRegion')]"
                    },
                    "omsRecoveryVaultName": {
                        "value": "[parameters('omsRecoveryVaultName')]"
                    },
                    "omsWorkspaceName": {
                        "value": "[parameters('omsWorkspaceName')]"
                    },
                    "azureAdmin": {
                        "value": "[parameters('azureAdmin')]"
                    },
                    "azureAdminPwd": {
                        "value": "[parameters('azureAdminPwd')]"
                    },
                    "_artifactsLocation": {
                        "value": "[parameters('_artifactsLocation')]"
                    },
                    "_artifactsLocationSasToken": {
                        "value": "[parameters('_artifactsLocationSasToken')]"
                    }
                }
            }
        },

You'll notice that we'll provide values for the majority of the parameters we're using, and the deployment has dependencies to the Azure Log Analytics and Azure Recovery Services deployments.
The reason for this, is because we're retrieving some values from these services dynamically during template runtime. More specific, we create automation variables in the Automation account, to contain the workspace Id and workspace Key from Azure Log Analytics, and details from the backup policy within Azure Recovery Services.

If you explore the *omsAutomation.json* template, you can find a nested resource that shows how this is done:

	{
          "name": "[variables('omsWorkspaceId')]",
          "type": "variables",
          "apiVersion": "2015-10-31",
          "dependsOn": [
            "[concat('Microsoft.Automation/automationAccounts/', parameters('omsAutomationAccountName'))]"
          ],
          "tags": { },
          "properties": {
            "description": "OMS Workspace Id",
            "value": "[concat('\"',reference(resourceId('Microsoft.OperationalInsights/workspaces/', parameters('omsWorkspaceName')),'2015-11-01-preview').customerId,'\"')]"
          }
        },

###### Azure Automation artifacts
Remember that we want these templates to work on it's own too, so they can be used outside of this context.
That's why we have additional templates that deploys artifacts to an Azure Automation account.
The first one will add several automation runbooks to the automation account. Add the following resource to your main template, and ensure it has a dependency to the automation deployment declared earlier:

	{
          "type": "Microsoft.Resources/deployments",
          "apiVersion": "2017-05-10",
          "name": "asrRunbooks",
          "dependsOn": [
            "omsAutomation"
          ],
          "properties": {
            "mode": "Incremental",
            "templateLink": {
              "uri": "[variables('nestedTemplates').asrRunbooks]",
              "contentVersion": "1.0.0.0"
            },
            "parameters": {
              "automationAccountName": {
                "value": "[parameters('omsAutomationAccountName')]"
              },
              "automationRegion": {
                "value": "[parameters('omsAutomationRegion')]"
              }
            }
          }          
        },

The second template containing automation artifacts, will deploy several DSC configurations.
Add the following section to your template, and ensure it has a dependency to the automaton deployment:

	{
	          "type": "Microsoft.Resources/deployments",
	          "apiVersion": "2017-05-10",
	          "name": "dscConfigs",
	          "dependsOn": [
	            "omsAutomation"
	          ],
	          "properties": {
	            "mode": "Incremental",
	            "templateLink": {
	              "uri": "[variables('nestedTemplates').dscConfigs]",
	              "contentVersion": "1.0.0.0"
	            },
	            "parameters": {
	              "omsAutomationAccountName": {
	                "value": "[parameters('omsAutomationAccountName')]"
	              },
	              "omsAutomationRegion": {
	                "value": "[parameters('omsAutomationRegion')]"
	              },
	              "omsWorkspaceName": {
	                "value": "[parameters('omsWorkspaceName')]"
	              },
	              "DSCJobGuid": {
	                "value": "[parameters('DSCJobGuid')]"
	              },
	              "DSCJobGuid2": {
	                "value": "[parameters('DSCJobGuid2')]"
	              },
	              "DSCJobGuid3": {
	                "value": "[parameters('DSCJobGuid3')]"
	              }
	            }
	          }          
	        },

###### Adding VM workload
Once the management services are instantiated, we can safely deploy the VM workload which will attach to these services. Add this section to your main template:

        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2017-05-10",
            "name": "deployVMs",
            "resourceGroup": "[parameters('vmResourceGroup')]",
            "dependsOn": [
              "omsWorkspace",
              "omsRecoveryServices"
            ],
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[variables('nestedTemplates').managedVMs]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "instanceCount": {
                        "value": "[parameters('instanceCount')]"
                    },
                    "vmNameSuffix": {
                        "value": "[parameters('vmNameSuffix')]"
                    },
                    "platform": {
                        "value": "[parameters('platform')]"
                    },
                    "vmSize": {
                        "value": "[parameters('vmSize')]"
                    },
                    "userName": {
                        "value": "[parameters('userName')]"
                    },
                    "pwd": {
                        "value": "[parameters('pwd')]"
                    },
                    "omsRecoveryVaultName": {
                        "value": "[parameters('omsRecoveryVaultName')]"
                    },
                    "omsRecoveryVaultRegion": {
                        "value": "[parameters('omsRecoveryVaultRegion')]"
                    },
                    "omsResourceGroup": {
                        "value": "[resourceGroup().name]"
                    },
                    "omsWorkspaceName": {
                        "value": "[parameters('omsWorkspaceName')]"
                    }
                }
            }
        },

###### Enabling VM Backup
Explore the *managedVms.json* template. In the end, you can see that another nested deployment will start, once the VM extension for OMS has completed. This will start a deployment to the resource group holding the Azure Recovery Services resource. 

###### Adding Azure dashboard

The final step of the main template, is to add the resource pointing to the Azure dashboard nested template.

	{
          "type": "Microsoft.Resources/deployments",
          "apiVersion": "2017-05-10",
          "name": "mgmtDashboards",
          "dependsOn": [
            "omsAutomation",
            "omsWorkspace",
            "omsRecoveryServices"
          ],
          "properties": {
            "mode": "Incremental",
            "templateLink": {
              "uri": "[variables('nestedTemplates').mgmtDashboards]",
              "contentVersion": "1.0.0.0"              
            },
            "parameters": {
              "omsWorkspaceName": {
                "value": "[parameters('omsWorkspaceName')]"
              },
              "omsRecoveryVaultName": {
                "value": "[parameters('omsRecoveryVaultName')]"
              },
              "omsAutomationAccountName": {
                "value": "[parameters('omsAutomationAccountName')]"
              },
              "vmResourceGroup": {
                "value": "[parameters('vmResourceGroup')]"
              }
            }
          }
        }

The deployment of this nested template will kick in once the management services has been successfully deployed.

