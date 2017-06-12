# Lab 1 - Getting started

>Last updated: 4/24/2017

>Author: krnese
>

## Azure Resource Manager Inside-Out

### Before you begin

The objective of this hackathon is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

### Lab 1 - Getting started 

During this excercise, you will become familiar with the Azure portal and explore its management capabilities, and customize the settings to fit your needs

#### Exploring Azure using the portal

1. From your computer, use your preferred browser and navigate to [Azure portal](https://azure.portal.com)
2. Sign in with your credentials that has acess to an Azure subscription (Admin access is required to complete the labs)
3. When logged in, explore the options you have available in the portal and familiarize yourself with the structure. Verify that by drilling further in for each object you selects, which should open new blades
![alt text](media/portal.png "Azure portal")

4. Close all the open blades and proceed to part 2.


#### Create Resource Group using Azure portal

1. In the portal, click on *New*,search for *Resource Group*, and click *Create*
2.  Assign a name for the resource group, the location that will store the metadata and click *Create*
![alt text](media/rg.png "New Resource Group")

3. Notice that you get a notification in the upper right once the deployment has completed. This is where you can track your deployments, so you can see if they are completed successfully, or are failing

![alt text](media/notification.png "Azure notifications")

#### Customizing the Azure portal

1. In the Azure portal on the main page, click on **+New dashboard**, assign a name and click **Done customizing**
![alt text](media/dashboard1.png "New dashboard")

2. Next, navigate to the resource group you created earlier by clicking on **More services**, **Resource groups**, and click on it. 
3. In the upper right of the resource group blade, you should see a pin which let you pin this particular resource to the dashboard you just created. Click on **Pin to dashboard** and go back to the main your dashboard

![alt text](media/dashboard2.png "Customized dashboard")

#### Exploring Azure using PowerShell

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


You have now completed the basics in **Lab 1**, by familiarizing yourself with the Azure portal and Azure PowerShell module, which will be essential as you proceed with the labs
