<#
.Synopsis
   Runbook for Azure Mgmt Analytics
.DESCRIPTION
   This Runbook does an assessment on your Azure subscription, and brings visibility into the resources and subscription from a mgmt. perspective
.AUTHOR
    Kristian Nese (Kristian.Nese@Microsoft.com) Azure CAT
#>

# Login to Azure using RunAs account in Azure Automation

"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

# Collecting Automation variables - created by the Azure Resource Manager Template

$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$AzureSubscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionId'
$AzureTenantId = Get-AutomationVariable -Name 'AzureTenantId'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
$OMSAutomationAccountName = Get-AutomationVariable -Name 'OMSAutomationAccountName'

# Fetching all unmanaged VMs

$VMs = Get-AzureRmVm 

foreach ($VM in $VMs)
{
       
        if ($vm.AvailabilitySetReference -ne $null)
        {
            $HA = 'Highly Available'
        }
        else
        {
            $HA = 'Not Highly Available'
        }

       $Extensions = Get-AzureRmVm -Name $vm.name -ResourceGroupName $VM.ResourceGroupName | select Extensions
 
       $MMA = 'Microsoft.EnterpriseCloud.Monitoring'
       $Extensions | ForEach-Object -Process {
           if ($Extensions.Extensions.Publisher -contains $MMA) 
           {
              $Status = "Managed"
              $Action = "This VM is managed by a Log Analytics Workspace"
           } 
           else 
           {
              $Status = "Unmanaged" 
              $Action = "This VM is not managed by a Log Analytics Workspace. You can add the extension to the VM from within the Log Analytics resource in Azure portal, or use tooling like PowerShell and ARM templates to deploy at scale."          
           }
                $ExtensionTable = @()
                $ExtensionData = New-Object psobject -Property @{
                   VMName = $VM.Name;
                   ResourceGroupName = $VM.ResourceGroupName;
                   Location = $VM.Location;
                 # Extension = $Extensions;
                   MgmtStatus = $Status;
                   SubscriptionId = $AzureSubscriptionId;
                   TenantId = $AzureTenantId;
                   Log = 'IaaS';
                   AvailabilityStatus = $HA;
                   ResourceId = $VM.Id;
                   RecommendedActions = $Action
                  }
        $ExtensionTable += $ExtensionData

        $ExtensionsTableJson = ConvertTo-Json -InputObject $ExtensionTable

        write-output $extensionstablejson 

        $LogType = 'AzureManagement'

        Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $ExtensionsTableJson -logType $LogType                  
        }
}

# Finding Automation Accounts

$AutomationAccounts = Find-AzureRmResource -ResourceType Microsoft.Automation/automationAccounts

foreach ($Automation in $AutomationAccounts)
{
   $Diagnostics = Get-AzureRmDiagnosticSetting -ResourceId $Automation.ResourceId
   if ($Diagnostics.WorkspaceId -eq $null)
   {

    $PaaSTable = @()
                $PaaSData = New-Object psobject -Property @{
                    ResourceName = $Automation.Name;
                    ResourceGroupName = $Automation.ResourceGroupName;
                    SubscriptionId = $AzureSubscriptionId;
                    TenantId = $AzureTenantId;
                    Location = $Automation.Location;
                    MgmtStatus = 'Unmanaged'
                    ResourceId = $Automation.ResourceId;
                    ResourceType = $Automation.ResourceType;
                    Log = 'PaaS';
                    RecommendedActions = "This resource is not managed by a Log Analytics Workspace. Use the Azure portal, PowerShell or ARM templates to enable metrics and diagnostics to Log Analytics so that you can perform forensics and management on your resource"
                   }
    $PaaSTable += $PaaSData
   
    $PaaSTableJson = ConvertTo-Json -InputObject $PaaSTable
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $PaaSTableJson -logType $LogType
    }
    else
    {
           $PaaSTable = @()
                $PaaSData = New-Object psobject -Property @{
                    ResourceName = $Automation.Name;
                    ResourceGroupName = $Automation.ResourceGroupName;
                    SubscriptionId = $AzureSubscriptionId;
                    TenantId = $AzureTenantId;
                    Location = $Automation.Location;
                    RecommendedActions = 'This resource is managed by a Log Analytics Workspace and you can explore, perform forensics and analytics on the data by using specific solutions or the search engine';
                    MgmtStatus = 'Managed'
                    ResourceId = $Automation.ResourceId;
                    ResourceType = $Automation.ResourceType;
                    WorkspaceId = $Diagnostics.WorkspaceId;
                    Log = 'PaaS'
                   }
    $PaaSTable += $PaaSData
   
    $PaaSTableJson = ConvertTo-Json -InputObject $PaaSTable
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $PaaSTableJson -logType $LogType 
    }
}

