# Deny Hybrid Use Benefit

This policy will deny Hybrid Use Benefit usage

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name denyHybridUseBenefit `
                                          -DisplayName "Deny hybrid use benefit" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Compute/deny-hybrid-use-benefit/azurepolicy.rules.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditVmExtension –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
