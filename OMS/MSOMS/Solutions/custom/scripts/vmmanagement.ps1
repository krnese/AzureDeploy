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

# Fetching all unmanaged VMs

$VMs = Get-AzureRmVm | where-object {$_.Extensions[0] -eq $null}

foreach ($VM in $VMs)
{

    $VMTable = @()
                $VMData = New-Object psobject -Property @{
                    VMName = $VM.Name;
                    ResourceGroupName = $VM.ResourceGroupName;
                    Location = $VM.Location;
                    RecommendedActions = 'This VM should be managed by Azure OMS services'
                    #SubscriptionId = $SubscriptionID;
                   }
    $VMTable += $VMData
   
    $VMTableJson = ConvertTo-Json -InputObject $VMData
    
    $LogType = 'VMManagement'

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $VMTableJson -logType $LogType

    }