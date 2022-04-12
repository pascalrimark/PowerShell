$WorkingDirectory = Read-Host "Specifiy the path to the working directory (e.g. C:\ODT)"
$UseProxyServer = Read-Host "Use a Proxy Server for outbound connection (tpye in http://proxy:port or leave blank)"
$MailNotify = Read-Host "Receive mail notifications if a new version was downloaded (Y|N)"
if($EmailNotify -eq "Y") {
    $MailSender = Read-Host "Type in the sender mail address"
    $MailHost = Read-Host "Type in the mail host"
    $MailReceiver = Read-Host "Type in the mail receiver"
}

## testing folders
try {
    if((Test-Path $WorkingDirectory) -eq $false) {
        New-Item -Path $WorkingDirectory -ItemType Directory | Out-Null
        Write-verbose "Created folder: $WorkingDirectory"
    }
    if((Test-Path "$WorkingDirectory\Config") -eq $false) {
        New-Item -Path "$WorkingDirectory\Config" -ItemType Directory | Out-Null
        Write-verbose "Created folder: $WorkingDirectory\Config"
    }
    if((Test-Path "$WorkingDirectory\Config\Download") -eq $false) {
        New-Item -Path "$WorkingDirectory\Config\Download" -ItemType Directory | Out-Null
        Write-verbose "Created folder: $WorkingDirectory\Config\Download"
    }
    if((Test-Path "$WorkingDirectory\Config\Install") -eq $false) {
        New-Item -Path "$WorkingDirectory\Config\Install" -ItemType Directory | Out-Null
        Write-verbose "Created folder: $WorkingDirectory\Config\Install"
    }
    if((Test-Path "$WorkingDirectory\Extract") -eq $false) {
        New-Item -Path "$WorkingDirectory\Extract" -ItemType Directory | Out-Null
        Write-verbose "Created folder: $WorkingDirectory\Extract"
    }
} catch {
    throw "Failed to test ODTFolders (Test-ODTFolders) $_"
}

## receiving current defaults
Write-Host "Getting defualt download config xml from https://raw.githubusercontent.com/pascalrimark/PowerShell/main/ODT/Defaults/Download-O365-32Bit.xml"
Invoke-WebRequest "https://raw.githubusercontent.com/pascalrimark/PowerShell/main/ODT/Defaults/Download-O365-32Bit.xml" -OutFile $WorkingDirectory\Config\Download\Download-O365-32Bit.xml
Write-Host "Getting defualt download config xml from https://raw.githubusercontent.com/pascalrimark/PowerShell/main/ODT/Defaults/Download-O365-64Bit.xml"
Invoke-WebRequest "https://raw.githubusercontent.com/pascalrimark/PowerShell/main/ODT/Defaults/Download-O365-64Bit.xml" -OutFile $WorkingDirectory\Config\Download\Download-O365-64Bit.xml

## WRiting config file
if($MailNotify -eq "Y") {$MailNotify = $true} else {$MailNotify = $false}
$config = @{
    WorkingDirectory = $WorkingDirectory
    UseProxyServer = $UseProxyServer
    MailNotify = $MailNotify
    MailSender = $MailSender
    MailHost = $MailHost
    MailReceiver = $MailReceiver
}
$config | convertto-json -Depth 10 | out-file $WorkingDirectory\ODTConfig.json

Write-Host "Created WorkingFolder at $WorkingDirectory"
Write-Host "Saved config to $WorkingDirectory"
Write-Host ""
Write-Host "------------------------------"
Write-Host "-- Further Steps"
Write-Host "------------------------------"
Write-Host "1. Modify the download configuration under $WorkingDirectory\Config\Download "
Write-Host "2. Modify the install configuration under $WorkingDirectory\Config\Install"
Write-Host "3. Run PublishODTInstallFiles.ps1 to download the newest odtdeploymentsetup file and extract the setup.exe"
Write-Host "4. Run InstallODTFilesOnTarget for installing Office365 on a remote machine."