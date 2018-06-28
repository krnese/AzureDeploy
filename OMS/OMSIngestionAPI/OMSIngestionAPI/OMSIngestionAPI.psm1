#PowerShell Module leveraged for ingesting data into Log Analytics API ingestion point

#Build API signature for Log Analytics
Function Get-OMSAPISignature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}

# Build & send request to POST API to OMS
Function Send-OMSAPIIngestionData($customerId, $sharedKey, $body, $logType) 
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Get-OMSAPISignature `
     -customerId $customerId `
     -sharedKey $sharedKey `
     -date $rfc1123date `
     -contentLength $contentLength `
     -method $method `
     -contentType $contentType `
     -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
    }
    
    $response = Invoke-WebRequest `
        -Uri $uri `
        -Method $method `
        -ContentType $contentType `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing `
        -verbose
    
    if ($response.StatusCode -eq 202)
    {
        write-output 'Accepted'
    }
}