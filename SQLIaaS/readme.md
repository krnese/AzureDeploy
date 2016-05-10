# Deploy SQL IaaS Extension to existing Virtual Machine

This template will enable the SQL IaaS Extension on your SQL VMs in Azure, letting you enable automated patching and backup of user databases

# Deploy using PowerShell

````powershell
New-AzureRmResourceGroupDeployment -Name 'sqliaas' `
                                   -ResourceGroupName <nameofVMResourceGroup> `
                                   -virtualMachineName <nameofVM> `
                                   -diagnosticsStorageAccountName 'diagstor' `
                                   -diagnosticsStorageAccountType 'Standard_LRS' `
                                   -sqlAutopatchingDayOfWeek 'Sunday' `
                                   -sqlAutopatchingStartHour '5' `
                                   -sqlAutopatchingWindowDuration '60' `
                                   -sqlAutobackupRetentionPeriod '10' `
                                   -Verbose
````
