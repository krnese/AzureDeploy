## Generate a new policy for any resource type

param([string]$rpShortName = "batch", [string]$serviceName = "Azure Batch", [string]$resourceType = "Microsoft.Batch/batchAccounts", [bool]$hasMetrics = $false, [bool]$hasLogs = $false, [array]$logCategories = 'category1')
#$rpShortName = 'classicCompute'
#$serviceName = 'Classic Virtual Machines'
#$resourceType = 'Microsoft.ClassicCompute/virtualMachines'
#$hasMetrics = $true
#$hasLogs = $false
#$logCategories = 'ServiceLog','anotherLog'

$metricsArray = ''
$logsArray = ''

if($hasLogs) {
    $logsArray += '
                                            "logs": ['
    foreach ($element in $logCategories) {
        $logsArray += "
                                                {
                                                    `"category`": `"$element`",
                                                    `"enabled`": true
                                                },"
    }
    $logsArray = $logsArray.Substring(0,$logsArray.Length-1)
    $logsArray += '
                                            ]'
}

if($hasMetrics) {
    $metricsArray = '
                                            "metrics": [
                                                {
                                                    "category": "AllMetrics",
                                                    "enabled": true,
                                                    "retentionPolicy": {
                                                        "enabled": false,
                                                        "days": 0
                                                    }
                                                }
                                            ],'
}
if (!$hasLogs) { $metricsArray = $metricsArray.Substring(0,$metricsArray.Length-1) }
$templatePath = $PWD.path + '\AzMonDeployIfNotExists-template.json'
$newPath = $PWD.path + '\' + $rpShortName + 'AzMonDeloyIfNotExists.json'
Copy-Item -Path $templatePath -Destination $newPath
(Get-Content $newPath).replace('<NAME OF SERVICE>', $serviceName) | Set-Content $newPath
(Get-Content $newPath).replace('<RESOURCE TYPE>', $resourceType) | Set-Content $newPath
(Get-Content $newPath).replace('<LOGS ARRAY>', $logsArray) | Set-Content $newPath
(Get-Content $newPath).replace('<METRICS ARRAY>', $metricsArray) | Set-Content $newPath
