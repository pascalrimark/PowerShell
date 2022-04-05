try {
    $epplus = [System.Reflection.Assembly]::LoadFile("$PSScriptRoot\EPPlus.dll");
} catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to get the root configuration"
    break    
}
Export-ModuleMember -variable $epplus

function Convert-ExcelToPSObject() {
    param(
        [Parameter(Mandatory=$True)]
        [string]$File,
        [string]$WorkSheetName,
        [string[]]$IgnoreColumns,
        [switch]$ShowResultsInGridView,
        [switch]$includeIndex,
        [switch]$FirstRowIsHeader
    )

    process {
        ## Initialize a stopwatch to measure time while executing
        $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
        Write-Verbose "ScriptRoot: $PSScriptRoot"

        ## Open specified file and save it as stream 
        ## On failure throw exception and dispose stream item
        ## this will prevent that the file will be inaccessible for ever
        try {
            $stream = New-Object -TypeName System.IO.FileStream -ArgumentList $File, 'Open', 'Read', 'ReadWrite'
            Write-Verbose "Stream opened ($($stream.Name))"
        } catch {
            $stream.Dispose()
            throw "FAILED_CREATING_FILESTREAM - $($_.Exception.Message)"
        }

        ## create an ExcelPackage that contains the data from the defined excel file
        ## Also dispose the stream and clear the ExcelPackage on failure detection
        try {
            $xlspck = New-Object OfficeOpenXml.ExcelPackage
            $xlspck.Load($stream)
            Write-Verbose "Package loaded - Loaded from stream"
        } catch {
            $stream.Dispose()
            $xlspck.Stream.Close()
            $xlspck.Dispose()
            throw "FAILED_CREATING EXCELPACKAGE - $($_.Exception.Message)"
        }

        ## Try to get the default WorkSheet.
        ## The default WorkSheet is normally item 1 in the WorkSheet Array
        ## Do this only is the user hasn't defined a WorkSheetName parameter
        try {
            if([string]::IsNullOrEmpty($WorkSheetName)) {
                $Worksheet = $xlspck.Workbook.Worksheets[1]
            } else {
                $Worksheet = $xlspck.Workbook.Worksheets["$WorkSheetName"]
            }
        } catch {
            $stream.Dispose()
            $xlspck.Stream.Close()
            $xlspck.Dispose()
            throw "FAILED_OPENING_WORKSHEET($WorkSheetName) - $($_.Exception.Message)"
        }

        Write-Verbose "WorkSheet is $($Worksheet.Name)"

        ## Dimension
        ## Sometimes wrong formatted excel table return a dimension end address at F1048576
        ## You can determine this at the start of the script. This will be printed out during Write-Verbose Process.

        ## Get the start address
        $Start = $Worksheet.Dimension.Start
        Write-Verbose "Dimension StartAddress: $($Start.Address)"

        ## Get the end address
        $End = $Worksheet.Dimension.End   
        Write-Verbose "Dimension EndAddress: $($End.Address)"

        ## Define the properties result array. This will hold all determined properties.
        $properties = @()

        ## Trying to determine the properties (table headers)
        ## This will be done through each column in the worksheet from start column to End Column
        for ($c = $Start.Column; $c -le $End.Column; $c++) {

            if($FirstRowIsHeader) {
                ## Get the property at the specific column
                $pr_temp = $Worksheet.Cells[1,$c] | Where-Object {$_.Value} | Select-Object @{N='Column'; E={$c}}, Value
                if($pr_temp.Value -in $IgnoreColumns) {
                    Write-Verbose "ignore property: $($pr_temp.Value)"
                    continue
                } else { 
                    Write-Verbose "adding property: $($pr_temp.Value) @ c:$($pr_temp.Column)"
                    $properties += $pr_temp
                }
            } else {
                 $pr_temp = $Worksheet.Cells[1,$c] | Where-Object {$_.Value} | Select-Object @{N='Column'; E={$c}}
                 $pr_temp | Add-Member -MemberType NoteProperty -Name Value -Value "Property$c"
                 $properties += $pr_temp
            }
            ## Test if the found property is in the exclude Array
            ## If the value is in the ignore array continue with the next element
            ## Else add them to the properties array
        }

        ## Define an export array.
        ## This will hold all the items. 
        $export = @()

        ## Foreach row until the end row is reached
        for ($r = $Start.Row; $r -le $End.Row; $r++) {
            if($FirstRowIsHeader -and $r -eq 1) {
                continue
            } else {
                ## Creates an ordered PSCustomObject that will hold the row item
                $item = [ordered]@{}
    
                ## do this for each determined property. Since property holds the header name and column index it's easy to set the corresponding cell content.
                ## this will add the cell content with the header header name in $p.value to the specific value.
                foreach ($p in $properties) {
                    $item[$p.Value] += $Worksheet.Cells[$r,$p.column].Value
                }
                Write-Verbose "adding (properties: $($items.PSObject.Properties.Name -join ", ")), item (items: $($item.Values -join ", "))"

                ## If the parameter switch $includeindex is True, this will add the current row number as a new property into the item-row object.
                if($includeIndex) {
                    $item["Index"] = $r
                }

                ## Before the loop starts again the row-item needs to be added to defined export array.
                $export += [PSCustomObject]$item
            }
        }

        ## Dispose all streams and close ExcelPackage-object to prevent inaccessible files.
        $stream.Dispose()
        $xlspck.Stream.Close()
        $xlspck.Dispose()

        ## Just for verbose purposes
        Write-Verbose "Processed Items: $($export.Count)"
        $stopwatch.Stop()
        Write-Verbose "Elapsed Time: $($stopwatch.Elapsed)"

        ## If the parameter $ShowResultsInGridView is True, open a ogv at the end of the script execution.
        ## Alternativly this could be achived through: 
        ## $items = . C.\wsirep\general\other\Read-ExcelFileV2n.ps1 -File MyExcelFile.xlsx 
        ## $items |ogv
        if($ShowResultsInGridView) {
            $export | ogv -Title "Read-ExcelFileV2n.ps1 - $($WorkSheet.Name) @ $file"
        }

        ## This will print out the results int the console window.
        $export
    }
}
<#

    .SYNOPSIS
    Reads an Excel file and creates a PowerShell object from it. 
    This is an updated version of Read-ExcelFile Script.
 
    .DESCRIPTION
    Reads an Excel file and creates a PowerShell object from it.
    Tests have shown that the processing of individual 
    elements is much faster due to the improved method.  
    The new version allows 6 times faster processing of Excel tables into PowerShell objects.

    .NOTES
    File Name : Read-ExcelFileV2.ps1
    Author    : Pascal Rimark
    Requires  : PowerShell Version 3.0 + EPPlus.dll in Script Directory
    
    .LINK
    To provide feedback or for further assistance email:
    primark@united-internet.de

    .PARAMETER File
    Specify the file location of the excel file to import
    String

    .PARAMETER WorkSheetName
    Specify the name of the worksheet where the table to be imported is located. 
    String

    .PARAMETER IgnoreColumns
    Specify if these columns should not be imported. 
    String[]

    .PARAMETER ShowResultsInGridView
    If true the results will be shown in a grid view.
    Switch

    .EXAMPLE
    Read-ExcelFileV2n.ps1 .\MyExcel.xlsx

    .EXAMPLE
    Read-ExcelFileV2n.ps1 -File .\MyExcel.xlsx -WorkSheet "Table 2"

    .EXAMPLE
    If there is an error while importing some excel items to PowerShellObjects through this script you can determine these errors while using the -verbose-parameter.
    Read-ExcelFileV2n.ps1 -File .\MyExcel.xlsx -WorkSheet "Table 2" -Verbose

    .EXAMPLE
    Read-ExcelFileV2n.ps1 -File .\MyExcel.xlsx -WorkSheet "Table 2" -ShowResultsInGridView

    .EXAMPLE
    Read-ExcelFileV2n.ps1 -File .\MyExcel.xlsx -WorkSheet "Table 2" -IgnoreColumns "Status","Username" -ShowResultsInGridView
