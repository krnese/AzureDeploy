configuration updateWebApp
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
                    <title>Azure Managed Application v1.2</title>
                    <h3 style="background-color:#0000FF">
                    This is a demo of an UPDATED Azure Managed Application.
                    </h3>
                    <h4 style="background-color:#00FFFF">
                    <a href="https://github.com/Azure/azure-managedapp-samples">Visit our repository for more samples</a>
                    </h4>                                        
                    <meta name="viewport" content="width=device-width, initial-scale=1">

<body>

                    </head>
                    <body>

                    <!DOCTYPE html>
<html>
<style>
input[type=text], select {
    width: 100%;
    padding: 12px 20px;
    margin: 8px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

input[type=Order] {
    width: 100%;
    background-color: #4CAF50;
    color: white;
    padding: 14px 20px;
    margin: 8px 0;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

input[type=Open menu]:hover {
    background-color: #45a049;
}

div {
    border-radius: 10px;
    background-color: white;
    padding: 10px;
}
</style>
<body>

<h3>Contoso Eat & Shine - Place your orders</h3>

<div>
  <form action="/action_page.php">
    <label for="fname">First Name</label>
    <input type="text" id="fname" name="firstname" placeholder="Your name..">

    <label for="lname">Last Name</label>
    <input type="text" id="lname" name="lastname" placeholder="Your last name..">

    <label for="country">Category</label>
    <select id="country" name="Category">
      <option value="australia">Pizza</option>
      <option value="canada">Burgers</option>
      <option value="usa">Steaks</option>
      <option value="usa">Fish</option>
    </select>
  
    <input type="submit" value="Open menu">
  </form>
</div>

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