# Finding NSGs

$NSGs = Find-AzureRmResource -ResourceType Microsoft.Network/networkSecurityGroups

foreach ($NSG in $NSGS)
{
   $Diagnostics = Get-AzureRmDiagnosticSetting -ResourceId $nsg.ResourceId
   if ($Diagnostics.WorkspaceId -eq $null)
   {

    $PaaSTable = @()
                $PaaSData = New-Object psobject -Property @{
                    ResourceName = $NSG.Name;
                    ResourceGroupName = $NSG.ResourceGroupName;
                    SubscriptionId = $AzureSubscriptionId;
                    TenantId = $AzureTenantId;
                    Location = $NSG.Location;
                    RecommendedActions = 'This PaaS resource should be managed by Azure OMS services';
                    MgmtStatus = 'Unmanaged'
                    ResourceId = $NSG.ResourceId;
                    ResourceType = $NSG.ResourceType;
                    Log = 'PaaS'
                   }
    $PaaSTable += $PaaSData
   
    $PaaSTableJson = ConvertTo-Json -InputObject $PaaSTable
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $PaaSTableJson -logType $LogType
    }
    else
    {
           $PaaSTable = @()
                $PaaSData = New-Object psobject -Property @{
                    ResourceName = $NSG.Name;
                    ResourceGroupName = $NSG.ResourceGroupName;
                    SubscriptionId = $AzureSubscriptionId;
                    TenantId = $AzureTenantId;
                    Location = $VM.Location;
                    RecommendedActions = 'This PaaS resource is managed by OMS Services';
                    MgmtStatus = 'Managed'
                    ResourceId = $NSG.ResourceId;
                    ResourceType = $NSG.ResourceType;
                    WorkspaceId = $Diagnostics.WorkspaceId;
                    Log = 'PaaS'
                   }
    $PaaSTable += $PaaSData
   
    $PaaSTableJson = ConvertTo-Json -InputObject $PaaSTable
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $PaaSTableJson -logType $LogType 
    }
}

# Finding protected and unprotected VMs

$backupVaults = Find-AzureRmResource -ResourceType Microsoft.RecoveryServices/vaults

foreach ($backupvault in $backupVaults)
{

        $rsVault = Get-AzureRmRecoveryServicesVault -Name $backupVault.Name -ResourceGroupName $backupVault.ResourceGroupName
        Set-AzureRmRecoveryServicesVaultContext -Vault $rsVault
        $azureVMs = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM
        Get-AzureRmVM | where-object {$_.Location -eq $rsVault.Location} | ForEach-Object -Process {
            if ($azureVMs.FriendlyName -contains $_.Name) {
                $protected = "Protected"
            } else {
                $protected = "Unprotected"
            }
            $backupTable = @()
               $backupData = New-Object psobject -Property @{
                VMName = $_.Name;
                ProtectionStatus = $protected;
                SubscriptionId = $AzureSubscriptionId;
                TenantId = $AzureTenantId;
                Log = 'Backup';
                VaultName = $rsVault.Name;
                Location = $rsVault.Location
                ResourceGroupName = $_.ResourceGroupName;
                VMId = $_.Id
            }
            $backupTable += $backupData
   
            $backupTableJson = ConvertTo-Json -InputObject $backupData

            write-output $backuptablejson
            }
       

    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $backupTableJson -logType $LogType
    
}

# Find DSC nodes

$Auto = Find-AzureRmResource -resourceType Microsoft.Automation/automationAccounts

