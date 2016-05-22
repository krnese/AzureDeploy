Login-AzureRmAccount -credential (get-credential -credential automation@kristianneseoutlook.onmicrosoft.com)

$vault1 = Get-AzureRmRecoveryServicesVault –Name "KNRecovery" -ResourceGroupName KNOMS

Set-AzureRmRecoveryServicesBackupProperties  -vault $vault1 -BackupStorageRedundancy GeoRedundant

$vault1 | Set-AzureRmRecoveryServicesVaultContext

get-AzureRMRecoveryServicesBackupProtectionPolicy -WorkloadType AzureVM

$schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"

$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"

New-AzureRmRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType AzureVM -RetentionPolicy $retPol -SchedulePolicy $schPol

$pol=Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "NewPolicy"

Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -Name "V2VM" -ResourceGroupName "RGName1"

#region modify existing policy

$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
$retPol.DailySchedule.DurationCountInDays = 365
$pol= Get-AzureRMRecoveryServicesBackupProtectionPolicy -Name NewPolicy
Set-AzureRmRecoveryServicesBackupProtectionPolicy -Policy $pol  -RetentionPolicy  $RetPol

#endregion 

$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -Name "V2VM";
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM";
$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item;

$joblist = Get-AzureRMRecoveryservicesBackupJob –Status InProgress

$joblist[0]

#region restore an Azure IaaS v2 VM

$namedContainer = Get-AzureRmRecoveryServicesBackupContainer  -ContainerType AzureVM –Status Registered -Name 'V2VM'

$backupitem = Get-AzureRmRecoveryServicesBackupItem –Container $namedContainer  –WorkloadType "AzureVM"

$restorejob = Get-AzureRmRecoveryServicesBackupJob -Job $restorejob
$details = Get-AzureRmRecoveryServicesBackupJobDetails
$properties = $details.Properties
$storageAccountName = $properties["Target Storage Account Name"]
$containerName = $properties["Config Blob Container Name"]
$blobName = $properties["Config Blob Name"]
Set-AzureRmCurrentStorageAccount -Name $storageaccountname -ResourceGroupName test
$destination_path = "C:\vmconfig.json"
Get-AzureStorageBlobContent -Container $containerName -Blob $blobName -Destination $destination_path -Context $storageContext
$obj = ((Get-Content -Path $destination_path -Encoding UniCode)).TrimEnd([char]0x00) | ConvertFrom-Json
$vm = New-AzureRmVMConfig -VMSize $obj.HardwareProfile.VirtualMachineSize -VMName "testrestore"
Set-AzureRmVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.StorageProfile.OSDisk.VirtualHardDisk.Uri

$nicName="p1234"
$pip = New-AzureRmPublicIpAddress -Name $nicName -ResourceGroupName "test" -Location "CentralIndia" -AllocationMethod Dynamic
$vnet = Get-AzureRmVirtualNetwork -Name "testvNET" -ResourceGroupName "test"
$subnetIndex=0
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName "test" -Location "centralindia" -SubnetId $vnet.Subnets[$subnetIndex].Id -PublicIpAddressId $pip.Id
$vm=Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
$vm.StorageProfile.OsDisk.OsType = $obj.StorageProfile.OSDisk.OperatingSystemType
New-AzureRmVM -ResourceGroupName "test" -Location "centralindia" -VM $vm

#endregion