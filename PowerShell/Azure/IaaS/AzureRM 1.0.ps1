# Connect to your Azure subscription

Add-AzureRmAccount -Credential (get-credential)

# Add some variables that you will use as you move forward

# Global

$RGname = "KNRGTest01"
$Location = "west europe"

# Storage

$StorageName = "Knstor5050"
$StorageType = "Standard_LRS"

# Network

$vnicName = "vmvNic"
$Subnet1Name = "Subnet1"
$vNetName = "KNVnet01"
$vNetAddressPrefix = "192.168.0.0/16"
$vNetSubnetAddressPrefix = "192.168.0.0/24"

# Compute

$VMName = "KNVM01"
$ComputerName = $VMName
$VMSize = "Standard_A2"
$OSDiskName = $VMName + "osDisk"

# Create a new Azure Resource Grou

$RG = New-AzureRmResourceGroup -Name $RGname -Location $location -Verbose

# Create Storage

$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGname -Name knstor5050 -Type $StorageType -Location $Location 

# Create Network

$PIP = New-AzureRmPublicIpAddress -Name $vnicName -ResourceGroupName $RGname -Location $Location -AllocationMethod Dynamic
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $vNetSubnetAddressPrefix
$vNET = New-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $RGname -Location $Location -AddressPrefix $vNetAddressPrefix -Subnet $SubnetConfig
$Interface = New-AzureRmNetworkInterface -Name $vnicName -ResourceGroupName $RGname -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Create Compute

# Setup local VM object

$Credential = Get-Credential
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize 
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $interface.Id 
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd" 
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption fromImage 

# Deploy the VM in Azure

New-AzureRmVM -ResourceGroupName $RGname -Location $Location -VM $VirtualMachine 

# Publish DSC config to your newly created storage account

Publish-AzureRmVMDscConfiguration -ResourceGroupName $RGname -ConfigurationPath .\webdsc.ps1 -StorageAccountName knstor5050 

# Add DSC Extension with config to the newly created VM

Set-AzureRmVMDscExtension -ResourceGroupName $RGname -VMName $virtualmachine.Name -ArchiveBlobName webdsc.ps1.zip -ArchiveStorageAccountName knstor5050 -ConfigurationName webdsc -Version 2.7 -Location $location 


