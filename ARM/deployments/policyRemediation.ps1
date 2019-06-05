# Remediate all non-compliant policies

$nonCompliant = Get-AzPolicyState | Where-Object {$_.IsCompliant -like "False" -and $_.PolicyDefinitionAction -like "deployIfNotExists"}

foreach ($non in $nonCompliant)
    {
        Start-AzPolicyRemediation -Name (get-random) -PolicyAssignmentId $non.PolicyAssignmentId -Verbose
    }