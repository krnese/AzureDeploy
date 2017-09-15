# Allow only a custom VM image

This policy will ensure that only a custom image from a Resource Group is allowed.

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name allowCustomImage `
                                          -DisplayName "Allows only a custom VM Image" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Compute/custom-image-from-rg/azurepolicy.rules.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditVmExtension –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
