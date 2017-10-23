# Deny storage accounts without file encryption

This policy will deny creation of storage accounts, if file encryption is not enabled

## How to create Policy Definition using PowerShell

````powershell
$definition = New-AzureRmPolicyDefinition -Name denyStorageWithoutFileEncryption `
                                          -DisplayName "Deny storage creation without file encryption enabled." `
                                          -Policy 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/policies/Storage/storage-account-file-encryption/azurepolicy.rules.json'
````

## How to create Policy Definitions using AzureCLI

````cli

Az policy definition create –name auditNworkWatcher –policyUri 'github.com/raw/foo/azurepolicy.rules.json' – parametersUri 'github.com/raw/bar/azurepolicy.parameters.json'

````
