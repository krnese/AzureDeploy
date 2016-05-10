$ip = '10.0.0.128'

$cred = Get-Credential -Credential $ip\administrator

set-item WSMan:\localhost\Client\TrustedHosts $ip -Concatenate

Enter-PSSession -ComputerName $ip -Credential $cred

# Enabling fil copy to Nano

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes

# Enabling CredSSP for Nano to do Live Migration and VMs over SMB

Enable-WSManCredSSP -Role ServerNet localgroup administrators coffee\knadmin /add# On management server, run the following:Enable-WSManCredSSP –Role Client –DelegateComputer nanocompute01.coffee.azurestack.coffee$s1=new-pssession -ComputerName NAnodmz.coffee.azurestack.coffee  -authentication CredSSP -Credential coffee\knadmin$inst = Get-CimInstance Win32_OperatingSystem –ComputerName localhost# Reboot Nano server using Invoke-CimMethodInvoke-CimMethod –ClassName Win32_OperatingSystem –MethodName Reboot -ComputerName nanodmz