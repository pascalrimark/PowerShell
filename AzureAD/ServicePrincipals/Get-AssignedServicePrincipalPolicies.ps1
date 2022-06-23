Connect-AzureAD
$resultList = [System.Collections.ArrayList]::new()
$sps = Get-AzureADServicePrincipal -All $true
foreach($sp in $sps) {
    $policies = Get-AzureADServicePrincipalPolicy -Id $sp.ObjectId | Select-Object *
    if($policies.Count -ne 0) {
        Write-Host "Adding $($sp.ObjectId) ($($sp.DisplayName)) found Policy for this ServicePrincipal"
        $item = @{}
        $item["SPId"] = $sp.ObjectId
        $item["SPName"] = $sp.DisplayName
        $policyCollection = [System.Collections.ArrayList]::new()
        foreach($p in $policies) {
            $policyItem = @{}
            $policyItem["SPPolicyId"] = $p.id
            $policyItem["SPPolicyDisplayName"] = $p.DisplayName
            $policyItem["SPPolicyIsOrganizationDefault"] = $p.IsOrganizationDefault
            $policyItem["SPPolicyType"] = $p.Type
            $policyItem["SPPolicyDefinition"] = $p.Definition
            Write-Host "Adding policy $($p.id) ($($p.DisplayName)) for ServicePrincipal $($sp.ObjectId)"
            $policyCollection.add([PScustomObject]$policyItem) | out-null
        }
        $item["AssignedPolicies"] = $policyCollection
        $resultList.add([PScustomObject]$item) | out-null
    }
}    
return $resultList | Format-List

<#
Result:

PS C:\WINDOWS> $resultList | fl

SPName           : Airwatch
AssignedPolicies : {@{SPPolicyDefinition=; SPPolicyType=; SPPolicyIsOrganizationDefault=; SPPolicyDisplayName=; SPPolicyId=}, @{SPPolicyDefinition=System.Collections.Generic.List`1[System.String]; SPPolicyType=TokenIssuancePolicy; 
                   SPPolicyIsOrganizationDefault=False; SPPolicyDisplayName=TokenIssuancePolicy; SPPolicyId=755f199e-ed23-489a-ad98-6c263277fa62}}
SPId             : 33119c1f-a625-47c9-a0f2-a9d04bb93f99

#>
