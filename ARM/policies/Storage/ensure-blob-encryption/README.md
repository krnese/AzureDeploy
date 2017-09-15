# Ensure storage blog encryption

This policy ensures there's no blob storage being created, without encryption enabled.

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name ensureBlobEncryption `
                                          -DisplayName "Ensure Storage blob encryption is enabled" `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Storage/ensure-blob-encryption/azurepolicy.rules.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditNworkWatcher –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
