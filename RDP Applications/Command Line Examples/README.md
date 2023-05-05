# Command Line Examples

This folder exists to store sample example command lines that have been tested and known to work on various versions of Safeguard.  The example command lines use some of the resources also found in this repository, such as [AutoIt scripts](https://github.com/OneIdentity/SafeguardAutomation/tree/master/RDP%20Applications/AutoIt) and [web browser automation code](https://github.com/OneIdentity/SafeguardAutomation/tree/master/RDP%20Applications/Go%20chromedp) written in Go.

The `Set-IconsForRdpApps.ps1` script may be used to set the icon for the published application on the jump host.  There are some sample icons in the [Icons](Icons) folder.

```
NAME
    C:\source\OneIdentity\SafeguardAutomation\RDP Applications\Command Line Examples\Set-IconsForRdpApps.ps1

SYNOPSIS
    Set icon for published RDP application.


SYNTAX
    C:\source\OneIdentity\SafeguardAutomation\RDP Applications\Command Line Examples\Set-IconsForRdpApps.ps1
    [-Collection] <String> [-DisplayName] <String> [-IconPath] <String> [<CommonParameters>]


DESCRIPTION
    Get the published RDP application by collection and display name and set the specified
    icon path.


PARAMETERS
    -Collection <String>
        A string containing the name of the collection as shown in Server Manager.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -DisplayName <String>
        A string containing the display name of the RDP application as shown in Server Manager.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -IconPath <String>
        A string containing the path to an icon file.

        Required?                    true
        Position?                    3
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).
```
