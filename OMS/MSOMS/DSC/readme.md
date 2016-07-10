# Deploy OMS Automation DSC Configuration in Azure with Azure Resource Manager
This template will deploy all the assets (variables and modules) and the DSC Configuration to your OMS Automation Account, for onboarding machines to ASR protection using the Mobility Service

# Deploy using PowerShell:
````powershell
$OMSAutomationRGname = 'KNOMS'

$DSCJobGuid = (New-Guid).Guid

New-AzureRmResourceGroupDeployment `
                                  -Name "DSC3" `
                                  -ResourceGroupName $OMSAutomationRGname `
                                  -TemplateFile https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/DSC/azuredeploy.json `
                                  -OMSAutomationAccountName KNOMSAA `
                                  -ASRRemoteFile "https://knrecstor01.blob.core.windows.net/asr/ASR.zip" `
                                  -ASRRemotePassphrase "https://knrecstor01.blob.core.windows.net/asr/passphrase.txt" `
                                  -ASRCSEndpoint '10.0.0.115' `
                                  -DSCJobGuid $DSCJobGuid `
                                  -Verbose
````                                   
