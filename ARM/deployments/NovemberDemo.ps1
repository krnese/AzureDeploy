# MSP Expert demo

# Querying managed subscriptions using Azure Resource Graph

$MspTenant = "d6ad82f3-42af-4a15-ac1e-49e6c08f624e"

$subs = Get-AzSubscription

Search-AzGraph -Query "ResourceContainers | where type == 'microsoft.resources/subscriptions' | where tenantId != '$($mspTenant)' | project name, subscriptionId, tenantId" -subscription $subs.subscriptionId

# Deploy conditional resources using subscriptions().managedByTenant property

New-AzDeployment -Name "experts" `
                 -Location ukwest `
                 -TemplateFile ./sub01.json `
                 -Verbose

New-AzDeployment -Name policy `
                 -Location ukwest `
                 -TemplateUri "https://raw.githubusercontent.com/Azure/Azure-Lighthouse-samples/master/Azure-Delegated-Resource-Management/templates/policy-add-or-replace-tag/addOrReplaceTag.json" `
                 -Verbose
                 
# MSP Opt-out from a delegated subscriptin

Get-AzRoleDefinition -Name "Managed Services Registration assignment Delete Role"

# Verify you are on a delegated subscription (InspireProd expected)
$subName = (Get-AzContext).Subscription.Name
$subName

Get-AzManagedServicesAssignment

# Remove MSP access to the delegated subscription
Get-AzManagedServicesAssignment | Remove-AzManagedServicesAssignment

# Verify the sub is no longer visible from the MSP tenant

Get-AzSubscription -SubscriptionName $subName

