## More information https://social.technet.microsoft.com/wiki/contents/articles/962.how-to-determine-if-a-certificate-is-using-a-capi1-or-cng-key.aspx

<#
    .SYNOPSIS
    Determines if for the found certificates in the given cert location the private keys are associated with a CNG or CAPI1 key provider.
    
    .DESCRIPTION
    Determines if for the found certificates in the given cert location the private keys are associated with a CNG or CAPI1 key provider.
    
    .NOTES
    File Name : Get-CertKeyProviderType
    Author    : primark (concept+code)
    Requires  : PowerShell Version 5.1
    
    .LINK
    To provide feedback or for further assistance email:
    primark@united-internet.de
    
    .PARAMETER CertificateLocation
    DESC.
    String Mandatory
    
    .EXAMPLE
    Get-CertificateKeyProviderType.ps1 -CertificateLocation Cert:\LocalMachine\My
    
#>
[CmdletBinding()]
param(
    [string]$CertificateLocation
)
process {
    try {
        $signature = @"
[DllImport("Crypt32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool CertGetCertificateContextProperty(
    IntPtr pCertContext,
    uint dwPropId,
    IntPtr pvData,
    ref uint pcbData
);
[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct CRYPT_KEY_PROV_INFO {
    [MarshalAs(UnmanagedType.LPWStr)]
    public string pwszContainerName;
    [MarshalAs(UnmanagedType.LPWStr)]
    public string pwszProvName;
    public uint dwProvType;
    public uint dwFlags;
    public uint cProvParam;
    public IntPtr rgProvParam;
    public uint dwKeySpec;
}
"@
        Add-Type -MemberDefinition $signature -Namespace PR -Name CertTools

        $CERT_KEY_PROV_INFO_PROP_ID = 0x2 # from Wincrypt.h header file

        $returnArray = @()
        foreach($cert in Get-ChildItem $CertificateLocation) {
            # initialize variables
            $pcbData = 0

            # get buffer size that will contain provider information
            [void][PR.CertTools]::CertGetCertificateContextProperty($cert.Handle,$CERT_KEY_PROV_INFO_PROP_ID,[IntPtr]::Zero,[ref]$pcbData)

            # allocate this buffer in unmanaged memory
            $pvData = [Runtime.InteropServices.Marshal]::AllocHGlobal($pcbData)
            # call the function again to copy provider information to a pointer.
            [void][PR.CertTools]::CertGetCertificateContextProperty($cert.Handle,$CERT_KEY_PROV_INFO_PROP_ID,$pvData,[ref]$pcbData)
            # copy structure from unmanaged memory to a managed structure
            $keyProv = [Runtime.InteropServices.Marshal]::PtrToStructure($pvData,[type][PR.CertTools+CRYPT_KEY_PROV_INFO])
            # we don't need unmanaged buffer, so release it

            $return = [PSCustomObject]@{
                Certificate = $cert.SubjectName.Name
                Thumbprint = $cert.Thumbprint
                ProviderName = $keyProv.pwszProvName
                ProviderType = $keyProv.dwProvType
            }
            if($keyprov.rgProvParam -eq 0 -and $keyProv.dwKeySpec -eq 0) {
                $return | Add-Member -MemberType NoteProperty -Name "KeyType" -Value "CNG"
            } else {
                $return | Add-Member -MemberType NoteProperty -Name "KeyType" -Value "CAPI1"
            }
            $returnArray += $return
        }
        return $returnArray

    } catch {
        Write-Error $_
    }
}

