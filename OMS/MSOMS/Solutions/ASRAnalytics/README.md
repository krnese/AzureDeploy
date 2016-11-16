# Azure Site Recovery Analytics

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2AzureDeploy%2Fmaster%2FOMS%2FMSOMS%2FSolutions%2FASRAnalytics%2Fazuredeploy.json) 
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2krnese%2AzureDeploy%2Fmaster%2FOMS%2FMSOMS%2FSolutions%2FASRAnalytics%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/Solutions/ASRAnalytics/azuredeploy.json

>[AZURE.NOTE]This is preliminary documentation Azure Site Recovery Analytics in OMS which is currently in preview. 

Azure Site Recovery Analytics will monitor your Recovery Vault in Azure (ARM) and visualize the data in Log Analytics. The data ingestion is currently based on a PowerShell Runbook that will be deployed to your Automation Account.

![alt text](images/overview.png "Overview")

## Pre-reqs

- **Hyper-V 2 Azure or/and VMware/Physical 2 Azure**

The current ASR Analytics solution is mainly targeting Hyper-V To Azure and VMWare/Physical To Azure scenarios. If you have Recovery Vaults configured for one of these scenarios, it will automatically show up in the Log Analytics workspace after the first runbook execution. 


- **Automation Account with SPN**

Before you deploy this template, you must create an Automation Account in the Azure portal with the default settings so that the SPN account will be created. If you have an existing OMS Log Analytics Workspace you would like to use for this OMS ASR solution, it is important that the Automation account is created into the **same Resource Group where the OMS Log Analytics Workspace is located**.

If you **dont** have an existing OMS Log Analytics Workspace, the template will create and deploy this for you.

## Setup - Using an existing OMS Log Analytics Workspace

### Follow these instructions to deploy the OMS ASR Solution into an existing OMS Log Analytics Workspace

Log into Azure Portal (https://portal.azure.com) and ensure you are in the subscription containing your OMS Workspace

Locate your existing OMS Log Analytics Workspace and note the name of the workspace, the location of the workspace, and the Resource Group

![alt text](images/knomsworkspace.png "omsws") 

Next, create a new Automation Account and click on *New* and search for 'Automation'

![alt text](images/knautomation.png "automation")
 
Select Automation and click *Create* 

![alt text](images/kncreate.png "create")

Specify the name of the Automation Account and ensure you are selecting 'Use existing' and selects the Resource Group containing the OMS Log Analytics workspace. If possible, use the same Azure Region for the Automation Account. Ensure that 'Create Azure Run As account' is set to 'Yes' and click 'Create'

![alt text](images/knaaccount.png "Create account") 

Once the deployment has completed, you should see the Automation account and the Log Analytics workspace in the same Resource Group

![alt text](images/knrg.png "Resource Group")

###You can now deploy the template   
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2AzureDeploy%2Fmaster%2FOMS%2FMSOMS%2FSolutions%2FASRAnalytics%2Fazuredeploy.json) 

This will send you to the Azure Portal with some default values for the template parameters. 
Ensure that the parameters reflects your setup so that you are deploying this into the *existing* Resource Group containing the Log Analytics Workspace and the Automation account.

*It is important that you type the exact values for your workspace name and automation account name, and points to the regions where these resources are deployed.* 

You should also change the *INGESTSCHEDULEGUID* value. You can generate your own using PowerShell with the following cmdlet:


![alt text](images/knguid.png "guid")

Once you have customized all the parameters, click *Create*

![alt text](images/knarmtemp.png "template")

The ingestion will start 5-10 minutes post deployment.

Note: You will not see any data ingestion if you don't have any Recovery Vaults in your subscription

## Setup - Creating a new OMS Log Analytics Workspace

### Follow these instructions to deploy the OMS ASR Solution into a new OMS Log Analytics Workspace

Log into Azure Portal (https://portal.azure.com) and ensure you are in the subscription where you want to deploy the OMS ASR Solution

Create a new Automation Account and click on *New* and search for 'Automation'

![alt text](images/knautomation.png "automation")
 
Select Automation and click *Create* 

![alt text](images/kncreate.png "create")

Specify the name of the Automation Account and create the account into a new Resource Group. Ensure that 'Create Azure Run As account' is set to 'Yes' and click 'Create'

![alt text](images/knnewrg.png "Create account") 

Once the deployment has completed, you should see the new Resource Group with the Automation account

![alt text](images/knautorg.png "RG")

###You can now deploy the template   
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fasr-oms-monitoring%2F%2Fazuredeploy.json)

This will send you to the Azure Portal with some default values for the template parameters. 
Ensure that the parameters reflects your setup so that you are deploying this into the *existing* Resource Group containing the Automation account, and also change the parameters for 'omsautomationaccountname' and 'omsautomationregion' to point to the existing account. 

This template will create a new OMS Log Analytics Workspace in the specified region.

You should also change the *INGESTSCHEDULEGUID* value. You can generate your own using PowerShell with the following cmdlet:


![alt text](images/knguid.png "guid")

Once you have customized all the parameters, click *Create*

![alt text](images/knarmtemp.png "New workspace")

The ingestion will start 5-10 minutes post deployment.

Note: You will not see any data ingestion if you don't have any Recovery Vaults in your subscription

Once the solution has been enabled, OMS will perform an assessment and start to show data once ingested.
You should expect to see the following view for the next hour.

![alt text](images/overview.png "Assessment")

When the first data has been ingested, you can drill into the ASR Private Preview solution and explore the views

![alt text](images/asrpreview.png "ASR Private Preview")           