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


#### Creating a resource manager template for Azure Log Analytisc
