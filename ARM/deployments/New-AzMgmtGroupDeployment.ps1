function New-AzMgmtGroupDeployment {
    <#
        .Synopsis
        Deploys Azure Resource Manager template to a Management Group

        .Example
        New-AzMgmtGroupDeployment -MgmtGroupId <id> -TemplateFile <path> -ParameterFile <path>
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty]
        [string] $TemplateFile,

        [string] $ParameterFile,

        [Parameter(Mandatory), ValueFromPipeline)]
        [ValidateNotNullOrEmpty]
        [string] $MgmtGroupId
    )
    begin {
        $currentContext = Get-AzContext
        $token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id}
    }
    process {
        $TemplateParameters = Get-Content -Raw $ParameterFile | ConvertFrom-Json
        $body = @"
{
    "properties": {
        "template": $(Get-Content -Raw $TemplateFile),
        "parameters": $($TemplateParameters.parameters | ConvertTo-Json -Depth 100),
        "mode": "incremental"
    }
}
"@

    # ARM Request
    $ARMRequest = @{
        Uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$($MgmtGroupId)/providers/Microsoft.Resources/deployments?api-version=2019-05-01"
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Methord = 'Put'
        Body = $body
        UseBasicParsing = $true
    }
    $Deploy = Invoke-WebRequest @ARMRequest
    #prettify
    [Newtonsoft.Json.Linq.JObject]::Parse($deploy.Content).ToString()
    }
}
