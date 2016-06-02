Configuration A2A
{
  
    $A2APackageLocalPath = "C:\A2A\MicrosoftAzureSiteRecoveryUnifiedSetup.exe"

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost {

        xRemoteFile OMSPackage {
            Uri = "https://aka.ms/unifiedinstaller"
            DestinationPath = $A2APackageLocalPath
        }
        }
    }
a2a