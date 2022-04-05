#Have you ever wondered shy there is no Export-PowerShellDataFile while there is Import-PowershellDataFile.

I personally use a PowerShell data file very often to manage settings on scripts externally. This way I don't always have to customize the script.
Especially with complex scripts I like to use these files to not have to specify unnecessary many parameters.

However, there is no Microsoft Export-PowershellDataFile cmdlet to write an imported hashtable back into the resulting file.
For this I use my self written module Export-PowershellDataFile.

#Usage
    import-module PATH-TO-MODULEFILE\Export-PowerShellDataFile.psm1
    
    ## import the psd1 file as hashtable
    $DataObject = Import-PowerShellDataFile "C:\users\primark\desktop\config.psd1"

    ## change properties
    $DataObject.UserSyncSettings.SyncEnabled = $false
    $DataObject.answer = 60
    $DataObject.more.more.again.thisisgettingridiculous.here = 50

    ## export the hashtable
    Export-PowerShellDataFile -DataObject $DataObject -outPath "C:\users\primark\Desktop\config.psd1" -Verbose
    Export-PowerShellDataFile -DataObject $DataObject.Answer -outPath "C:\users\primark\Desktop\config.psd1" -Verbose

    # or via pipeline
    $DataObject | Export-PowerShellDataFile -outPath "C:\users\primark\Desktop\config.psd1" -Verbose
