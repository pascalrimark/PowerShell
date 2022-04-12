<#
    .SYNOPSIS
	   converts a managed domain into a federated domain and vice versa
		
	.DESCRIPTION
       A managed domain is a domain that supports PHS sign in. However if PHS was enabled and the domains should be reconfigured for ADFS, the domain needs to be converted.

    .NOTES
        File Name : SwapMsolDomainAuthentication.ps1
        Author    : Pascal Rimark
        Requires  : PowerShell Version 5.0

    .Example 
        If setting from managed PHS to federated ADFS run:
        SwapMsolDomainAuthentication.ps1 -Mode Federated

        If setting from federated to managed for PHS run:
        SwapMsolDomainAuthentication.ps1 -Mode Managed
#>


##############################################
## Run in PowerShell on primary ADFS Server
##############################################

param(
    [Parameter(Mandatory=$True)]
    [ValidateSet("Federated","Managed")]
    [string]$Mode
)

Connect-MsolService

Write-Host "Getting domains"
$domains = Get-MsolDomain | Where-Object {$_.Name -notlike "*onmicrosoft.com"}
Write-Host "Got $($domains.count) domains"

foreach($domain in $domains) {
    try {
        $approve = Read-Host "Set $($domain.Name) to $($mode)? (Y|N)"
        if($approve -eq "Y" -or $approve -eq "y") {
             switch($mode) {
                "Federated" {
                    Convert-MsolDomainToFederated -SupportMultipleDomain -DomainName $domain.Name
                }
                "Managed" {
                    Set-MsolDomainAuthentication -DomainName $domain.name -Authentication Managed
                }
            }
            Write-Host "Authentication for domain $($domain.Name) was set to $mode" -ForegroundColor Green
        } else {
            Write-Host "User canceled operation" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "something failed trying to update domain authentication - $($_.Exception.Message)"
    }
}