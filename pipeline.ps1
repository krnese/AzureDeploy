# Placeholder for script logic once changeset works
[string]$changestart = "HEAD"
[string]$changeend = "HEAD~1"

$changeset = (git diff --name-only origin/master $changestart $changeend)

Write-Host "The change set is: $($changeset)"

# Current credentials for testing
$pwd = Convertto-SecureString $env:PWD -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($env:USER, $pwd)
Connect-AzAccount -credential $credential -tenant $env:TENANT -serviceprincipal

Get-AzSubscription

