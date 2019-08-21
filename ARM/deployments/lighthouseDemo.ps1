# Query all tenants

$currentContext = Get-AzContext
$token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id}

# ARM Request
    $ARMRequest = @{
        Uri = "https://management.azure.com/tenants?api-version=2019-03-01&includeAllTenantCategories=true"
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Get'
    }
    $Query = Invoke-WebRequest @ARMRequest
    #prettify
    [Newtonsoft.Json.Linq.JObject]::Parse($Query.Content).ToString()

    $ARMRequest2 = @{
        Uri = "https://management.azure.com/subscriptions/74903176-3e4e-492d-9d18-9afab69a0cf8/providers/Microsoft.ManagedServices/registrationDefinitions?api-version=2019-06-01"
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Get'
    }
    $Query2 = Invoke-WebRequest @ARMRequest2
    #prettify
    [Newtonsoft.Json.Linq.JObject]::Parse($Query2.Content).ToString()

# Using Resource Graph to detect storage accounts not being secured by https

Search-AzGraph -Query "summarize count() by tenantId" | ConvertTo-Json

Search-AzGraph -Query "where type =~ 'Microsoft.Storage/storageAccounts' | project name, location, subscriptionId, tenantId, properties.supportsHttpsTrafficOnly" | convertto-json

# Deploying Azure Policy using ARM templates at scale across multiple customer scopes, to deny creation of storage accounts not using https

$subs = Get-AzSubscription

Write-Output "In total, there's $($subs.Count) projected customer subscriptions to be managed"

foreach ($sub in $subs)
{
    Select-AzSubscription -SubscriptionId $sub.id

    New-AzDeployment -Name mgmt `
                     -Location eastus `
                     -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/ARM/deployments/PCI/Enforce-HTTPS-Storage-DENY.json" `
                     -AsJob
}

# Validating the policy - deny creation of storage accounts that are NOT using https only

New-AzStorageAccount -ResourceGroupName (New-AzResourceGroup -name kntest -Location eastus -Force).ResourceGroupName `
                     -Name (get-random) `
                     -Location eastus `
                     -EnableHttpsTrafficOnly $false `
                     -SkuName Standard_LRS `
                     -Verbose
                     
# clean-up

foreach ($sub in $subs)
{
    select-azsubscription -subscriptionId $sub.id

    Remove-AzDeployment -Name mgmt -AsJob

    $Assignment = Get-AzPolicyAssignment | where-object {$_.Name -like "enforce-https-storage-assignment"}

    if ([string]::IsNullOrEmpty($Assignment))
    {
        Write-Output "Nothing to clean up - we're done"
    }
    else
    {
    Remove-AzPolicyAssignment -Name 'enforce-https-storage-assignment' -Scope "/subscriptions/$($sub.id)" -Verbose

    Write-Output "ARM deployment has been deleted - we're done"
    }
}