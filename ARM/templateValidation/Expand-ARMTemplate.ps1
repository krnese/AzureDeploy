function Expand-ARMTemplate {
    <#
        .Synopsis
        Validates ARM template in combination with parameter file and returns ARM expanded results.

        .Example
        Expand-AzureRMTemplate -TemplateFile c:\subnet.json -ParameterFile c:\param.json -ResourceGroupName 'myRG'
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $TemplateFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ParameterFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName
    )
    begin {
        $currentContext = Get-AzureRmContext
        $token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id}
    }
    process {
        $templateParams = Get-Content -Raw $ParameterFile | ConvertFrom-Json
        $body = @"
{
    "properties": {
        "template": $(Get-Content -Raw $TemplateFile),
        "parameters": $($templateParams.parameters | ConvertTo-Json -Depth 100),
        "mode": "Incremental"
    }
}
"@

        $iwrArgs = @{
            Uri = "https://management.azure.com/subscriptions/$($currentContext.Subscription.Id)/resourcegroups/$ResourceGroupName/providers/Microsoft.Resources/deployments/$([guid]::NewGuid().guid)/validate?api-version=2017-05-10"
            Headers = @{
                Authorization = "Bearer $($token.AccessToken)"
                'Content-Type' = 'application/json'
            }
            Method = 'Post'
            Body = $body
            UseBasicParsing = $true
        }
        $result = Invoke-WebRequest @iwrArgs
        #pretty print
        [Newtonsoft.Json.Linq.JObject]::Parse($result.Content).ToString()
    }
} 