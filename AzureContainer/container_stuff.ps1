# Docker examples

cmd

docker search server

docker pull microsoft/iis

Docker run –it –-name krnesedemo windowsservercore powershell

cd\

mkdir kristianrules

docker ps -a

Docker commit krnesedemo demoimage

Docker run –it –name demo02 demoimage powershell

# Switch to PowerShell from here

$image = Get-ContainerImage -Name WindowsServerCore

$container = New-Container -name mycontainer -ContainerImage $image -ContainerComputerName mycontainer -SwitchName (Get-VMSwitch).Name -Verbose

Start-Container $container -Verbose

Enter-PSSession -ContainerName $container.ContainerName -RunAsAdministrator

Install-WindowsFeature -Name web-server -verbose

cd\

mkdir kristianrules

Exit-PSSession

Invoke-Command -ContainerName $container.containername -ScriptBlock {ipconfig}

if (!(Get-NetNatStaticMapping | where {$_.ExternalPort -eq 80})) {
Add-NetNatStaticMapping -NatName "ContainerNat" -Protocol TCP -ExternalIPAddress 0.0.0.0 -InternalIPAddress 172.16.0.2 -InternalPort 80 -ExternalPort 80
}

if (!(Get-NetFirewallRule | where {$_.Name -eq "TCP80"})) {
    New-NetFirewallRule -Name "TCP80" -DisplayName "HTTP on TCP/80" -Protocol tcp -LocalPort 80 -Action Allow -Enabled True
}

# head back to portal.azure and we'll take it from there :-)