### Get assigned AzureAD service Pincipal Policies that were assigned via Add-AzureADServicePrincipalPolicy

Connect-AzureAD
$resultList = [System.Collections.ArrayList]::new()
$sps = Get-AzureADServicePrincipal -All $true
foreach($sp in $sps) {
    $policy = Get-AzureADServicePrincipalPolicy -Id $sp.ObjectId | select *
    if($policy -ne $null) {
        $item = @{}
        $item["SPId"] = $sp.ObjectId
        $item["SPName"] = $sp.DisplayName
        $item["SPPolicyId"] = $policy.id
        $item["SPPolicyDisplayName"] = $policy.DisplayName
        $item["SPPolicyIsOrganizationDefault"] = $policy.IsOrganizationDefault
        $item["SPPolicyType"] = $policy.Type
        $item["SPPolicyDefinition"] = $policy.Definition
        Write-Host "Added $($sp.ObjectId) ($($sp.DisplayName))"
        $resultList.add([PScustomObject]$item) | out-null
    }
}    
return $resultList | fl
