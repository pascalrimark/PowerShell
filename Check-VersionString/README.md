# Synopsis
Function to check if 2 Version Strings are lower, greater or equal
 
# DESCRIPTION
Function to check if 2 Version Strings are lower, greater or equal.
Scripts tests each block in the version string that is seperated via .-Sign.
Returns a PSCustomObject. In the property Result is the determined result of the version string check
This script only supports version strings in the format x.x.x.x.x.x and so on....

Test if a version is higher:
    if((Check-VerisonString -Verstion1 -Version2).Result -eq "Higher") -eq $true) { // do stuff } else { // do other stuff }


# PARAMETER Version1
The first version string
String Mandatory

# PARAMETER Version2
The second version string
String Mandatory

# EXAMPLE
    Check-VersionString -Version1 "6.0.51005.0" -Version2 "6.0.51119.0"
    Version1         : 6.0.51005.0
    Version2         : 6.0.51119.0
    BlockTestResults : {@{BlockPosition=0; BlockName=Block0; BlockValueVersion1=6; BlockValueVersion2=6; BlockResult=blockSame}, @{BlockPosition=1; BlockName=Block1; BlockValueVersion1=0; BlockValueVersion2=0; BlockResult=blockSame}, 
                    @{BlockPosition=2; BlockName=Block2; BlockValueVersion1=51005; BlockValueVersion2=51119; BlockResult=blockLower}, @{BlockPosition=3; BlockName=Block3; BlockValueVersion1=0; BlockValueVersion2=0; BlockResult=blockSame}}
    Result           : Lower
    Text             : Version 1 is lower than Version 2
    
    Check-VersionString -Version1 "6.0.51119.0" -Version2 "6.0.51005.0"
    Version1         : 6.0.51119.0
    Version2         : 6.0.51005.0
    BlockTestResults : {@{BlockPosition=0; BlockName=Block0; BlockValueVersion1=6; BlockValueVersion2=6; BlockResult=blockSame}, @{BlockPosition=1; BlockName=Block1; BlockValueVersion1=0; BlockValueVersion2=0; BlockResult=blockSame}, 
                    @{BlockPosition=2; BlockName=Block2; BlockValueVersion1=51119; BlockValueVersion2=51005; BlockResult=blockHigher}, @{BlockPosition=3; BlockName=Block3; BlockValueVersion1=0; BlockValueVersion2=0; BlockResult=blockSame}}
    Result           : Higher
    Text             : Version 1 is higher than Version 2

    
    Check-VersionString -Version1 "1.1.1.1" -Version2 "1.1.1.1"
    Version1         : 1.1.1.1
    Version2         : 1.1.1.1
    BlockTestResults : {@{BlockPosition=0; BlockName=Block0; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, @{BlockPosition=1; BlockName=Block1; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, 
                    @{BlockPosition=2; BlockName=Block2; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, @{BlockPosition=3; BlockName=Block3; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}}
    Result           : Equal
    Text             : Versions are equal
    
    Check-VersionString -Version1 "1.1.1.1a" -Version2 "1.1.1.1b"
    Version1         : 1.1.1.1a
    Version2         : 1.1.1.1b
    BlockTestResults : {@{BlockPosition=0; BlockName=Block0; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, @{BlockPosition=1; BlockName=Block1; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, 
                    @{BlockPosition=2; BlockName=Block2; BlockValueVersion1=1; BlockValueVersion2=1; BlockResult=blockSame}, @{BlockPosition=3; BlockName=Block3; BlockValueVersion1=1a; BlockValueVersion2=1b; BlockResult=blockLower}}
    Result           : Lower
    Text             : Version 1 is lower than Version 2