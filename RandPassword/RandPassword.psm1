function Get-RandPassword() {
    
    ## hier kommt die Synopsis hin. Das was ausgeben wird wenn man Get-Help Get-RandPassword ausführt
    <#
        .SYNOPSIS
        This script creates a random string
    
        .DESCRIPTION
        This script creates a random string

        .NOTES
        File Name : Get-RandPassword.psm1
        Author    : primark (concept+code)
        Requires  : PowerShell Version 5.1
        
        .LINK
        To provide feedback or for further assistance email:
        primark@united-internet.de

        .PARAMETER signs
        the amount of signs that should be used
        Integer Mandatory

        .PARAMETER noUpperLetters
        Defines if no upper letters should be used
        switch

        .PARAMETER noLowerLetters
        Defines if no lower letters should be used
        Switch

        .PARAMETER noSpecialSigns
        Defines if no special signs should be used
        Switch

        .PARAMETER noNumbers
        Defines if no numbers should be used
        Switch

        .PARAMETER CopyToClipboard
        Defines if the created password should be set to clipboard
        Switch
    #>

    ## Parameter, die vom Anwender angebenen werden müssen
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({ $_ -ge 1 -and $_ -le 60 })]
        [int]$Signs,
        [switch]$noUpperLetters,
        [switch]$noLowerLetters,
        [Switch]$noSpecialSigns,
        [switch]$noNumbers,
        [switch]$DoNotExcludeSimilarChars,
        [switch]$CopyToClipboard
    )
    
    ## hier werden variablen deklariert
    begin {
        ## throw if all option switchs are provided.
        if($noUpperLetters -and $noLowerLetters -and $noSpecialSigns -and $noNumbers) {
            throw "Could not create password"
            break
        }
        
        if(!$signs) {
            $signs = 12
        }

        ## create signs
        $numbers = @("0","1","2","3","4","5","6","7","8","9")
        $letters_lower = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
        $letters_upper = $letters_lower.ToUpper()
        $special_signs = @("!","$","%","&","+","?","#")

        $similarChars = @("1", "I", "i", "l", "O", "o" ,"0")
        $passwordChar = ""

        $allowedoptions = @()
        if(!$noUpperLetters) {$allowedoptions += "UpperLetters"}
        if(!$noLowerLetters) {$allowedoptions += "LowerLetters"}
        if(!$noSpecialSigns) {$allowedoptions += "SpecialSigns"}
        if(!$noNumbers) {$allowedoptions += "Numbers"}
    }

    ## hier wird der eigentliche Code definiert
    process {
        function ReturnCharacter($allowed) {
            if($allowed.Count -eq 1) {
                $randOption = 0
            } else {
                $randOption = Get-Random -Minimum 0 -Maximum $allowed.Count
            }
            Write-Verbose "Invoked option: $($allowed[$randOption])"
            switch($allowed[$randOption]) {
                "UpperLetters" {
                    $rand = Get-Random -Maximum $letters_lower.Count
                    $char = $letters_upper[$rand]
                }
                "LowerLetters" {
                    $rand = Get-Random -Maximum $letters_lower.Count
                    $char = $letters_lower[$rand]
                }
                "SpecialSigns" {
                    $rand = Get-Random -Maximum $special_signs.Count
                    $char = $special_signs[$rand]
                }
                "Numbers" {
                    $rand = Get-Random -Maximum $numbers.Count
                    $char = $numbers[$rand]
                }
            }
            return $char
        }

        ## create password
        Write-Verbose "Sign Amount: $signs"
        for($s = 1; $s -le $signs; $s++) {
            $passwordChar += ReturnCharacter $allowedoptions
        }

        ## set to clipboard if param setTocliepboard was specified
        if($CopyToClipboard) {
            $passwordChar | Set-Clipboard
        }
         
        ## return password to user
        return $passwordChar
    }

    ## hier wird aufgeräumt
    end {
        ## clear password char string
        $passwordChar = $null
    }
}