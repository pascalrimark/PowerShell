Connect-AzureAD
$Applications = Get-AzureADApplication | Select-Object *
$today = Get-Date
$appList = [System.Collections.ArrayList]::new()
foreach($App in $Applications) {
    if($App.KeyCredentials.Count -ne 0) {
        foreach($KeyCred in $App.KeyCredentials) {
            $dt = New-TimeSpan -Start $today -End $KeyCred.EndDate
            if($dt.Days -lt 30) {
                $CredentialItem = @{}
                $CredentialItem["DisplayName"] = $App.DisplayName
                $CredentialItem["ObjectId"] = $app.ObjectId
                $CredentialItem["AppId"] = $app.AppId
                $CredentialItem["Type"] = $KeyCred.Type
                $CredentialItem["Status"] = "Will Expire in the next 30 Days / Is already expired"
                $CredentialItem["EndDate"] = $KeyCred.EndDate
                $CredentialItem["KeyId"] = $KeyCred.KeyId
                $appList.add([PSCustomObject]$CredentialItem)
            }
        }
    }
}
