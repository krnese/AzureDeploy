# Azure Monitor Policies

The script in this repo will help generate policies for a resource type. It simplifies the process vs having to manually change each policy.

## Running the script

To run the script, go to PowerShell in the same directory as your policies and run:

```powershell

.\generator.ps1 -rpShortName "shortName" -serviceName "A Long Name" -resourceType "Microsoft.Test/test" -hasMetrics $true -hasLogs $true -logCategories 'Category1','Category2'

```

Descriptions of these properties:
* **rpShortName** - a short name for the service, used as a prefix for the policy JSON. Eg. 'iot' or 'sql'
* **serviceName** - a descriptive name for the service, used in the policy description. Eg. 'IoT Hubs' or 'SQL Databases'
* **resourceType** - ARM resource type of the service. Eg. Microsoft.Devices/iotHubs
* **hasMetrics** - Boolean for if the service emits metrics.
* **hasLogs** - Boolean for if the service emits logs. If true, must also have the -logCategories parameter.
* **logCategories** - List of log categories, comma separated.

## Notes
* Do not modify the `AzMonDeployIfNotExists-template.json` file, this is used by the script to generate new policies
* Do not run the script from a different folder than the folder with the template file.
* `generator.ps1` and `AzMonDeployIfNotExists-template.json` should be excluded from the list of policies to be created as built-in policies.