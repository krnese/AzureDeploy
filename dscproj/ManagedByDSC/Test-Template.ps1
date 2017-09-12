
[CmdletBinding()]
param(
    [switch]$Deploy
)
$locations = Get-AzureRmLocation | Where-Object {$_.Providers -contains 'Microsoft.Automation'}
$max = $locations.Count-1
$index = Get-Random -Maximum $max
$location = $locations[$index].Location
$rgname = "APITEST$((new-guid).Guid)"
$localpath = if ($env:Build_Repository_LocalPath) {$env:Build_Repository_LocalPath} else {'.'}
$parametersFileName = if ($deploy){'mainTemplate.deployparameters.json'} else {'mainTemplate.validateparameters.json'}

try {
    
    New-AzureRmResourceGroup -Name $rgname -location $location

    Write-Output 'Creating a storage account'

    # create a storage account to copy the files to this is done to make sure  templateLink property exists on deployment object

    $StorageAccountName = "v$((new-guid).Guid.Replace('-',''))".ToLowerInvariant().Substring(0,24)
    $storageAccount = New-AzureRMStorageAccount -Name $StorageAccountName  -Location $location -ResourceGroupName $rgname -SkuName 'Standard_LRS'
    $StorageContainerName = "test"
    $StorageContainer = New-AzureStorageContainer -Name $StorageContainerName -Permission Blob -Context $storageAccount.Context
    $template = Set-AzureStorageBlobContent -Container $StorageContainerName -File "$localpath\mainTemplate.json"  -Context $storageAccount.Context
    $mainTemplateUri = $template.ICloudBlob.StorageUri.PrimaryUri
   
    Write-Output 'Uploading dependencies'

    Get-ChildItem -Path "$localpath" -Filter *.json |%{
        $FileUpload = Set-AzureStorageBlobContent -Container $StorageContainerName -File $_.FullName -Context $storageAccount.Context -Blob "$($_.Name)" -Force | % Name
    }

    if ($deploy) {

        Write-Output "Deploying Template for $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"
        New-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateUri $mainTemplateUri  -TemplateParameterFile $localpath\$parametersFileName
        
        if (!$?)
        {
            Write-Output "Failed Template Deployment for $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"
            $haserror=$true
            throw $_
        }
        
        Write-Output "Finished Deploying Template $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"
    }
    else {
        
        Write-Output "Validating Template $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"
        $result = Test-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateUri $mainTemplateUri  -TemplateParameterFile $localpath\$parametersFileName

        if ($result)
        {
            
            Write-Output "Failed Template Validation for $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"
            $result | ForEach-Object {
                Write-Output "Code: $($_.Code)"
                Write-Output "Message: $($_.Message)"
               
                if ($_.Details)
                {
                    if ($_.Details.GetType().Name -eq 'String')
                    {
                        Write-Output "Details: $($_.Details)"
                    }
                    else
                    {
                        Write-Output "Details:"
                        $_.Details | ForEach-Object {$_.Details}
                    } 
                }
            }

            $haserror = $true
            throw $_
        }
        Write-Output "Finished Validating Template $localpath\mainTemplate.json using parameters $localpath\$parametersFileName"   
    }
}
finally {
    Write-Output "Removing Resource Group $rgname" 
    Remove-AzureRmResourceGroup -name $rgname  -force -ErrorAction silentlycontinue
    if ($haserror) {throw $_}
}