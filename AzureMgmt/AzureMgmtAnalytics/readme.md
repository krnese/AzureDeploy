# Azure Management Analytics

>Note: This is an open source solution, to demonstrate how MSPs can use Azure Management services and tools to build a multi-tenant view witihn Log Analytics.

## Deploy the solution

The template will deploy an Azure Management solution to a new or existing Log Analytics workspace, and use an Azure Automation runbook to collect the data from ARM APIs.

### Instructions

1. Deploy an Azure Automation account via the Azure **portal** - and remember to create a SPN RunAs Account during the process. The automation runbook will use the SPN to authenticate with ARM and collect the data.
2. Deploy the Azure Resource Manager template by clicking on the link below

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkrnese%2Fazuredeploy%2Fmaster%2FAzureMgmt%2FAzureMgmtAnalytics%2FazureMgmtatScale.json)