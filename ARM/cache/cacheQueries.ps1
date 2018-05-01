# queries

Explore-AzureRmCache -Query "where type == 'Microsoft.Compute/virtualMachines' | extend OS = properties.storageProfile.imageReference.publisher | project tostring(OS), resourceGroup, name, location" -Subscription 09e8ed26-7d8b-4678-a179-cfca8a0cef5c

Explore-AzureRmCache -Query "where type == 'Microsoft.Compute/virtualMachines' | extend OS = properties.storageProfile.imageReference.publisher | project tostring(OS), resourceGroup, name, location"

Explore-AzureRmCache -Query "where location == 'westeurope' | project name, resourceGroup"

Explore-AzureRmCache -Query "where location == 'westeurope' | where type == 'Microsoft.Storage/storageAccounts' | project name, resourceGroup, properties"

Explore-AzureRmCache -Query "where type == 'Microsoft.Compute/virtualMachines/extensions' | where name contains 'Monitoring' | extend settings = properties.settings.workspaceId | project tostring(settings), name, resourceGroup"

Explore-AzureRmCache -Query "where type == 'Microsoft.ServiceFabric/clusters' | project properties" -MaxRows 1

Explore-AzureRmCache -Query "where type == 'Microsoft.ServiceFabric/clusters' | extend cluster = properties.clusterCodeVersion | project tostring(cluster), resourceGroup, name, location, subscriptionId"

Explore-AzureRmCache -Query "where type == 'Microsoft.Network/virtualNetworks' | extend subnet = properties.subnets | project tostring(subnet)"