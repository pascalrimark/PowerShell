
function Export-PowerShellDataFile() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Hashtable]$DataObject, 
        [Parameter(Mandatory = $true)]
        [string]$outPath
    )
    function Writer($string, $indent) {
        Write-verbose "writing $string to $outPath with indent level: $indent"
        if($indent -eq 0) {
            return $string | Out-File $outPath -Append
        } else {
            return "{0,$($indent *4)}{1}" -f "", $string | Out-File $outPath -Append
        }
    }
    function Check($object, $indentLevel) {
        $level = 1
        foreach($obj in $Object.Keys) {
            if($indentLevel) {
                $level = $indentLevel
            }
            ## get the type of the object
            switch -Regex ($Object[$obj].GetType().Name) {
                default {
                    Writer -string "$obj = `"$($Object[$obj])`"" -indent $level
                }
                "Hashtable" {
                    Writer -string "$obj = @{" -indent $level
                    Check -object $Object[$obj] -indentLevel $($level+1)
                    Writer -string "}" -indent $level
                }
                "Object\[\]" {
                    Writer -string "$obj = @(" -indent $level
                    $a_count = 1
                    foreach($a in $Object[$obj]) {
                         if($a_count -lt $Object[$obj].Count) {
                            Writer -string "`"$($a)`"," -indent $($level+1)
                         } else {
                            Writer -string "`"$($a)`"" -indent $($level+1)
                         }
                         $a_count++
                    }
                    Writer -string ")" -indent $level
                }
                "Boolean" {
                   Writer -string "$obj = `$$($Object[$obj])" -indent $level
                }
                "Int\d{2}" {
                   Writer -string "$obj = $($Object[$obj])" -indent $level 
                }
            }
            $level = 1
        }
    }
    ##test input object
    if($DataObject.GetType().Name -ne "Hashtable") {
        Write-Error "The input type was not a hashtable." -Category InvalidData
        break
    }
    Write-Warning "Export-PowershellDataFile will remove any comments"
    if(Test-Path $outPath) {
        Remove-Item $outPath -Force
    }
    Writer -string "@{" -indent 0
    Check -Object $DataObject
    Writer -string "}" -indent 0
}