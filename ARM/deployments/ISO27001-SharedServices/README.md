# ISO 27001 as ARM templates

ARM template samples to deploy and ISO 27007 compliant subscription in Azure.

This includes:

- 4 Resource Groups with distributed resources, such as:
    - HA AD Domain controllers
    - Key Vault
    - Log Analytics configured with Update mgmt, change tracking, Antimalware, Security, Agent health and more
    - Virtual Network
- Azure Security Center is enabled and set to Standard tier for the subscription
- Required Azure Policies, such as enforcing security and monitoring across resource types is created, connected to the Log Analytics workspace being created
- Custom RBAC for SecOps, NetOps, and SysOps

To deploy using Azure PowerShell:

````
New-AzureRmDeployment -Name <deploymentName> `
                      -Location <azureLocation> `
                      -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/deployments/ISO27001-SharedServices/azuredeploy.json" `
                      -workspaceName <wsName> `
                      -workspaceLocation <wsLocation> `
                      -automationAccountName <aaName> `
                      -automationLocation <aaLocation> `
                      -mgmtRgName <nameForMgmtRg> `
                      -vNetRgName <nameForVnetRg> `
                      -dcRgName <nameForDcRg> `
                      -keyVaultRgName <nameForKVRg> `
                      -keyVaultName <kvName> `
                      -adminUsername <username> `
                      -domainName <domainName> `
                      -dnsPrefix <dnsPrefix> `
                      -objectId <objectId for users needing access to KeyVault> `
                      -Verbose
````

                      