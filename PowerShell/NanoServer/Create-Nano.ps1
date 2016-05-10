param (
        $computername = 'nanodemo10',
        $domainname = 'coffee.azurestack.coffee',
        $basepath = 'c:\nanostaging',
        $targetpath = $computername + '.vhdx',
        $vmname = $computername,
        $hypervisor = 'nanodmz',
        $vmconfigpath = 'c:\vms',
        $vmswitch = 'VM'
      )

$Remoteshare = 'M:\'$ShareExists = Test-Path $Remoteshare If ($ShareExists -eq $true) {Write-Output "it's already mounted"}
Else {

    Write-Output "It's not mounted, so we'll fix it on the fly"

    New-PSDrive -Name 'M' -PSProvider FileSystem -Root \\$hypervisor\c$\vms 

    }

Write-Output "Trying to mount disk image"

Mount-DiskImage -ImagePath C:\install\2016\en_windows_server_2016_technical_preview_5_x64_dvd_8512312.iso

Write-Output "Trying to import PS module"

Import-Module e:\nanoserver\nanoserverimagegenerator

# Create admin password

$pwd = "abab12UNI" | ConvertTo-SecureString -AsPlainText -Force

New-NanoServerImage -DeploymentType Guest -Edition Datacenter -MediaPath e:\ -BasePath $basepath -TargetPath c:\runbook\$targetpath -MaxSize 60gb -Containers -ComputerName $computername -DomainName $domainname -EnableRemoteManagementPort -AdministratorPassword $pwd -Verbose 

Copy-Item -Path c:\runbook\$targetpath -Destination M:\ -Force

New-VM -ComputerName $hypervisor -Name $computername -MemoryStartupBytes 512mb -BootDevice VHD -VHDPath c:\vms\$targetpath -SwitchName VMSET -Path 'c:\vms' -Generation 2 | Start-VM -Verbose

Write-Output "We're done here. The VM is now running"