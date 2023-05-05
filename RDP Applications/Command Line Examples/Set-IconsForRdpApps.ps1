<#
.SYNOPSIS
Set icon for published RDP application.

.DESCRIPTION
Get the published RDP application by collection and display name and set the specified
icon path.

.PARAMETER Collection
A string containing the name of the collection as shown in Server Manager.

.PARAMETER DisplayName
A string containing the display name of the RDP application as shown in Server Manager.

.PARAMETER IconPath
A string containing the path to an icon file.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true ,Position = 0)]
    [string]$Collection,
    [Parameter(Mandatory=$true ,Position = 1)]
    [string]$DisplayName,
    [Parameter(Mandatory=$true ,Position = 2)]
    [string]$IconPath
)

$local:App = (Get-RDRemoteApp -CollectionName $Collection -DisplayName $DisplayName)
$local:App
$local:App.Alias
Set-RDRemoteApp -CollectionName $Collection -Alias $app.Alias -IconPath $IconPath
