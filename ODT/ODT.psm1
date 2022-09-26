$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Foreach($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

try {
    $Config = Import-PowerShellDataFile -Path "$($PSScriptRoot)\ODTConfig.psd1"
} catch {
    throw "$_ - Failed getting ODTConfig file. Expected that the file is located at $PSScriptRoot\ODTConfig.psd1."
    break
}

$configPath = "$($PSScriptRoot)\ODTConfig.psd1"
Export-ModuleMember -Variable $Config
Export-ModuleMember -Variable $ConfigPath

foreach($func in $Public.Basename) {
    Export-ModuleMember -Function $func
}