#>
try {
    $epplus = [System.Reflection.Assembly]::LoadFile("$PSScriptRoot\EPPlus.dll");
} catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to get the root configuration"
    break    
}
Export-ModuleMember -variable $epplus

function Convert-ExcelToPSObject() {
    param(
        [Parameter(Mandatory=$True)]
        [string]$File,
        [string]$WorkSheetName,
        [string[]]$IgnoreColumns,
        [switch]$ShowResultsInGridView,
        [switch]$includeIndex,
        [switch]$FirstRowIsHeader
    )

    process {
        ## Initialize a stopwatch to measure time while executing
        $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
        Write-Verbose "ScriptRoot: $PSScriptRoot"

        ## Open specified file and save it as stream 
        ## On failure throw exception and dispose stream item
        ## this will prevent that the file will be inaccessible for ever
        try {
            $stream = New-Object -TypeName System.IO.FileStream -ArgumentList $File, 'Open', 'Read', 'ReadWrite'
            Write-Verbose "Stream opened ($($stream.Name))"
        } catch {
            $stream.Dispose()
            throw "FAILED_CREATING_FILESTREAM - $($_.Exception.Message)"
        }

        ## create an ExcelPackage that contains the data from the defined excel file
        ## Also dispose the stream and clear the ExcelPackage on failure detection
        try {
            $xlspck = New-Object OfficeOpenXml.ExcelPackage
            $xlspck.Load($stream)
            Write-Verbose "Package loaded - Loaded from stream"
        } catch {
            $stream.Dispose()
            $xlspck.Stream.Close()
            $xlspck.Dispose()
            throw "FAILED_CREATING EXCELPACKAGE - $($_.Exception.Message)"
        }

        ## Try to get the default WorkSheet.
        ## The default WorkSheet is normally item 1 in the WorkSheet Array
        ## Do this only is the user hasn't defined a WorkSheetName parameter
        try {
            if([string]::IsNullOrEmpty($WorkSheetName)) {
                $Worksheet = $xlspck.Workbook.Worksheets[1]
            } else {
                $Worksheet = $xlspck.Workbook.Worksheets["$WorkSheetName"]
            }
        } catch {
            $stream.Dispose()
            $xlspck.Stream.Close()
            $xlspck.Dispose()
            throw "FAILED_OPENING_WORKSHEET($WorkSheetName) - $($_.Exception.Message)"
        }

        Write-Verbose "WorkSheet is $($Worksheet.Name)"

        ## Dimension
        ## Sometimes wrong formatted excel table return a dimension end address at F1048576
        ## You can determine this at the start of the script. This will be printed out during Write-Verbose Process.

        ## Get the start address
        $Start = $Worksheet.Dimension.Start
        Write-Verbose "Dimension StartAddress: $($Start.Address)"

        ## Get the end address
        $End = $Worksheet.Dimension.End   
        Write-Verbose "Dimension EndAddress: $($End.Address)"

        ## Define the properties result array. This will hold all determined properties.
        $properties = @()

        ## Trying to determine the properties (table headers)
        ## This will be done through each column in the worksheet from start column to End Column
        for ($c = $Start.Column; $c -le $End.Column; $c++) {

            if($FirstRowIsHeader) {
                ## Get the property at the specific column
                $pr_temp = $Worksheet.Cells[1,$c] | Where-Object {$_.Value} | Select-Object @{N='Column'; E={$c}}, Value
                if($pr_temp.Value -in $IgnoreColumns) {
                    Write-Verbose "ignore property: $($pr_temp.Value)"
                    continue
                } else { 
                    Write-Verbose "adding property: $($pr_temp.Value) @ c:$($pr_temp.Column)"
                    $properties += $pr_temp
                }
            } else {
                 $pr_temp = $Worksheet.Cells[1,$c] | Where-Object {$_.Value} | Select-Object @{N='Column'; E={$c}}
                 $pr_temp | Add-Member -MemberType NoteProperty -Name Value -Value "Property$c"
                 $properties += $pr_temp
            }
            ## Test if the found property is in the exclude Array
            ## If the value is in the ignore array continue with the next element
            ## Else add them to the properties array
        }

        ## Define an export array.
        ## This will hold all the items. 
        $export = @()

        ## Foreach row until the end row is reached
        for ($r = $Start.Row; $r -le $End.Row; $r++) {
            if($FirstRowIsHeader -and $r -eq 1) {
                continue
            } else {
                ## Creates an ordered PSCustomObject that will hold the row item
                $item = [ordered]@{}
    
                ## do this for each determined property. Since property holds the header name and column index it's easy to set the corresponding cell content.
                ## this will add the cell content with the header header name in $p.value to the specific value.
                foreach ($p in $properties) {
                    $item[$p.Value] += $Worksheet.Cells[$r,$p.column].Value
                }
                Write-Verbose "adding (properties: $($items.PSObject.Properties.Name -join ", ")), item (items: $($item.Values -join ", "))"

                ## If the parameter switch $includeindex is True, this will add the current row number as a new property into the item-row object.
                if($includeIndex) {
                    $item["Index"] = $r
                }

                ## Before the loop starts again the row-item needs to be added to defined export array.
                $export += [PSCustomObject]$item
            }
        }

        ## Dispose all streams and close ExcelPackage-object to prevent inaccessible files.
        $stream.Dispose()
        $xlspck.Stream.Close()
        $xlspck.Dispose()

        ## Just for verbose purposes
        Write-Verbose "Processed Items: $($export.Count)"
        $stopwatch.Stop()
        Write-Verbose "Elapsed Time: $($stopwatch.Elapsed)"

        ## If the parameter $ShowResultsInGridView is True, open a ogv at the end of the script execution.
        ## Alternativly this could be achived through: 
        ## $items = . C.\wsirep\general\other\Read-ExcelFileV2n.ps1 -File MyExcelFile.xlsx 
        ## $items |ogv
        if($ShowResultsInGridView) {
            $export | ogv -Title "Read-ExcelFileV2n.ps1 - $($WorkSheet.Name) @ $file"
        }

        ## This will print out the results int the console window.
        $export
    }
}
Export-ModuleMember -function Convert-ExcelToPSObject