foreach ($Au in $Auto)
{

$DSCManaged = Get-AzureRmAutomationDscNode -AutomationAccountName $Au.Name -ResourceGroupName $Au.ResourceGroupName

    foreach ($DSC in $DSCManaged)
    {
            $DSCTable = @()
                    $DSCData = New-Object psobject -Property @{
                        VMName = $DSC.Name;
                        ResourceGroupName = $DSC.ResourceGroupName;
                        SubscriptionId = $AzureSubscriptionId;
                        TenantId = $AzureTenantId;
                        NodeConfigurationName = $DSC.NodeConfigurationName;
                        MgmtStatus = 'Managed'
                        AutomationAccountName = $DSC.AutomationAccountName;
                        Status = $DSC.Status;
                        Log = 'DSC'
                       }
        $DSCTable += $DSCData
   
        $DSCTableJson = ConvertTo-Json -InputObject $DSCTable
    
        $LogType = 'AzureManagement'

        Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $DSCTableJson -logType $LogType
    }
}
  
# Getting an overview of all existing Azure resources
    
$Resources = Get-AzureRmResource 

foreach ($resource in $resources)
{
       $ResourcesTable = @()
       $ResourcesData = new-object psobject -Property @{
           ResourceType = $Resource.ResourceType;
           ResourceGroupName = $Resource.ResourceGroupName;           
           Location = $Resource.Location;
           ResourceName = $Resource.Name;
           ResourceId = $Resource.ResourceId;
           SubscriptionId = $Resource.SubscriptionId;
           TenantId = $AzureTenantId;
           Log = 'Resources'
           }

       $ResourcesTable += $ResourcesData
    
       $ResourcesJson = ConvertTo-Json -InputObject $ResourcesTable

       Write-Output $ResourcesJson 

       $LogType = 'AzureManagement'

       Send-OMSAPIIngestionData -customerId $omsworkspaceid -sharedKey $omsworkspaceKey -body $ResourcesJson -logType $LogType
}
                      
# Getting an overview of all ARM Deployments

$ResourceGroups = Get-AzureRmResourceGroup

foreach ($resourcegroup in $ResourceGroups)
{
    $Deployments = Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourcegroup.ResourceGroupName

    foreach ($Deployment in $Deployments)
    {
        $DeploymentTable = @()
        $DeploymentData = new-object psobject -Property @{
            ResourceGroupName = $Deployment.ResourceGroupName;
            SubscriptionId = $AzureSubscriptionId;
            TenantId = $AzureTenantId;
            DeploymentName = $Deployment.DeploymentName;
            ProvisioningState = $Deployment.ProvisioningState;
            TimeStamp = $Deployment.TimeStamp.ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ss');
            Mode = $Deployment.Mode.ToString();
            Parameters = $deployment.Parameters.Keys + $deployment.Parameters.Values;
            Outputs = $Deployment.Outputs.Keys + $deployment.Outputs.Values;
            TemplateLink = $Deployment.TemplateLink;
            CorrelationId = $Deployment.CorrelationId.ToString()
            Log = 'Deployments'
            }

        $DeploymentTable += $DeploymentData

        $DeploymentsJson = ConvertTo-Json -inputobject $deploymenttable

        #write-output $DeploymentsJson

        $LogType = 'AzureManagement'

        Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $DeploymentsJson -logType $LogType
    }
}

# Getting all storage accounts to see storageType

$StorageAccounts = Get-AzureRmStorageAccount

foreach ($StorageAccount in $StorageAccounts)
{
   if ($StorageAccount.sku.name -eq 'StandardLRS')
   {
    $HA = "Not Highly Available"
   }
   else
   {
    $HA = "Highly Available"
   }

    $StorageTable = @()
    $StorageData = new-object psobject -Property @{
        ResourceGroupName = $StorageAccount.ResourceGroupName;
        Location = $StorageAccount.Location;
        AvailabilityStatus = $HA;
        Sku = $StorageAccount.Sku.Name.ToString();
        PrimaryLocation = $StorageAccount.PrimaryLocation;
        #SecondaryLocation = $StorageAccount.SecondaryLocation;
        StatusOfPrimary = $StorageAccount.StatusOfPrimary;
        CreationTime = $StorageAccount.CreationTime.ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ss');
        #LastGeoFailoverTime = $StorageAccount.LastGeoFailoverTime.ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ss');
        ResourceId = $StorageAccount.Id;
        StorageAccountName = $StorageAccount.StorageAccountName;
        Log = "Storage";
        SubscriptionId = $AzureSubscriptionId;
        TenantId = $AzureTenantId;
        Tags = $StorageAccount.Tags
        }
    $StorageTable += $StorageData

    $StorageJson = ConvertTo-Json -inputobject $StorageTable

    Write-Output $StorageJson

    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $StorageJson -logType $LogType
}          

