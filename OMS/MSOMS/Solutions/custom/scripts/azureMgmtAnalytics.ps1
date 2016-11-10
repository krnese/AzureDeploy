<#
.Synopsis
   Runbook for OMS VM Management Log Ingestion
.DESCRIPTION
   This Runbook finds all VMs without management extensions. 
.AUTHOR
    Kristian Nese (Kristian.Nese@Microsoft.com) ECG OMS CAT
#>

"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$AzureSubscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionId'
$OMSRecoveryVault = Get-AutomationVariable -Name 'OMSRecoveryVault'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
$OMSAutomationAccountName = Get-AutomationVariable -Name 'OMSAutomationAccountName'

# Fetching all unmanaged VMs

$VMs = Get-AzureRmVm | where-object {$_.Extensions[0] -eq $null}

foreach ($VM in $VMs)
{

    $VMTable = @()
                $VMData = New-Object psobject -Property @{
                    VMName = $VM.Name;
                    ResourceGroupName = $VM.ResourceGroupName;
                    Location = $VM.Location;
                    RecommendedActions = 'This VM should be managed by Azure OMS services';
                    ManagedStatus = 'Unmanaged';
                    SubscriptionId = $AzureSubscriptionId;
                    Log = 'IaaS'
                   }
    $VMTable += $VMData
   
    $VMTableJson = ConvertTo-Json -InputObject $VMData
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $VMTableJson -logType $LogType

    }

$VMs = Get-AzureRmVm | where-object {$_.Extensions[0] -ne $null}

foreach ($VM in $VMs)
{
        $Extensions = (Get-AzureRmVm -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name).Extensions.id

        $ExtensionTable = @()
                           $ExtensionData = New-Object psobject -Property @{
                               VMName = $vm.Name;
                               ResourceGroupName = $vm.ResourceGroupName;
                               Location = $vm.Location;
                               Extension = $Extensions;
                               ManagedStatus = 'Managed';
                               SubscriptionId = $AzureSubscriptionId;
                               Log = 'IaaS'
                               }
        $ExtensionTable += $ExtensionData

        $ExtensionsTableJson = ConvertTo-Json -InputObject $ExtensionTable

        $LogType = 'AzureManagement'

        Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $ExtensionsTableJson -logType $LogType

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
                    Location = $Automation.Location;
                    RecommendedActions = 'This PaaS resource should be managed by Azure OMS services';
                    ManagedStatus = 'Unmanaged'
                    ResourceId = $Automation.ResourceId;
                    ResourceType = $Automation.ResourceType;
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
                    ResourceName = $Automation.Name;
                    ResourceGroupName = $Automation.ResourceGroupName;
                    Location = $Automation.Location;
                    RecommendedActions = 'This PaaS resource is managed by OMS Services';
                    ManagedStatus = 'Managed'
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
                    Location = $NSG.Location;
                    RecommendedActions = 'This PaaS resource should be managed by Azure OMS services';
                    ManagedStatus = 'Unmanaged'
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
                    Location = $VM.Location;
                    RecommendedActions = 'This PaaS resource is managed by OMS Services';
                    ManagedStatus = 'Managed'
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

$RsVault = Get-AzureRmRecoveryServicesVault -Name $OMSRecoveryVault -ResourceGroupName $OMSResourceGroupName
Set-AzureRmRecoveryServicesVaultContext -Vault $RsVault
$AzureVMs = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM
Get-AzureRmVM | ForEach-Object -Process {
    if ($AzureVMs.FriendlyName -contains $_.Name) {
        $Protected = "Protected"
    } else {
        $Protected = "Unprotected"
    }
    $VMTable = @()
       $VMData = New-Object psobject -Property @{
        VMName = $_.Name;
        ProtectionStatus = $Protected;
        Log = 'Backup'

    }
    $VMTable += $VMData
   
    $VMTableJson = ConvertTo-Json -InputObject $VMData
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $VMTableJson -logType $LogType
    
}

# Find DSC nodes

$DSCManaged = Get-AzureRmAutomationDscNode -AutomationAccountName $OMSAutomationAccountName -ResourceGroupName $OMSResourceGroupName

foreach ($DSC in $DSCManaged)
{
        $DSCTable = @()
                $DSCData = New-Object psobject -Property @{
                    VMName = $DSC.Name;
                    ResourceGroupName = $DSC.ResourceGroupName;
                    NodeConfigurationName = $DSC.NodeConfigurationName;
                    ManagedStatus = 'Managed'
                    AutomationAccountName = $DSC.AutomationAccountName;
                    Status = $DSC.Status;
                    Log = 'DSC'
                   }
    $DSCTable += $DSCData
   
    $DSCTableJson = ConvertTo-Json -InputObject $DSCTable
    
    $LogType = 'AzureManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $DSCTableJson -logType $LogType
}


    
                      