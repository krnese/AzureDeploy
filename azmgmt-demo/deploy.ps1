# Create 2 resource groups, for mgmt and workload
$MgmtRgName = 'krnesemgmt47' # Specify a name for the resource group containing the management services
$WorkloadRgName = 'krnesewl47' # Specify a name for the resource group containing the virtual machine(s)

$MgmtRg = New-AzureRmResourceGroup -Name $MgmtRgName -Location westeurope -Verbose
$WorkloadRg = New-AzureRmResourceGroup -Name $WorkloadRgName -Location westeurope -Verbose

# Define parameters for template deployment - remember to change the values!f

$azMgmtPrefix = 'olv47'
$Platform = 'Linux' # Select either 'Windows' or 'Linux'
$userName = 'knadmin' # username for the VM
$vmNamePrefix = 'ol47' # Specify the suffix for the virtual machine(s) that will be created
$instanceCount = '2' # You can create 1-10 VMs
$deploymentName = 'tss' # Specify the name of the main ARM template deployment job
$templateuri = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/azmgmt-demo/azuredeploy.json'

# Deploy template

New-AzureRmResourceGroupDeployment -Name $deploymentName `
                                   -ResourceGroupName $MgmtRg.ResourceGroupName `
                                   -TemplateUri $templateUri `
                                   -vmResourceGroup $WorkloadRg.ResourceGroupName `
                                   -azMgmtPrefix $azMgmtPrefix `
                                   -vmNamePrefix $vmNamePrefix `
                                   -userName $userName `
                                   -platform $platform `
                                   -instanceCount $instanceCount `
                                   -verbose

