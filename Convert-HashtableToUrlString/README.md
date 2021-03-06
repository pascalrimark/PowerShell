
# SYNOPSIS
Converts a given Hashtable to a url String

    Einfache Json Hashtable
    $jsonPayload = @{
        GivenName = "Pascal"
        SurName = "Rimark"
        LanguageArray = @("C#", "Powershell", "Python")
    }
    Convert-HashtableToUrlString -baseUrl "http://host:post/api?" -hash $jsonPayload -EncodeUrl
    Ausgabe: http://host:post/api?LanguageArray[0]=C#&LanguageArray[1]=Powershell&LanguageArray[2]=Python&GivenName=Pascal&SurName=Rimark&
    Ausgabe Encoded: http%3a%2f%2fhost%3apost%2fapi%3fLanguageArray%5b0%5d%3dC%23%26LanguageArray%5b1%5d%3dPowershell%26LanguageArray%5b2%5d%3dPython%26GivenName%3dPascal%26SurName%3dRimark

    Komplexe Json Hashtable
    $jsonPayload2 = @{
        wert1 = "val1"
        wert2 = "val2"
        nested = @{
            nestval = "wer"
            morenested = @{
                nestprop1 = "hallo"
                nestprop2 = "again"
                evenNastier = @{
                    lowest = $true
                    Text = "Könnte ewig so weiter machen"
                    DeepestArray = @(1,0,2,1,3,2)
                }
            }
        }
    }
    Convert-HashtableToUrlString -baseUrl "http://host:post/api?" -hash $jsonPayload2
    Ausgabe: http://host:post/api?wert2=val2&wert1=val1&DeepestArray[0]=1&DeepestArray[1]=0&DeepestArray[2]=2&DeepestArray[3]=1&DeepestArray[4]=3&DeepestArray[5]=2&lowest=True&Text=Könnte ewig so weiter machen&nestprop1=hallo&nestprop2=again&nestval=wer

# Usage
    # import module
    import-module PATH-TO-MODULEFILE\Convert-HashtableToUrlString.psm1
    # Auch mit PSCustomObjects (Objekte müssen mit Select direkt gepipet werden)
    $ADUser = get-aduser primark | select displayName, SamAccountName, UserPrincipalName
    $jsonPayload3 = @{
        ADUser = $ADuser
    }

    Convert-HashtableToUrlString -baseUrl "http://host:post/api?" -hash $jsonPayload3
    Ausgabe: http://host:post/api?displayName=&SamAccountName=primark&UserPrincipalName=primark@united-internet.de