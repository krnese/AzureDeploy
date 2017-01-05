param (
    
    [object]$WebhookData
      
      )
            
            $webhookname = $WebhookData.WebhookName		
			
            $webhookHeaders = $WebhookData.RequestHeader						
			
            $webhookBody = $WebhookData.RequestBody

        	$resultsobj = ConvertFrom-Json -InputObject $WebhookData.RequestBody
                                       
        	$SearchResults = $resultsobj.SearchResults.value

            write-output $SearchResults
			
			Try
    {
        "Logging in to Azure..."
        $Conn = Get-AutomationConnection -Name AzureRunAsConnection 
        Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

        "Selecting Azure subscription..."
        Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 	
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

        # Getting the required Automation variables
        $OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
        $TemplateUri='https://raw.githubusercontent.com/krnese/AzureDeploy/master/AzureMgmt/Mgmt/azureIaaSBackup.json'
        $OMSRecoveryVault = Get-AutomationVariable -Name 'OMSRecoveryVault'

Try {

        $Location = Get-AzureRmRecoveryServicesVault -Name $OMSRecoveryVault -ResourceGroupName $OMSResourceGroupName | select -ExpandProperty Location
    }

Catch {
        $ErrorMessage = 'Failed to retrieve the OMS Recovery Location property'
        $ErrorMessage += "`n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }        
		
foreach ($result in $SearchResults)
	{

# Find the VMName and verify it is in the same region as the vault

        	$serverName = $result.Resource
		
    		$VMs = Get-AzureRmVM | Where-Object {$_.Name -like "*$servername*" -and $_.Location -eq $Location}

# Enable Backup using ARM template

Try {
        Foreach ($vm in $vms)
        {
            New-AzureRmResourceGroupDeployment -Name $VM.Name `
                                               -ResourceGroupName $OMSResourceGroupName `
                                               -TemplateUri $TemplateUri `
                                               -omsRecoveryResourceGroupName $OMSResourceGroupName `
                                               -vmResourceGroupName $VM.ResourceGroupName `
                                               -vaultName $OMSRecoveryVault `
                                               -vmName $VM.Name `
                                               -Verbose
        }
    }

Catch {
        $ErrorMessage = 'Failed to enable backup using ARM template.'
        $ErrorMessage += "`n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }            
    }
	