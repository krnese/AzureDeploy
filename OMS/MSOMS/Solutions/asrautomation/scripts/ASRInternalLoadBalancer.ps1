
param ( 
        [Object]$RecoveryPlanContext 
      ) 

write-output $RecoveryPlanContext

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

# Logging in to Azure...

    "Logging in to Azure..."
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
     Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    "Selecting Azure subscription..."
    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 

# Getting Automation Variables for NAT port for Load Balancer

$Port = Get-AutomationVariable -Name 'intLbNatPort'

# Get the virtual machines in the Resource Group

    $VMs = Get-AzureRmVm -ResourceGroupName $RGName

    Write-Output ("Found the following VMs: `n " + $VMs.Name) 

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

# Find available IP for load balancer

        $IP = ($networkID -split "\/")[0] 
        $SubnetBits = ($networkID -split "\/")[1] 
         
        #Convert IP into binary 
        #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total 
        $Octets = $IP -split "\." 
        $IPInBinary = @() 
        foreach($Octet in $Octets) 
            { 
                #convert to binary 
                $OctetInBinary = [convert]::ToString($Octet,2) 
                 
                #get length of binary string add leading zeros to make octet 
                $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary) 
 
                $IPInBinary = $IPInBinary + $OctetInBinary 
            } 
        $IPInBinary = $IPInBinary -join "" 
 
        #Get network ID by subtracting subnet mask 
        $HostBits = 32-$SubnetBits 
        $NetworkIDInBinary = $IPInBinary.Substring(0,$SubnetBits) 
         
        #Get host ID and get the first host ID by converting all 1s into 0s 
        $HostIDInBinary = $IPInBinary.Substring($SubnetBits,$HostBits)         
        $HostIDInBinary = $HostIDInBinary -replace "1","0" 
 
        #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits) 
        #Work out max $HostIDInBinary 
        $imax = [convert]::ToInt32(("1" * $HostBits),2) -1 
 
        $IPs = @() 

        #Next ID is first network ID converted to decimal plus $i then converted to binary 
        For ($i = 1 ; $i -le $imax ; $i++) 
            { 
                #Convert to decimal and add $i 
                $NextHostIDInDecimal = ([convert]::ToInt32($HostIDInBinary,2) + $i) 
                #Convert back to binary 
                $NextHostIDInBinary = [convert]::ToString($NextHostIDInDecimal,2) 
                #Add leading zeros 
                #Number of zeros to add  
                $NoOfZerosToAdd = $HostIDInBinary.Length - $NextHostIDInBinary.Length 
                $NextHostIDInBinary = ("0" * $NoOfZerosToAdd) + $NextHostIDInBinary 
 
                #Work out next IP 
                #Add networkID to hostID 
                $NextIPInBinary = $NetworkIDInBinary + $NextHostIDInBinary 
                #Split into octets and separate by . then join 
                $IP = @() 
                For ($x = 1 ; $x -le 4 ; $x++) 
                    { 
                        #Work out start character position 
                        $StartCharNumber = ($x-1)*8 
                        #Get octet in binary 
                        $IPOctetInBinary = $NextIPInBinary.Substring($StartCharNumber,8) 
                        #Convert octet into decimal 
                        $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary,2) 
                        #Add octet to IP  
                        $IP += $IPOctetInDecimal 
                    } 
 
                #Separate by . 
                $IP = $IP -join "." 
                $IPs += $IP 
                 
            }  

$AllIPsCount = $IPs.Count
$SimpleCount = 0

$IP = $null

Do {

    $Result = Test-AzureRmPrivateIPAddressAvailability -VirtualNetwork $virtualNetwork -IPAddress $IPs[$SimpleCount]

    if ($Result.Available -eq $True) {
        $IP = $IPs[$SimpleCount]
        break;

        }
    $SimpleCount++
    }
    while ($SimpleCount -lt $AllIPsCount)
    Write-Output $IP

    if ([string]::IsNullOrEmpty($IP) -eq $False)
    {
        Write-Output "Found available IP - $IP for Load Balancer"
    }
    else
    {
        Write-Output "No Available IP - script will end"
    }

# Creating Load Balancer

    $LBName = "$RGName" + "-LB"

    $FrontEndIP = New-AzureRmLoadBalancerFrontendIpConfig -Name $LBName -PrivateIpAddress $IP -SubnetId $virtualNetworkSubnet.Id
    
    $BackEndAddressPool= New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "LB-BackEnd"

    $inboundNATRuleRDP= New-AzureRmLoadBalancerInboundNatRuleConfig -Name "RDP1" -FrontendIpConfiguration $FrontEndIP -Protocol TCP -FrontendPort $Port -BackendPort $Port

    $LoadBalancer = New-AzureRmLoadBalancer -ResourceGroupName $RGName -Name $LBName -Location $VMs[0].Location -FrontendIpConfiguration $FrontEndIP -InboundNatRule $inboundNATRuleRDP -BackendAddressPool $BackEndAddressPool -Verbose

#Join the VMs NICs to the Backed Pool in the Load Balancer

    $VMs = Get-AzureRmVM -ResourceGroupName $RGName

    foreach ($VM in $VMs)
    {
        Write-Output $VM.Name "Is connecting to load balancer..."
        $nicName=$VM.NetworkProfile.NetworkInterfaces[0].Id
        $nicName= $nicName.Substring(($nicName.LastIndexOf("/")+1) , $nicName.Length-($nicName.LastIndexOf("/")+1))
        $nic = Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $nicName
 
    $nic.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($LoadBalancer.BackendAddressPools[0]);
    
    $nic | Set-AzureRmNetworkInterface    
    }
}