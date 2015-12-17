
Param (
    [Parameter(Mandatory=$true)]
    [string]$containername
)

# Waiting for the Custom Extension to complete before proceeding...

Start-Sleep -Seconds 120

# Get Container Image

$image = Get-ContainerImage -Name "WindowsServerCore" -Verbose

# Create new Container and install Web-Server

$container = New-Container -Name "Temp" -ContainerImageName $image.Name -ContainerComputerName "Temp" -SwitchName (Get-VMSwitch).Name -RuntimeType Default -Verbose 

# Start the newly created Container

Start-Container $container -Verbose

# Install Web-Server within the container

Invoke-Command -ContainerName $container.Name -RunAsAdministrator -ScriptBlock { Install-WindowsFeature -Name Web-Server -IncludeManagementTools } 

# Stop the newly created Container

Stop-Container -Container $container -Verbose

# Create new Container image for Web Server

$newImage = New-ContainerImage -Container $container -Name "Web" -Version 1.0.0.0 -Publisher knese -Verbose

# Create new Container based on Web Server container image

$newcontainer = New-Container -Name $containername -ContainerImageName $newImage.Name -ContainerComputerName $containername -SwitchName (Get-VMSwitch).Name -RuntimeType Default -Verbose

# Start new Container containing the Web Server

Start-Container $newcontainer -Verbose

# Creating NAT rules and port config for container

if (!(Get-NetNatStaticMapping | where {$_.ExternalPort -eq 80})) {
Add-NetNatStaticMapping -NatName "ContainerNat" -Protocol TCP -ExternalIPAddress 0.0.0.0 -InternalIPAddress 172.16.0.2 -InternalPort 80 -ExternalPort 80
}

if (!(Get-NetFirewallRule | where {$_.Name -eq "TCP80"})) {
    New-NetFirewallRule -Name "TCP80" -DisplayName "HTTP on TCP/80" -Protocol tcp -LocalPort 80 -Action Allow -Enabled True
}

Write-Host "You are done :-)"