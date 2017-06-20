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

Your company recently had an incident, when someone accidentally changed the configuration of a storage account in Azure, being used by a LOB application. Your CIO was quite upset, realizing the app went south - stating that "my devs know all about code, but nothing about the operational aspect of the environment it executes in". For your company to be even more successful with Azure, he wants you to start building templates for all the approved Azure services you are using. Further, he wants you to initialize a Service Catalog with Managed Applications for these offerings, and make them available to the developers.

He list the following requirements:

* Approved Azure services for production should be templatized, centralized and managed by the SMEs
* The business units and devs should only be able to *consume* the service - and have *read only* access to the underlying Azure resources, to avoid that anything can be deleted or changed by accident (again)
* It's important that the devs can deploy what they need, through self-service, without adding any enterprise IT tax on top
* The top priority right now, is to start with a storage account, to replace the storage that caused the application to fail
* He wants you to prepare for a design that is scalable, and can be reused for other Managed Applications using nested templates
* The UI in the Azure portal for deploying, must be easy to understand and eliminate any possible human error

#### Building the managed storage account template