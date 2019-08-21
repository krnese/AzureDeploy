# Placeholder for script logic once changeset works
[string]$changestart = "HEAD"
[string]$changeend = "HEAD~1"

$changeset = (git diff --name-only $changestart $changeend)

Write-Host "The change set is: $($changeset)"

# Current credentials for testing
$pwd = Convertto-SecureString $env:pwd -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user,$pwd)
Connect-AzAccount -credential $credential -tenant $env:tenant -serviceprincipal

Get-AzSubscription