configuration ASRMobilityService {
    
    $RemoteFile = Get-AutomationVariable -Name "RemoteFile"
    $RemotePassphrase = Get-AutomationVariable -Name "RemotePassphrase"
    $RemoteAzureAgent = "http://go.microsoft.com/fwlink/p/?LinkId=394789"
    $LocalAzureAgent = "C:\Temp\AzureVmAgent.msi"
    $TempDestination = "C:\Temp\asr.zip"
    $LocalPassphrase = "C:\Temp\Mobility_service\passphrase.txt"
    $Role = 'Agent'
    $Install = 'C:\Program Files (x86)\Microsoft Azure Site Recovery'
    $CSEndpoint = Get-AutomationVariable -Name "CSEndpoint"
    $Arguments = '/Role ' + '"' + $Role + '"' + ' /InstallLocation ' + '"' + $Install + '"' + ' /CSEndpoint ' + '"' + $CSEndpoint + '"' + ' /PassphraseFilePath ' +  '"' +$LocalPassphrase + '"'  

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    node localhost {
        
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

        xRemoteFile AzureAgent {
            URI = $RemoteAzureAgent
            DestinationPath = $LocalAzureAgent
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
            Arguments = $Arguments
            DependsOn = "[Archive]ASRzip"
            }
        
        Package AzureAgent {
            Path = "C:\Temp\AzureVmAgent.msi"
            Ensure = "Present"
            Name = "Windows Azure VM Agent - 2.7.1198.735"
            ProductId = "5CF4D04A-F16C-4892-9196-6025EA61F964"
            Arguments = '/q /l "c:\temp\agentlog.txt'
            DependsOn = "[Package]Install"
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

        Service AzureAgentService {
            Name = "WindowsAzureGuestAgent"
            Ensure = "Present"
            State = "Running"
            DependsOn = "[Package]AzureAgent"
            }

        Service AzureTelemetry {
            Name = "WindowsAzureTelemetryService"
            Ensure = "Present"
            State = "Running"
            DependsOn = "[Package]AzureAgent"
            }
    }
}

