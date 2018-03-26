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

choco install sqlserver-cmdlineutils -y

choco install sqlserver-odbcdriver -y

# Download Service Fabric

Invoke-WebRequest -Uri http://go.microsoft.com/fwlink/?LinkId=730690 -UseBasicParsing -OutFile c:\temp\servicefabric\Microsoft.Azure.ServiceFabric.WindowsServer.6.1.472.9494.zip

# Extract Service Fabric binaries

Expand-Archive -Path C:\temp\servicefabric\Microsoft.Azure.ServiceFabric.WindowsServer.6.1.472.9494.zip -DestinationPath C:\temp\servicefabric