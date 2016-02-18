
Param (
    [Parameter(Mandatory=$true)]
    [string]$containername,

    [Parameter(Mandatory=$true)]
    [string]$AAendpoint,

    [Parameter(Mandatory=$true)]
    [string]$token
)

# Waiting for the Custom Extension to complete before proceeding...

Start-Sleep -Seconds 120

# Get Container Image

$image = Get-ContainerImage -Name "WindowsServerCore" -Verbose

# Create new Container and install Web-Server

$container = New-Container -Name "Temp" -ContainerImageName $image.Name -ContainerComputerName "Temp" -SwitchName (Get-VMSwitch).Name -RuntimeType Default -Verbose 

# Start the newly created Container

Start-Container $container -Verbose

# Install Web-Server within the container + adding some sleep so that the newly created container get the chance to wake up

start-sleep -Seconds 120

Invoke-Command -ContainerName $container.Name -RunAsAdministrator -ScriptBlock { Install-WindowsFeature -Name Web-Server -IncludeManagementTools } 

# Repeating the process and touch the Web-Server role (bug)

start-sleep -seconds 60

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

Start-Sleep 20

# Import Hybrid Registration

Import-Module -name "c:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\7.2.7241.0\HybridRegistration\HybridRegistration.psd1"

Start-Sleep 20

Add-HybridRunbookWorker –Name OMSWorker -EndPoint $AAendpoint -Token $token

# ENd