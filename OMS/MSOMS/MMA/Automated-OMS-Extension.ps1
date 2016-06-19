<#
.Synopsis
   Runbook for automated IaaS OMS Extensiond deployment in Azure
.DESCRIPTION
   This Runbook will enable OMS Extensions on all Azure IaaS VMs
#>


$credential = Get-AutomationPSCredential -Name 'AzureCredentials'
$subscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionID'
$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$OMSWorkspaceName = Get-AutomationVariable -Name 'OMSWorkspaceName'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
$templateuri = 'https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/MMA/azuredeploy.json'

$ErrorActionPreference = 'Stop'

Try {
        Login-AzureRmAccount -credential $credential
        Select-AzureRmSubscription -SubscriptionId $subscriptionId

    }

Catch {
        $ErrorMessage = 'Login to Azure failed.'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }

Try {
        $VMs = Get-AzureRmVM
    }

Catch {
        $ErrorMessage = 'Failed to retrieve the VMs.'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
     }

Try {
			foreach ($vm in $vms)
				{
					Get-AzureRmVM -Name $vm.name -ResourceGroupName $vm.ResourceGroupName -ErrorAction Stop

            			$IsExt=$null 
						$IsExt=$vm.Extensions | Where-Object {$_.Publisher -eq "Microsoft.EnterpriseCloud.Monitoring"} 
						if ($isExt) {Write-output "It's already here!"}
						
						else

            			{
                				foreach ($vm in $vms)

                		{
                    		New-AzureRmResourceGroupDeployment -Name MMAdeployment `
                                                               -ResourceGroupName $vm.ResourceGroupName `
                                                               -TemplateUri $templateuri `
                                                               -vmName $vm.Name `
                                                               -OMSLogAnalyticsWorkspaceName $OMSworkspaceName `
                                                               -OMSLogAnalyticsResourceGroup $OMSResourceGroupName `
                                                               -Verbose                                                               
	            		}
            		}
				}
	}

Catch {
        $ErrorMessage = 'Failed to deploy extensions.'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
     } 
