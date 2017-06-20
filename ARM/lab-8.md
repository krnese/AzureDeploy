# Lab 8 - Azure Managed Application

>Last updated: 6/20/2017

>Author: krnese

### Azure Resource Manager - Demystified

>For questions or feedback, contact **krnese@microsoft.com**

### Before you begin

The objective of this training is to learn how to author templates, interact with Azure Resource Manager through its API, Visual Studio (Visual Studio Code), Azure portal, source code systems (GitHub, TFS), and PowerShell. 

To complete these labs, you need to ensure you have access to the following tools:

* Admin access to an Azure subscription (minumum trial subscription)
* Visual Studio or Visual Studio Code with the Azure SDK/ARM extension installed
* Azure PowerShell module

### Lab 8 - Azure Managed Application

### Objectives

Learn how to build and publish an Azure Managed Applications to your company's internal Service Catalog, to enable self-service of approved applications, while separating the consumer and management aspect. 

**Scenario**

Your company had recently an incident, when someone accidentally deleted a storage account in Azure, being used by a LOB application. Your CIO states that "my devs know all about code, but nothing about the operational aspect of the environment it executes in". You suggest that any approved service being used in Azure, should ideally be *managed* and *operated* by central IT. As you realize this is your opportunity to make a proposal on the approach, you sit down with the CIO to define the requirements:

* Approved Azure services for production should be templatized, centralized and managed by the SMEs
* The business units and devs should not have *write* access to the underlying Azure resources, to avoid that anything can be deleted by accident (again)
* It's important that the devs can deploy what they need, through self-service, without any enterprise IT tax on top