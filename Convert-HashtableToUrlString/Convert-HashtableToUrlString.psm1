function Convert-HashtableToUrlString() {
    param(
        [string]$BaseUrl,
        [Hashtable]$Hash,
        [switch]$EncodeUrl
    )

    Add-Type -AssemblyName System.Web

    $url = $baseUrl

    function NestedProp($property) {
        $pidx = 0
        foreach($p in $property.keys) {
            if($property[$p].GetType().Name -eq "String" -or $property[$p].GetType().Name -eq "Boolean") {
                $url_Frag += "$p=$($property[$p])"
                $pidx++
                if($pidx -lt $property.Keys.count) {
                    $url_Frag += "&"
                }
            } elseif($property[$p].GetType().Name -eq "Object[]") {
                $arrC = 0
                foreach($a in $property[$p]) {
                    $url_Frag += "$($p)[$arrC]=$a"
                    $arrC++
                    if($arrC -lt $property[$p].count) {
                        $url_Frag += "&"
                    }
                }
                $pidx++
                if($pidx -lt $property.Keys.count) {
                    $url_Frag += "&"
                }
            }elseif($property[$p].GetType().Name -eq "PSCustomObject") {
                $custC = 0
                foreach($cp in $property[$p].PSObject.Properties) {
                    $url_Frag += "$($cp.Name)=$($cp.Value)"
                    $custC++
                    if($custC -lt $property[$p].PSObject.Properties.Name.Count) {
                        $url_Frag += "&"
                    }
                }
                $pidx++
                if($pidx -lt $property.Keys.count) {
                    $url_Frag += "&"
                }
            } else {
                $url_Frag += NestedProp $property[$p]
                $pidx++
                if($pidx -lt $property.Keys.count) {
                    $url_Frag += "&"
                }
            }
        }
        return $url_Frag
    }

    $idx = 0
    foreach($prop in $hash.Keys) {
        if($hash[$prop].GetType().Name -eq "String" -or $hash[$prop].GetType().Name -eq "Boolean") {
            $url += "$prop=$($hash[$prop])"
            $idx++
            if($idx -lt $hash.Keys.count) {
                $url += "&"
            }
        } elseif($hash[$prop].GetType().Name -eq "Object[]") {
            $arrC = 0
            foreach($a in $hash[$prop]) {
                $url += "$($prop)[$arrC]=$a"
                $arrC++
                if($arrC -lt $hash[$prop].count) {
                    $url += "&"
                }
            }
            $idx++
            if($pidx -lt $hash.Keys.count) {
                $url += "&"
            }
        } elseif($hash[$prop].GetType().Name -eq "PSCustomObject") {
            $custC = 0
            foreach($cp in $hash[$prop].PSObject.Properties) {
                $url += "$($cp.Name)=$($cp.Value)"
                $custC++
                if($custC -lt $hash[$prop].PSObject.Properties.Name.Count) {
                    $url += "&"
                }
            }
            $idx++
            if($pidx -lt $hash.Keys.count) {
                $url += "&"
            }
        } else {
            $url += NestedProp $hash[$prop]
        }
    }
    if($EncodeUrl) {
        return [System.Web.HttpUtility]::UrlEncode($url) 
    } else {
        return $url
    }
}

