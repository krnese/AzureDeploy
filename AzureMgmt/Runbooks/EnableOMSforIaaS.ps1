param (
        $workspaceName='azurescaleworkspace'
      )

# Grabbing the workspace
Write-Output "Grabbing the workspace: `n $workspaceName"

$workspace = Find-AzureRmResource -ResourceNameContains $workspaceName -ResourceType Microsoft.OperationalInsights/workspaces

Write-Output $workspace

Write-Output "Putting the customerId and primarySharedKey into some variables..."

$workspaceId = (Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).CustomerId
$workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).PrimarySharedKey

Write-Output "Done, now we'll iterate throught the VMs, do a light assessment, and install the OMS extension if missing..."

$VMs = Get-AzureRmVM -ResourceGroupName omsscript

foreach ($VM in $VMs)
{
# Preparing the OMS extensions for Windows and Linux...

Write-Output "Preparing the extensions in case we need them... :-)"

    $winPublicConfig = @{"workspaceId"= $workspaceId; "azureResourceId" = $vm.Id}
    $winPrivateConfig = @{"workspaceKey"= $workspaceKey}
    $linPublicConfig = "{ `"workspaceId`": `"$workspaceId`" }"
    $linPrivateConfig = "{ `"workspaceKey`": `"$workspaceKey`", `"vmResourceId`": `"$($vm.Id)`" }" 

# Check to see if OMS extension is alerady present...

    Write-Output "Check to see if OMS extension is alerady present..."

    $MMA = 'Microsoft.EnterpriseCloud.Monitoring'
    $Extensions | ForEach-Object -Process {
         if ($Extensions.Extensions.Publisher -contains $MMA) 
         {                  
             Write-Output "This VM is managed by a Log Analytics Workspace"
         } 
         else 
         {
             Write-Output "This VM is not managed by a Log Analytics Workspace.. `n" "We'll go ahead and add the extension... :-)"

            if ($VM.OSProfile.WindowsConfiguration -ne $Null)
            {
                Write-Output "This is a Windows VM, so OMS extension for Windows Platform will be added"

                Set-AzureRmVMExtension -ExtensionName 'Microsoft.EnterpriseCloud.Monitoring' `
                                       -Publisher 'Microsoft.EnterpriseCloud.Monitoring' `
                                       -ExtensionType 'MicrosoftMonitoringAgent' `
                                       -Settings $winPublicConfig `
                                       -ProtectedSettings $winPrivateConfig `
                                       -Location $vm.Location `
                                       -ResourceGroupName $vm.ResourceGroupName `
                                       -VMName $vm.Name `
                                       -TypeHandlerVersion 1.0 `
                                       -Verbose
            }
            else
            {
                Write-Output "This is a Linux VM, so we'll add the OMS extension for Linux Platform"

                Set-AzureRmVMExtension -ExtensionName 'OmsAgentForLinux' `
                                       -Publisher 'Microsoft.OSTCExtensions' `
                                       -TypeHandlerVersion 2.0 `
                                       -ExtensionType 'OmsAgentForLinux' `
                                       -Settings $linPublicConfig `
                                       -ProtectedSettings $linPrivateConfig `
                                       -ResourceGroupName $vm.ResourceGroupName `
                                       -VMName $vm.Name `
                                       -Location $vm.Location `
                                       -Verbose
            }
         }
       }
    }
