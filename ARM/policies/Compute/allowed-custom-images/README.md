# Govern approved VM Images

This policy let you control the approved VM images.

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name approvedVMImages `
                                          -DisplayName "Approved VM images" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Compute/allowed-custom-images/azurepolicy.rules.json' `
                                          -Parameter 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Compute/allowed-custom-images/azurepolicy.parameters.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name approvedVMImages –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
