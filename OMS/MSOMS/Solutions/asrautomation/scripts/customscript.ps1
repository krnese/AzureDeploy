<# 
.SYNOPSIS 
    Runbook to add public IP addresses and custom script extension to all VMs within a Recovery Plan 
 
.DESCRIPTION 
    This runbook will add a public IP address to all the virtual machines in a Recovery Plan and execute a script using Custom Script Extension.
    For RPD access, you can connect to the VMs from the Azure Portal or using PowerShell to retrieve the RDP file.
    Whether you will be able to connect successfully to your workloads remotely will depend on the firewall settings within each guest, but you can
    use the custom script extension to add your own script to enable firewall settings and more.

.PLATFORM
    Windows Server      
      
.DEPENDENCIES 
    Azure VM Agent is required for the custom script extension to be installed in the guest(s). Ensure this is present prior to any test- or planned failover.
    
.ASSETS 
    This runbook requires the following modules present in the Azure Automation assets:
    - AzureRm.Profile
    - AzureRm.Compute
    - AzureRm.Network
    - AzureRm.Storage
    - Azure.Storage
 
.PARAMETER RecoveryPlanContext 
    RecoveryPlanContext is the only parameter you need to define. 
    This parameter gets the failover context from the recovery plan.  
 
.NOTES 
    Author: Kristian Nese - krnese@microsoft.com  
    Last Updated: 17/10/2016    
#> 

param ( 
        [Object]$RecoveryPlanContext 
      ) 

write-output $RecoveryPlanContext

if($RecoveryPlanContext.FailoverDirection -ne 'PrimaryToSecondary')
{
    Write-Output 'Script is ignored since Azure is not the target'
}
else
{

    $VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name

    Write-OutPut $VMInfo

    if ($VMInfo -is [system.array])
    {
        $VMinfo = $VMinfo[0]

        Write-Output "Found multiple VMs in the Recovery Plan"
    }
    else
    {
        Write-Output "Found only a single VM in the Recovery Plan"
    }

    $RGName = $RecoveryPlanContext.VmMap.$VMInfo.CloudServiceName

    Write-OutPut ("Name of resource group: " + $RGName)

    "Logging in to Azure..."
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
     Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    "Selecting Azure subscription..."
    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

    # Get automation variables for script execution

    $ScriptName = Get-AutomationVariable -Name ScriptName

    $StorageName = Get-AutomationVariable -Name StorageName

    $ContainerName = Get-AutomationVariable -Name ContainerName

    $StorageRGName = Get-AutomationVariable -Name StorageRGName

    # Get VMs within the Resource Group

    $VMs = Get-AzureRmVm -ResourceGroupName $RGName

    Write-Output ("Found the following VMs: `n " + $VMs.Name) 

    foreach ($VM in $VMs)
    {
        $VMNetworkInterfaceName = $VM.NetworkInterfaceIDs[0].Split('/')[-1]

        $VMNetworkInterfaceObject = Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $VMNetworkInterfaceName

        $PIP = New-AzureRmPublicIpAddress -Name $VM.Name -ResourceGroupName $RGName -Location $VM.Location -AllocationMethod Dynamic

        $VMNetworkInterfaceObject.IpConfigurations[0].PublicIpAddress = $PIP

        Set-AzureRmNetworkInterface -NetworkInterface $VMNetworkInterfaceObject
        
        Write-Output ("Added public IP address to the following VM: " + $VM.Name)
        
    # Add custom script to the VM

        If ($VM.StorageProfile.OsDisk.OsType -eq 'Windows')
        {
            Write-Output ("This is a Windows VM and we'll continue to install the script extension on  `n" + $VM.name) 

            $Key = (Get-AzureRmStorageAccountKey -Name $StorageName -resourcegroupname $StorageRGName).Value[0]

            $Context = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Key 

            Set-AzureRmVmCustomScriptExtension -ResourceGroupName $RGName -VMName $VM.Name -ContainerName $ContainerName -FileName $ScriptName -StorageAccountName $StorageName -StorageAccountKey $Key -Location $VM.Location -Name CustomASR
          
        }
        else
        {
            Write-Output ("VM is not running Windows platform and we will skip this step")
        }

    Write-Output ("Operation completed on the following VM(s): `n" + $VMs.Name)
    }
}
