# Check Azure subscription read & write limits
# You should run 'Login-AzureRmAccount' before executing this snippet :-)

$currentContext = Get-AzureRmContext
$token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id}    

 $readLimits = @{
     Uri = "https://management.azure.com/subscriptions/$($currentContext.Subscription.Id)/resourcegroups?api-version=2016-09-01"
     Headers = @{
           Authorization = "Bearer $($token.AccessToken)"
           'Content-Type' = 'application/json'
           }
           Method = 'Get'
           UseBasicParsing = $true
        }
$result = Invoke-WebRequest @readLimits

$remainingReadLimit = $result.Headers["x-ms-ratelimit-remaining-subscription-reads"]


Write-output "Your remaining reads in subscription:" (get-azurermcontext).subscription.name "is:" $remainingReadLimit

$body = @"
{
    "location": "West Us"
    
}
"@

$rgName = [guid]::NewGuid().guid

$writeLimits = @{
     Uri = "https://management.azure.com/subscriptions/$($currentContext.Subscription.Id)/resourcegroups/$($rgName)?api-version=2016-09-01"
     Headers = @{
           Authorization = "Bearer $($token.AccessToken)"
           'Content-Type' = 'application/json'
           }
           Method = 'Put'
           Body = $body
           UseBasicParsing = $true
        }
$writeResult = Invoke-WebRequest @writeLimits

$remainingWriteLimit = $writeResult.Headers["x-ms-ratelimit-remaining-subscription-writes"]

Write-output "Your remaining writes in subscription:" (get-azurermcontext).subscription.name "is:" $remainingWriteLimit

# clean up 

$deleteRg = @{
     Uri = "https://management.azure.com/subscriptions/$($currentContext.Subscription.Id)/resourcegroups/$($rgName)?api-version=2016-09-01"
     Headers = @{
           Authorization = "Bearer $($token.AccessToken)"
           'Content-Type' = 'application/json'
           }
           Method = 'Delete'
        }
$delete = Invoke-WebRequest @deleteRg

Write-Output "Done!"