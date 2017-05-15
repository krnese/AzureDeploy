# Azure Resource Manager - Inside-Out
>Last updated: 4/25/2017
>
>Author: krnese
>
>This material for **"Azure Resource Manager - Inside-Out"** is developed by Azure CAT.
>
>![alt text](media/azurecat.png "Azure CAT")

>For questions or feedback, contact **krnese@microsoft.com**


### Overview

Throughout this hackathon, you will work through several scenarios and examples, to get a good understanding of how you can configure, deploy and manage your Azure resources at scale, with Azure Resource Manager.

We will start to cover the basics - just to get you started and level set on what we will accomplish. As you proceed through the different labs, things will indeed get a bit more complicated and hectic, but be assured that you will learn a lot and have fun!

We believe that by having an approach where we go through known, common scenarios to get the right context, it will simplify the learning, and make it more interesting. Therefor you will be presented with a high-level scenario in every lab, to better understand the "what" and "why", and we will guide you through the "how".

The instructor should also be capable of answering **any** question you might have **:-)**

### Agenda

This is an instructor led hackathon, where the trainer will present and demo on Azure Resource Manager.

* To access the **presentation** used for this hackathon, click [here](./ppt/armTraining.pptx)

·  **Authoring**

Learn how to author your Azure Resource Manager templates to be capable of creating, deploying and managing any of your cloud resources, following best-practices

·  **Deployment**

Learn how to do deployments to Azure using different tools, techniques and possible integrations

·  **Management**

Management of cloud resources is key, and can be handled through Azure Resource Manager as well. Learn best practices for the different cloud resources, using ARM with Role-based access control, tags, resource locks and policy. We will also cover how to easily scale and plug into Azure management services, such as Log Analytics, Automation, Backup & Site Recovery

·  **Troubleshooting**

Sometimes you need to dive deeper into the operations to troubleshoot what’s going on. Learn about the techniques, where to find what, how to use the information and resolve the issues

·  **IaaS+**

Moving away from the ‘traditional way’ of doing Infrastructure, we are now using Azure Resource Manager to extend the capabilities, giving us the ideal platform for performing this end-to-end, all from the deployment to post-deployment tasks.

This section will also focus on the key resource providers in Azure, such as Compute, Storage and Networking

We can promise you the following:

·  Best practices advice's around the covered topics

·  Inspiration

·  Enthusiasm

·  Key learning, using real-world scenarios from the field

#### Prerequisites

We have some recommended reading we suggest you familiarize yourself with, prior to attending this hackathon.

[Azure Resource Manager overview](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)

[Azure Resource Manager templates - structure and syntax](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)

[Azure Resource Manager templates - best practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-template-best-practices)

[Design patterns for Azure Resource Manager templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/best-practices-resource-manager-design-templates)

[Deploy templates using PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy)

[Azure Resource Policies - overview](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-policy)

[Azure Resource Manager - troubleshooting](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-common-deployment-errors)

[Continuous integration in VSO using Azure Resource Manager](https://docs.microsoft.com/en-us/azure/vs-azure-tools-resource-groups-ci-in-vsts)

### Content & Labs

Use the following labs to advance your ARM skills throughout this hackathon

* [**LAB 1 - Getting Started**](./lab-1.md)

Throughout this lab, you will familiarize yourself with the Azure portal and PowerShell, to work with Resource Groups

* [**LAB 2 - Exploring Resource Manager Templates**](./lab-2.md)

In this lab, you will learn the basics of an ARM template, and work with some of the most frequently used functions

* [**LAB 3 - Advanced Resource Manager Templates**](./lab-3.md)

In this lab, you will work on some sample templates that deploys various workloads, spanning multiple services across different regions, while exploring many more functions

* [**LAB 4 - Nested Resource Manager Templates**](./lab-4.md)

In this lab, you will explore nested templates, and how they are used in real-world scenarios to handle conditions and to build out an entire infrastructure together with your apps, all based on ARM templates

* [**LAB 5 - Troubleshooting**](./lab-5.md)

In this lab, you will learn how to troubleshoot templates and deployments, how to improve your templates, and understand how to leverage the **outputs** section

* [**LAB 6 - Resource Policies**](./lab-6.md)

In this lab, you will explore how to govern your subscriptions, resource groups and resources with Resource Policies

* [**LAB 7 - Resource Locks**](./lab-7.md)

Learn how to use and implement Resource Locks for your production workload

* [**LAB 8 - Azure Managed Appliactions**](./lab-8.md)

Learn how to build and publish an Azure Managed Applications to the Service Catalog, and manage the life-cycle using Resource Manager templates.

* [**LAB 8 - CI/CD with Resource Manager**](./lab-8.md) (Coming soon)

Code, test, build & release. You will learn how to configure Git and VSO to set up continuous integration/continuous deployment for your apps, using ARM templates

* [**LAB 9 - Role-Based Access Control**](./lab-8.md) (Coming soon)

Learn about the built-in RBAC roles, and how to create and use customized RBAC roles on your own