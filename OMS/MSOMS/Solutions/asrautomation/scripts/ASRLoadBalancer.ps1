<# 
    .DESCRIPTION 
        This runbook will attach an existing load balancer to the vNics of the virtual machines, in the Recovery Plan during failover. 
         
        This will create a Public IP address for the failed over VM(s). 
         
        Pre-requisites 
        All resources involved are based on Azure Resource Manager (NOT Azure Classic)

        - A Load Balancer with a backend pool
        - Automation variables for the Load Balancer name, and the Resource Group containing the Load Balancer

        To create the variables and use it towards multiple recovery plans, you should follow this pattern:
            
            New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lb -Value <name of the load balancer> -Encrypted $false

            New-AzureRmAutomationVariable -ResourceGroupName <RGName containing the automation account> -AutomationAccountName <automationAccount Name> -Name <recoveryPlan Name>-lbrg -Value <name of the load balancer resource group> -Encrypted $false           

        The following AzureRm Modules are required
        - AzureRm.Profile
        - AzureRm.Resources
        - AzureRm.Compute
        - AzureRm.Network          
         
        How to add the script? 
        Add this script as a post action in boot up group for which you need a public IP. All the VMs in the group will get a public IP assigned. 
        If the NSG parameters are specified, all the VM's NICs will get the same NSG attached. 
         
        Clean up test failover behavior 
 
    .NOTES 
        AUTHOR: krnese@microsoft.com - AzureCAT
        LASTEDIT: 20 March, 2017 
#> 
param ( 
        [Object]$RecoveryPlanContext 
      ) 

Write-output $RecoveryPlanContext

# Set Error Preference	

$ErrorActionPreference = "Stop"

if ($RecoveryPlanContext.FailoverDirection -ne "PrimaryToSecondary") 
    {
        Write-Output "Failover Direction is not Azure, and the script will stop."
    }

else {

$VMinfo = $RecoveryPlanContext.VmMap | Get-Member | Where-Object MemberType -EQ NoteProperty | select -ExpandProperty Name

    Write-Output ("Found the following VMGuid(s): `n" + $VMInfo)

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
    Write-Output "ResourceGroupName is $RGName"
    
  Try 
  {
    #Logging in to Azure...

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
    $LBNameVariable = $RecoveryPlanContext.RecoveryPlanName + "-LB"    
    $LBRgVariable = $RecoveryPlanContext.RecoveryPlanName + "-LBRG"    
    $LBName = Get-AutomationVariable -Name $LBNameVariable    
    $LBRgName = Get-AutomationVariable -Name $LBRgVariable    
    
 }
Catch
 {
    $ErrorMessage = 'Failed to retrieve Load Balancer info from Automation variables.'
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $_
    Write-Error -Message $ErrorMessage `
                   -ErrorAction Stop
 }

# Get the virtual machines in the Resource Group

  Try
  {
    $VMs = Get-AzureRmVm -ResourceGroupName $RGName
    Write-Output ("Found the following VMs: `n " + $VMs.Name) 
  }
  Catch
  {
      $ErrorMessage = 'Failed to retrieve any VMs in this Resource Group.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
  }
# Verify that availability set exists
    Foreach ($VM in $VMs) 
    {
        if ($VM.AvailabilitySetReference -eq $null) 
        {            
          Write-Output "No Availability set is present for VM: `n" $VM.Name
        }
            
        else             
        {
          Write-Output "Availability set is present for VM: `n" $VM.Name             
        }
    }
# Retrieving network configuration for VMs
    Write-Output "Getting network settings for the VM"    
    $nicName=$VMs[0].NetworkProfile.NetworkInterfaces[0].Id
    $nicName= $nicName.Substring(($nicName.LastIndexOf("/")+1) , $nicName.Length-($nicName.LastIndexOf("/")+1))
    $nic = Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $nicName
    $vnet = $nic.IpConfigurations.subnet.id
    $vNet = $vnet.split("/")
    $vNetRgName = $vNet[4]
    $vNetName = $vNet[8]
    $vNetSubnetName = $vNet[10]
    $virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $vNetRgName -Name $vNetName
    $virtualNetworkSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $vNetSubnetName -VirtualNetwork $virtualNetwork
    $networkID = $virtualNetworkSubnet.AddressPrefix

# Getting Load Balancer

 Try
 {   
    $LoadBalancer = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $LBRgName 

 }
 Catch
 {
    $ErrorMessage = 'Failed to get load balancer.'
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $_
    Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
  }
#Join the VMs NICs to backend pool of the Load Balancer
 Try
  {
    $VMs = Get-AzureRmVM -ResourceGroupName $RGName
    foreach ($VM in $VMs)
    {
        Write-Output $VM.Name "Is connecting to load balancer..."
        $nicName=$VM.NetworkProfile.NetworkInterfaces[0].Id
        $nicName= $nicName.Substring(($nicName.LastIndexOf("/")+1) , $nicName.Length-($nicName.LastIndexOf("/")+1))
        $nic = Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $nicName
        $nic.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($LoadBalancer.BackendAddressPools[0]);        
        $nic | Set-AzureRmNetworkInterface    
        Write-Output "Done configuring Load Balancing for VM" $VM.Name
    }
  }
  Catch
  {
      $ErrorMessage = 'Failed to associate nics with Load Balancer.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
  }
}