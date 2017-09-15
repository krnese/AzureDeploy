# Audit for Network Watcher existence

This policy will audit Network Watchers existence in a selected location where virtual networks are present.

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name auditNetworkWatcher `
                                          -DisplayName "Audit for Network watcher absence" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Network/audit-network-watcher-existence/azurepolicy.rules.json' `
                                          -Parameter 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Network/audit-network-watcher-existence/azurepolicy.parameters.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditNworkWatcher –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
