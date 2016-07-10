configuration ASRMobilityService {
    
    $RemoteFile = "\\myfileserver\share\ASR.zip"
    $RemotePassphrase = "myfileserver\share\passphrase.txt"
    $TempDestination = "C:\Temp\asr.zip"
    $LocalPassphrase = "C:\Temp\Mobility_service\passphrase.txt"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    param (
            [Parameter(Mandatory=$true)]
            [string]$computername
          )

    node $computername {
        
        xRemoteFile Setup {
           URI = $RemoteFile
           DestinationPath = $TempDestination
           DependsOn = "[File]Directory"
            }

        xRemoteFile Passphrase {
            URI = $RemotePassphrase
            DestinationPath = $LocalPassphrase
            DependsOn = "[File]Directory"
            }

        File Directory {
            DestinationPath = "C:\Temp\ASRSetup\"
            Type = "Directory"            
            }

        Archive ASRzip {
           Path = $TempDestination
           Destination = "C:\Temp\ASRSetup"
           DependsOn = "[xRemotefile]Setup"
           }

        Package Install {
            Path = "C:\temp\ASRSetup\ASR\UNIFIEDAGENT.EXE"
            Ensure = "Present"
            Name = "Microsoft Azure Site Recovery mobility Service/Master Target Server"
            ProductId = "275197FC-14FD-4560-A5EB-38217F80CBD1"
            Arguments = '/Role "Agent" /InstallLocation "C:\Program Files (x86)\Microsoft Azure Site Recovery" /CSEndPoint "10.0.0.115" /PassphraseFilePath "C:\Temp\Mobility_service\passphrase.txt"'
            DependsOn = "[Archive]ASRzip"
            }           

        Service ASRvx {
            Name = "svagents"
            Ensure = "Present"
            State = "Running"
            DependsOn = "[Package]Install"
            }

        Service ASR {
            Name = "InMage Scout Application Service"
            Ensure = "Present"
            State = "Running"
            DependsOn = "[Package]Install"
            }
        }
    }
