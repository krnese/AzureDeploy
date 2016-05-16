### All of these actions should take place on a management machine and be performed remotely on the Nano server
### These examples assumes you have deployed Nano with Container and DSC package. If you haven't, either prepare a new image or add through PackageProvider on the fly

# Enter the name of the Nano Server you want to configure with Docker DSC

$nanovm = "nanodemodsc03"

# Creating a new PS Session to the nano server (the machine is already in domain and enabled for remote mgmt
$s = New-PSSession -ComputerName $nanovm

# Install PackageProvider for ContainerImager 

Invoke-Command -Session $s -ScriptBlock { Install-PackageProvider -Name ContainerImage } -Verbose

# Install NanoServer base image

Invoke-Command -Session $s -ScriptBlock { install-ContainerImage -name NanoServer -force } -Verbose

# Download docker.exe

wget https://aka.ms/tp5/docker -OutFile "C:\nanodocker\docker.exe"

# Download dockerd.exe

wget https://aka.ms/tp5/dockerd -OutFile "C:\nanodocker\dockerd.exe"

$item = @()
$item += Get-Item C:\nanodocker\docker.exe
$item += Get-Item C:\nanodocker\dockerd.exe

# Copy files over to nano Server

Copy-Item -ToSession $s -Path $item -Destination c:\ -Recurse

configuration NanoDocker {
    
    $DockerDeamon = "C:\windows\system32\dockerd.exe"
    $DockerClient = "c:\windows\system32\docker.exe"

    #Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node $nanovm {

        File ProgramFiles {
            
            DestinationPath = "C:\ProgramData\Docker\"
            Type = "Directory"
            Force = $true

            }

        File DockerCMD {
            
            DestinationPath = "C:\ProgramData\Docker\runDockerDaemon.cmd"
            Type = "File"
            Force = $true
            Contents = "@echo off
set certs=%ProgramData%\docker\certs.d

if exist %ProgramData%\docker (goto :run)
mkdir %ProgramData%\docker

:run
if exist %certs%\server-cert.pem (if exist %ProgramData%\docker\tag.txt (goto :secure))

if not exist %systemroot%\system32\dockerd.exe (goto :legacy)

dockerd -H npipe:// 
goto :eof

:legacy
docker daemon -H npipe:// 
goto :eof

:secure
if not exist %systemroot%\system32\dockerd.exe (goto :legacysecure)
dockerd -H npipe:// -H 0.0.0.0:2376 --tlsverify --tlscacert=%certs%\ca.pem --tlscert=%certs%\server-cert.pem --tlskey=%certs%\server-key.pem
goto :eof

:legacysecure
docker daemon -H npipe:// -H 0.0.0.0:2376 --tlsverify --tlscacert=%certs%\ca.pem --tlscert=%certs%\server-cert.pem --tlskey=%certs%\server-key.pem"
            DependsOn = "[File]ProgramFiles"
            
            }

        
        File DockerD {

            DestinationPath = $DockerDeamon
            Ensure = "Present"
            SourcePath = "c:\dockerd.exe"
            Type = "File"
            Force = $true
            MatchSource = $true

            }

        File docker {
            DestinationPath = $DockerClient
            Ensure = "Present"
            SourcePath = "c:\docker.exe"
            Type = "file"
            Force = $true
            MatchSource = $true
            DependsOn = "[File]DockerD"
            
            }

        WindowsProcess Docker {
            Path = "C:\ProgramData\docker\runDockerDaemon.cmd"
            Ensure = "Present"
            WorkingDirectory = "C:\ProgramData\Docker"
            Arguments = "/c c:\programdata\docker\rundockerdaemon.cmd > c:\programdata\daemon.log 2>&1"
            DependsOn = "[File]DockerCmd"


        }
        
    }

  }
NanoDocker

Start-DscConfiguration .\nanodocker -ComputerName $nanovm -Wait -Force -Verbose