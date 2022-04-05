function Check-VersionString() {
    param(
        [parameter(Mandatory=$true)]
        [string]$Version1,
        [parameter(Mandatory=$true)]
        [string]$Version2,
        [switch]$showFullBlockResults
    )
    
#region main
    
    ## Blocks contains the block section test results
    $blocks = @()

    ## regex the version blocks
    $rx = [regex]::matches($version1, "([A-Za-z0-9]{1,})")
    $rx2 = [regex]::matches($version2, "([A-Za-z0-9]{1,})")
    
    ## foreach match create a new check-Item with properties
    for($i = 0; $i -lt $rx.Count; $i++) {
        
        ## check object holds the performed check for the current block
        $check = New-Object -TypeName psobject
        $check | Add-Member -MemberType NoteProperty -Name BlockPosition -Value $i
        $check | Add-Member -MemberType NoteProperty -Name BlockName -Value Block$i
        $check | Add-Member -MemberType NoteProperty -Name BlockValueVersion1 -Value $rx[$i].Value 
        $check | Add-Member -MemberType NoteProperty -Name BlockValueVersion2 -Value $rx2[$i].Value 
        
        ## check if the value from regex expression 1 value to the coresponding regex expression 2 value
        if($rx[$i].Value -lt $rx2[$i].Value) {
            $check | Add-Member -MemberType NoteProperty -Name BlockResult -Value "blockLower"
        } elseif($rx[$i].Value -gt $rx2[$i].Value) {
            $check | Add-Member -MemberType NoteProperty -Name BlockResult -Value "blockHigher"
        } else {
            $check | Add-Member -MemberType NoteProperty -Name BlockResult -Value "blockSame"
        }

        ## append the check object to the block array
        $blocks += $check
    }

    ## creates a new ordered hashtable with some properties
    $VersionCheck = [ordered]@{}
    $VersionCheck["Version1"] = $version1
    $VersionCheck["Version2"] = $version2

    ## the return value contains also the blocks array with the results from the tested block section
    $versionCheck["BlockTestResults"] = $blocks
    
    ## check each tested block section. This goes in the version string from left to right
    foreach($b in $blocks) {
        ## if there is any value higher than the corresponding value -> return immediately since the string is higher // 1.2.0 -> 1.1.0 return Higher since 1.2 is higher than 1.1
        if($b.BlockResult -eq "blockHigher") {
            $VersionCheck["Result"] = "Higher"
            $VersionCheck["Text"] = "Version 1 is higher than Version 2"
            if(!$showFullBlockResults) {
                return $VersionCheck["Result"]
            } else {
                return [PSCustomObject]$VersionCheck
            }
        }
        if($b.BlockResult -eq "blockLower") {
            $VersionCheck["Result"] = "Lower"
            $VersionCheck["Text"] = "Version 1 is lower than Version 2"
            if(!$showFullBlockResults) {
                return $VersionCheck["Result"]
            } else {
                return [PSCustomObject]$VersionCheck
            }
        }
        if($b.BlockResult -eq "blockSame") {
            $VersionCheck["Result"] = "Equal"
            $VersionCheck["Text"] = "Versions are equal"
        }
    }
    return [PSCustomObject]$VersionCheck
}
#endregion main