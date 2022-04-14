# SPF Resolver

## What is it
This scirpt provides a WPF Gui that resolves SPF entries in a domains TXT Record. The records will be recursivly resolved. Meaning the script will check until a SPF entry was found that starts not with include:

SPF Entries define if a host can send mails on behalf of the domain in which the entry is added.

![SPF](https://github.com/pascalrimark/PowerShell/blob/main/Mail/SPFResolver/Images/SPF.png?raw=true)

If a /xx is behind the ip4 entry this means, that all ips within the net can send mails on behalf of the domain.

For Example:
A host within the ip range 157.55.0.192/26 e.g. 157.55.0.193 can send mails on behalf of the domain outlook.de.

![SPFResolver](https://github.com/pascalrimark/PowerShell/blob/main/Mail/SPFResolver/Images/SPFResolver.png?raw=true)
## How to use
Download the PowerShell Script SPFResolver.ps1 to your desired destination and run the script via


    PATH-TO-THE-SCRIPT\SPFResolver.ps1

You can even submit parameters while starting via powershell

    PATH-TO-THE-SCRIPT\SPFResolver.ps1 -Domain packservice.com -expandResults

This will start the SPFResolver Script directly with the domain outlook.de and the results in the treeview will be directly expanded.

Otherwise you can rightclick on the script and select "run with Powershell" and type the requested domain by yourself