# Lab 5 - Troubleshooting

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

### Lab 5 - Troubleshooting

### Objectives

In this lab, you will work on nested templates and deployments, to implement best practices and instantiate more complex solutions in Azure. You'll work through different tasks, which will introduce you to new functions and techniques.

**Scenario**

Your CIO validated the work you recently did. Although he is happy about meeting his requirements, he has decided to expand the scope a bit.
Moving forward, he wants you to create a baseline for a new Azure environment, where the VM workload is entirely managed by Azure management services, but separated into its own Resource Group. Post deployment, the operations team should have access to a customized dashboard for easy access, and the environment should be highly automated with several Automation runbooks.
