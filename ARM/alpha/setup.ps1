# Installing Docker

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force -SkipPublisherCheck

Install-package -Name docker -providername DockerMsftProvider -Confirm:$false -Force -Verbose

# Pulling docker image - this will take some time

docker pull dliaodocker/sqlservr

# Creating directories for the setup

mkdir c:\temp\SQLNativeClient11

mkdir c:\temp\servicefabric

# Download SQL stuff

Invoke-WebRequest -Uri http://go.microsoft.com/fwlink/?linkid=239648 -UseBasicParsing -OutFile c:\temp\SQLNativeClient11\sqlncli.msi

msiexec.exe /qn /i c:\temp\SQLNativeClient11\sqlncli.msi IACCEPTSQLNCLILICENSETERMS=YES /L*V C:\temp\SQLNativeClient11\sqlNativeClientInstall.log

# Install choco and SQL binaries

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install sqlserver-odbcdriver -y

choco install sqlserver-cmdlineutils -y

Write-Output "Done with choco!"

# Download Service Fabric

Invoke-WebRequest -Uri http://go.microsoft.com/fwlink/?LinkId=730690 -UseBasicParsing -OutFile c:\temp\servicefabric\Microsoft.Azure.ServiceFabric.WindowsServer.6.1.472.9494.zip

# Extract Service Fabric binaries

Expand-Archive -Path C:\temp\servicefabric\Microsoft.Azure.ServiceFabric.WindowsServer.6.1.472.9494.zip -DestinationPath C:\temp\servicefabric

# Preparing network communication

Write-Verbose "Opening TCP firewall port 445 for networking."
Set-NetFirewallRule -Name 'FPS-SMB-In-TCP' -Enabled True
Get-NetFirewallRule -DisplayGroup 'Network Discovery' | Set-NetFirewallRule -Profile 'Private, Public' -Enabled true

Write-Verbose "Opening TCP firewall port 1433 for SQL."
New-NetFirewallRule -DisplayName "SQL-in" -Name "SQL" -Direction Inbound -Protocol TCP -LocalPort 1433

Write-Verbose "Opening TCP firewall port 5022 for SQL Mirror"
New-NetFirewallRule -DisplayName "SQLMirror-in" -Name "SQL" -Direction Inbound -Protocol TCP -LocalPort 5022

Write-Verbose "Opening SF ports!"
New-NetFirewallRule -DisplayName "SF1" -Name "SF1" -Direction Inbound -Protocol TCP -LocalPort 135
New-NetFirewallRule -DisplayName "SF2" -Name "SF2" -Direction Inbound -Protocol TCP -LocalPort 137
New-NetFirewallRule -DisplayName "SF3" -Name "SF3" -Direction Inbound -Protocol TCP -LocalPort 138
New-NetFirewallRule -DisplayName "SF4" -Name "SF4" -Direction Inbound -Protocol TCP -LocalPort 139