# Getting usage across regions

$regions = Get-AzureRmLocation
foreach ($region in $regions)
{
    $VMUsageTotal = Get-AzureRmVMUsage -Location $region.Location
    
    foreach ($VMUsage in $VMUsageTotal)
    {
        $VMUsageTable = @()
        $VMUsageData = new-object psobject -property @{
            Region = $Region.Location;
            Name = $VMUsage.Name.Value;
            CurrentValue = $VMUsage.CurrentValue;
            Limit = $VMUsage.Limit;
            SubscriptionId = $AzureSubscriptionId;
            TenantId = $AzureTenantId;
            Log = 'VMUsage'
            }
        $VMUsageTable += $VMUsageData

        $VMUsageJSON = ConvertTo-Json -inputobject $VMUsageTable

        write-output $VMUsageJson

    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $VMUsageJSON -logType $LogType
    }
}  

# Checking for Policy Assignments

$Policies = Get-AzureRmPolicyAssignment

foreach ($Pol in $Policies)
{
    $PolicyTable = @()
    $PolicyData = new-object psobject -property @{
        Name = $Pol.Name;
        ResourceId = $pol.ResourceId;
        ResourceType = $pol.ResourceType;
        SubscriptionId = $AzureSubscriptionId;
        TenantId = $AzureTenantId;
        Properties = $pol.properties;
        PolicyAssignmentId = $pol.PolicyAssignmentId;
        ResourceGroupName = $pol.ResourceGroupName;
        Log = 'Policy'
        }
    
    $PolicyTable += $PolicyData

    $PolicyJson = ConvertTo-Json -inputobject $PolicyTable

    $LogType = 'AzureManagement'

    Write-Output $policyjson
    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $PolicyJson -logType $LogType
}

# Getting overview over Tags

$Tags = Get-AzureRmTag

foreach ($Tag in $Tags)
{
    $Value = Get-AzureRmTag -Name $Tag.Name | select -ExpandProperty Values

    $TagTable = @()
    $TagData = New-Object psobject -property @{
        TagName = $Tag.Name;
        Value = $Value.Name;
        Log = 'Tag'
        }
    $TagTable += $TagData

    $TagJson = ConvertTo-Json -inputobject $TagTable

    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $TagJson -logType $LogType
    }

# Getting overview over RBAC

$RoleAssignments = Get-AzureRmRoleAssignment

foreach ($role in $RoleAssignments)
{
    $RoleTable = @()
    $RoleData = new-object psobject -property @{
        RoleAssignmentId = $Role.RoleAssignmentId;
        Scope = $Role.Scope;
        DisplayName = $Role.DisplayName;
        SignInName = $Role.SignInName;
        RoleDefinitionName = $Role.RoleDefinitionName;
        RoleDefinitionId = $Role.RoleDefinitionId;
        ObjectId = $Role.ObjectId;
        ObjectType = $Role.ObjectId;
        Log = 'RBAC';
        SubscriptionId = $AzureSubscriptionId;
        TenantId = $AzureTenantId
        }
    $RoleTable += $RoleData
    
    $RoleJson = ConvertTo-Json -inputobject $RoleTable

    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $RoleJson -logType $LogType
    }

# Getting overview over resource lock usage

$locks = Get-AzureRmResourceLock

foreach ($lock in $locks)
{
    $LockTable = @()
    $LockData = new-object psobject -property @{
        Name = $lock.Name;
        Log = 'Lock';
        ResourceName = $lock.ResourceName;
        ResourceType = $lock.ResourceType;
        SubscriptionId = $AzureSubscriptionId;
        TenantId = $AzureTenantId;
        LockId = $lock.LockId;
        ResourceId = $lock.ResourceId;
        ExtensionResourceType = $lock.ExtensionResourceType;
        Properties = $lock.properties
        }
       $LockTable += $LockData
       $LockJson = ConvertTo-Json -inputobject $locktable
       
       $LogType = 'AzureManagement'
       
       Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $OMSWorkspaceKey -body $LockJson -logType $LogType    
}