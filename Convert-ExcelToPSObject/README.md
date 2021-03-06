# SYNOPSIS
    Reads an Excel file and creates a PowerShell object from it. 
    This is an updated version of Read-ExcelFile Script.
 
# DESCRIPTION
    Reads an Excel file and creates a PowerShell object from it.
    Tests have shown that the processing of individual 
    elements is much faster due to the improved method.  
    The new version allows 6 times faster processing of Excel tables into PowerShell objects.

    This SCript uses EPPlus.dll --> https://www.nuget.org/packages/EPPlus/

# PARAMETER File
    Specify the file location of the excel file to import
    String

# PARAMETER WorkSheetName
    Specify the name of the worksheet where the table to be imported is located. 
    String

# PARAMETER IgnoreColumns
    Specify if these columns should not be imported. 
    String[]

# PARAMETER ShowResultsInGridView
    If true the results will be shown in a grid view.
    Switch

# EXAMPLE
    ## import module
    import-module PATH-TO-MODULEFILE\Convert-ExcelToPSobject.psm1
    Convert-ExcelToPSObject .\MyExcel.xlsx

    Convert-ExcelToPSObject -File .\MyExcel.xlsx -WorkSheet "Table 2" -FirstRowIsHeader

    #If there is an error while importing some excel items to PowerShellObjects through this script you can determine these errors while using the -verbose-parameter.
    Convert-ExcelToPSObject -File .\MyExcel.xlsx -WorkSheet "Table 2" -FirstRowIsHeader -Verbose

    Convert-ExcelToPSObject -File .\MyExcel.xlsx -WorkSheet "Table 2" -FirstRowIsHeader -ShowResultsInGridView

    Convert-ExcelToPSObject -File .\MyExcel.xlsx -WorkSheet "Table 2" -FirstRowIsHeader -IgnoreColumns "Status","Username" -ShowResultsInGridView