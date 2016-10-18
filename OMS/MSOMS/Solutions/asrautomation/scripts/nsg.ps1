<# 
.SYNOPSIS 
    Runbook that creates a NSG, add public IP addresses to all VMs within a Recovery Plan 
 
.DESCRIPTION 
    This runbook will add a public IP address to all the virtual machines in a Recovery Plan.
    For RPD access, you can connect to the VMs from the Azure Portal or using PowerShell to retrieve the RDP file.
    A NSG will be created with default ports enabled (RDP, HTTP and HTTPS) and linked to each virtual network adapter

.PLATFORM
    Windows Server      
      
.DEPENDENCIES 
    Azure VM Agent is required for the custom script extension to be installed in the guest(s). Ensure this is present prior to any test- or planned failover.
    
.ASSETS 
    This runbook requires the following modules present in the Azure Automation assets:
    - AzureRm.Profile
    - AzureRm.Compute
    - AzureRm.Network
    - AzureRm.Resources
 
.PARAMETER RecoveryPlanContext 
    RecoveryPlanContext is the only parameter you need to define. 
    This parameter gets the failover context from the recovery plan.  
 
.NOTES 
    Author: Kristian Nese - krnese@microsoft.com  
    Last Updated: 18/10/2016    
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

    # Creating a NSG with default ports allowed that will be assigned to the network interfaces
    
    $NSGname = $RGName + 'NSG'

    $NSG = New-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $RGName -Location (Get-AzureRmResourceGroup -Name $RGName).Location

    $NSG | Add-AzureRmNetworkSecurityRuleConfig -Name "EnableRDP" -Direction Inbound -Protocol Tcp -Priority 1000 -Access Allow -SourcePortRange '*' -SourceAddressPrefix '*' -DestinationAddressPrefix '*' -DestinationPortRange '3389' | Set-AzureRmNetworkSecurityGroup

    $NSG | Add-AzureRmNetworkSecurityRuleConfig -Name "HTTP" -Direction Inbound -Protocol Tcp -Priority 1500 -Access Allow -SourcePortRange '*' -SourceAddressPrefix '*' -DestinationAddressPrefix '*' -DestinationPortRange '80' | Set-AzureRmNetworkSecurityGroup

    $NSG | Add-AzureRmNetworkSecurityRuleConfig -Name "HTTPS" -Direction Inbound -Protocol Tcp -Priority 2000 -Access Allow -SourcePortRange '*' -SourceAddressPrefix '*' -DestinationAddressPrefix '*' -DestinationPortRange '443' | Set-AzureRmNetworkSecurityGroup

    foreach ($VM in $VMs)
    {
        $VMNetworkInterfaceName = $VM.NetworkInterfaceIDs[0].Split('/')[-1]

        $VMNetworkInterfaceObject = Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $VMNetworkInterfaceName

        $PIP = New-AzureRmPublicIpAddress -Name $VM.Name -ResourceGroupName $RGName -Location $VM.Location -AllocationMethod Dynamic

        $VMNetworkInterfaceObject.IpConfigurations[0].PublicIpAddress = $PIP

        $VMNetworkInterfaceObject.NetworkSecurityGroup = $NSG

        Set-AzureRmNetworkInterface -NetworkInterface $VMNetworkInterfaceObject
        
        Write-Output ("Added public IP address to the following VM: " + $VM.Name)      

    Write-Output ("Operation completed on the following VM(s): `n" + $VMs.Name)
    }
}
