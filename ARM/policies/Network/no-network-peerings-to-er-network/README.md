# Deny network peering in ER networks

This policy ensure that no network peering can be associated to networks in network in a resource group containing central managed network infrastructure.

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name denyERPeering `
                                          -DisplayName "Deny peering to ER network" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Network/no-network-peerings-to-er-network/azurepolicy.rules.json' `
                                          -Parameter 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Network/no-network-peerings-to-er-network/azurepolicy.parameters.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditNworkWatcher –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
