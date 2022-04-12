param(
    [string]$WorkingDirectory,
    [string]$DownloadConfiguration
)

## test working directory
if((Test-Path $WorkingDirectory) -eq $false) {
    Write-Error "Could not find a workingDirectory on $WorkingDirectory. Please run FirstRunConfigureODT.ps1."
    break
}

Write-Host "Found workingDirectory on $WorkingDirectory"

## getting config
$config = Get-Content $WorkingDirectory\ODTConfig.json | convertfrom-json

$site = Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117" -UseBasicParsing
$downloadLink = $site.links.where({$_.outerHTML -like "*download manually*"}).href
Write-Host "Downloading Files...."
Invoke-WebRequest -Uri $downloadLink -OutFile "$WorkingDirectory\officedeploymenttool.exe" | Out-Null
Write-Host "Downloaded DeploymentTool to $WorkingDirectory."
Write-Host "Extracting DeploymentTool..." 
$ODTProcess = Start-Process "$WorkingDirectory\officedeploymenttool" -ArgumentList "/extract:$WorkingDirectory\Extract /quiet" -Wait -ErrorAction stop -verb runas -PassThru
if($ODTProcess.ExitCode -eq 1) {
    Write-Error "An Error occured trying to extract the current ODTFile."
} else {
    Write-Host "Extracted DeploymentTool content to -> $WorkingDirectory\Extract."
}
Write-Host "Starting $WorkingDirectory\Extract\setup.exe /download with DownloadConfiguration $DownloadConfiguration ($WorkingDirectory\Configs\Download\$DownloadConfiguration.xml)"
$ODTProcess = Start-Process "$($config.LocalWorkingDirectory)\Extract\setup.exe" -ArgumentList "/download $WorkingDirectory\Configs\Download\$DownloadConfiguration.xml" -Wait -PassThru -verb runas
if($ODTProcess.ExitCode -eq 1) {
    Write-Error "An Error occured trying to download the current Install files."
} else {
    [xml]$ConfigXml = Get-content "$WorkingDirectory\Configs\Download\$DownloadConfiguration.xml"
    Write-Host "Install Files were downloaded successfully to $($ConfigXml.Configuration.Add.SourcePath)"
}
$Version = (Get-ChildItem "$($ConfigXml.Configuration.Add.SourcePath)\Office\Data" | Where-Object Attributes -eq "Directory").Name
Write-Host "Downloaded Version: $Version"