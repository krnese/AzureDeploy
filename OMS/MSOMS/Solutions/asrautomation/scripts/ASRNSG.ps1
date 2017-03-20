<# 
    .DESCRIPTION 
        This will create a Public IP address for the failed over VM(s), create a NSG that allows common inbound traffic and associates every vNic. 
         
        Pre-requisites 
        All resources involved are based on Azure Resource Manager (NOT Azure Classic)

        The following AzureRm Modules are required
        - AzureRm.Profile
        - AzureRm.Resources
        - AzureRm.Compute
        - AzureRm.Network

        How to add the script? 
        Add this script as a post action in boot up group for which you need a public IP and NSG. All the VMs in the group will get a public IP assigned. 
         
        Clean up test failover behavior 
        You must manually remove the NSG and Public IP interfaces
 
    .NOTES 
        AUTHOR: krnese@microsoft.com 
        LASTEDIT: 20 March, 2017 
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

    $RGName = $RecoveryPlanContext.VmMap.$VMInfo.ResourceGroupName

    Write-OutPut ("Name of resource group: " + $RGName)
Try
 {
    "Logging in to Azure..."
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
     Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    "Selecting Azure subscription..."
    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
 }
Catch
 {
      $ErrorMessage = 'Login to Azure subscription failed.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
 }
Try
 {
    $VMs = Get-AzureRmVm -ResourceGroupName $RGName
    Write-Output ("Found the following VMs: `n " + $VMs.Name) 
 }
Catch
 {
      $ErrorMessage = 'Failed to find any VMs in the Resource Group.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
 }
Try
 {
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
Catch
 {
      $ErrorMessage = 'Failed to complete the NSG configuration.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
 }
}
