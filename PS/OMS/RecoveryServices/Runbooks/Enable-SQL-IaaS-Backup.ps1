<# Installing SQL Server IaaS Agent Extension into Azure VM

#>


param (
    
    [object]$webhookdata
      
      )
            
			$webhookname = $webhookdata.WebhookName 
			
			write-output $webhookname
			
            $webhookHeaders = $webhookdata.RequestHeader 
			
			write-output $webhookHeaders
			
            $webhookBody = $webhookdata.RequestBody 
			
			write-output $webhookBody 

        	$resultsobj = $WebhookData.RequestBody | Convertfrom-Json
                                       
        	$SearchResults = $resultsobj.SearchResults.value
			
			Try
    {
		$credential = Get-AutomationPSCredential -Name 'AutoAdmin'
		Add-AzureRmAccount -Credential $credential
		$subscriptionID = "ec8ddce6-2ecb-45b3-b3e6-d370e8863b99"
		Select-AzureRmSubscription -SubscriptionId "ec8ddce6-2ecb-45b3-b3e6-d370e8863b99"	
    }
    		Catch
    {
        $ErrorMessage = 'Failed to logon to Azure'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
    }
		
		    foreach ($result in $SearchResults)
	{
		#region Construct credentials and variables
        # Crack open the Computer Name
        	$netbiosname = $result.computer.Split('.')
			$serverName = $netbiosname[0]
			
    		    $vms = Get-AzureRmVM | Where-Object {$_.Name -like "*$servername*"}  -ErrorAction Stop
	
				foreach ($vm in $vms)
				{
					Get-AzureRmVM -Name $vm.name -ResourceGroupName $vm.ResourceGroupName -ErrorAction Stop

            			$IsExt=$null 
						$IsExt=$vm.Extensions | Where-Object {$_.Publisher -eq "Microsoft.SqlServer.Management"} 
						if ($isExt) {Write-output "It's already here!"}
						
						else

            			{
                				foreach ($vm in $vms)

                		{
                    		New-AzureRmResourceGroupDeployment -Name SQLIaaS -ResourceGroupName $vm.ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/krnese/AzureDeploy/master/SQLIaaS/SQLIaaS.json" -virtualMachineName $vm.Name -diagnosticsStorageAccountName sql -sqlAutopatchingDayOfWeek Sunday -sqlAutopatchingStartHour 1 -sqlAutobackupRetentionPeriod 5 -ErrorAction Stop
	            		}
            		}
				}
	} 
    
