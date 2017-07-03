configuration ManagedWebApplication
{
    Import-DscResource -Module xWebAdministration

    Node localhost
    {
        WindowsFeature IISWeb
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        xWebSite DefaultSite
        {
            Ensure = "Present"
            Name = "Default Web Site"
            State = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn = "[WindowsFeature]IISWeb"
        }

        File CreateWebConfig 
        { 
         DestinationPath = "c:\inetpub\wwwroot" + "\iisstart.htm" 
         Contents = '<!DOCTYPE html>
                    <html>
                    <head>
                    <title>Azure Managed Application</title>
                    </head>
                    <body>

                    <h1>Hello world :-)</h1>
                    <h2>This is a demo of Azure Managed Application.</h2>

                    <img src="http://2.bp.blogspot.com/-nmP0pk6WsHs/Vq9WYuwImrI/AAAAAAAABqk/icfd6U7oSJk/s1600/cloudcloud.png" alt="HTML5 Icon" style="width:128px;height:128px;">
                    <h2><a href="https://github.com/Azure/azure-managedapp-samples">Visit our repository for more samples</a></h2>
                    </p>

                    </body>
                    </html>' 
                Ensure = "Present"         
        } 
        
        xWebSite Appliance
        {
            Ensure = "Present"
            Name = "Appliance"
            State = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn = "[xWebSite]DefaultSite" 
            BindingInfo = MSFT_xWebBindingInformation
                        {
                            Port = "80"
                            Protocol = "http"
                        }                                  
        }
    }
}
