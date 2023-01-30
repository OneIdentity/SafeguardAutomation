# DEPRECATED
# This publisher was created for session initiated setup with Safeguard 6.12 and 6.13. Feel free to use the samples though from apps.csv



#############
### USAGE
# The script has been tested with session-initiated workflow, changes may be required for the portal-initiated workflow.
# The script uses the apps.csv file as an input, located next to the script.
# The script publishes new applications, it does not unpublish or change existing published applications with the same DisplayName.
# The script configures the necessary RDP settings that are required to make Safeguard Privileged App Auto-logon work.
# The script will use the default Launcher path, change it below if required.
# Set below the name of the collection where apps will be published to.
# An Icon must be set in CSV, you may use the safeguard.ico provided with the package as a fallback for new applications. Change the icon path in the CSV accordingly.
# User grops: If unset in CSV, the default setting will be used (all users have access). If set, groups should be separated with colon (:). Publishing will fail if a non-existent AD group is given in the CSV file, change the sample in the CSV accordingly.
# RDP properties: adjust the variable below as necessary. WARNING: if any custom RDP properties are already set, those will be overwritten.


#############
### VARIABLES
#############

$launcherPath = 'C:\Program Files\OneIdentity\RemoteApp Launcher\OI-SG-RemoteApp-Launcher.exe'
$collectionName = "QuickSessionCollection"
$customRDPProperties = @('prompt for credentials on client:i:0','disableconnectionsharing:i:1')


#############
### FUNCTIONS
#############

Function Publish-App {
    Param (
        [Parameter(Mandatory = $true)]
        [array] $app
    )
    
    $app | Format-Table | Out-String | Write-Host

    If ($app.UserGroups.Length -ne 0)
    {
        Write-Host "Publishing app with group assignment: $($app.UserGroups)"
        $groups = $app.UserGroups.Split(":")
        If ($?) {
               New-RDRemoteApp `
                   -CollectionName $collectionName `
                   -DisplayName $app.DisplayName `
                   -FilePath $launcherPath `
                   -ShowInWebAccess 1 `
                   -FolderName $app.Folder `
                   -CommandLineSetting Require `
                   -RequiredCommandLine $app.Parameters `
                   -IconPath $app.IconPath `
                   -UserGroups $groups
                If ($?) {
                    Write-Host "$($app.DisplayName) published"
                    Return "Published"
                } Else {
                    Write-Host "Publishing $($app.DisplayName) failed"
                    Return "Failed"
                }
        } Else {
            Write-Host "Can't parse usergroups of $($app.DisplayName): $($app.UserGroups). Skipping"
            Return "Skipped"
        }
    } ElseIf ($app.UserGroups.Length -eq 0) 
    {
        Write-Host "Publishing app without group assignment"
        $newapp = New-RDRemoteApp `
            -CollectionName $collectionName `
            -DisplayName $app.DisplayName `
            -FilePath $launcherPath `
            -ShowInWebAccess 1 `
            -FolderName $app.Folder `
            -CommandLineSetting Require `
            -RequiredCommandLine $app.Parameters `
            -IconPath $app.IconPath
         If ($newapp) {
            Write-Host "$($app.DisplayName) published"
            Return "Published"
        } Else {
            Write-Host "Publishing $($app.DisplayName) failed"
            Return "Failed"
        }
    } 
}
    

#############
### SCRIPT
#############

## Setting RDP properties
Write-Output "`n########################`n# SETTING RDP PROPERTIES"
Write-Output "`nCheck if required RDP properties are set.."

$rdconfig = Get-RDSessionCollectionConfiguration -CollectionName $collectionName

Write-Output "`nCurrent RDSessionCollectionConfiguration is:`n$($rdconfig.CustomRdpProperty)"
Write-Output "Required custom RDP properties are:`n$($customRDPProperties -join "`n")"
$properties=""
foreach ($property in $customRDPProperties) {
    Write-Output "`nAdding $($property) to RDP properties"
    if($properties -ne '') {
        $properties+="`n"
    }
    $properties+=$property
}
if ($properties -ne "") {
    Write-Output "`nSetting custom RDP properties:`n$($properties)"
    Write-Output "`nWARNING: IF ANY CUSTOM RDP PROPERTIES WERE SET, THOSE ARE OVERWRITTEN. CHECK THE ABOVE ORIGINAL OUTPUT AND COMPARE IT TO THE FINAL SETTINGS PRINTED"
    Set-RDSessionCollectionConfiguration -CollectionName $collectionName -CustomRDPproperty $properties 
} else {
    Write-Output "`nAll required properties are already configured, there's nothing to add"
}


## Publishing applications
Write-Output "`n#########################`n# PUBLISHING APPLICATIONS"
Write-Output "`nLauncher path: $($launcherPath)"
Write-Output "Reading apps from CSV..."
$scriptPath = $MyInvocation.MyCommand.Path
$csv = Import-Csv ($PSScriptRoot + '\apps.csv')

If (-Not $? -Or $csv.Count -eq 0) {
    Write-Output "Importing CSV failed or there are no apps in the CSV. Stopping."
    Exit
}

$apps = $csv.Count
$appsCreated = 0
$appsSkipped = 0
$appsFailed = 0

Write-Output "Publishing apps.."

foreach ($appInput in $csv) {
    Write-Output "`n$($appInput.DisplayName): check if app is already published"
    If (-Not (Get-RDRemoteApp -CollectionName $collectionName -DisplayName $appInput.DisplayName)) {
        Write-Output "Publishing $($appInput.DisplayName)"

        Switch (Publish-App $appInput)
        {
            "Published" {$appsCreated +=1}
            "Failed" {$appsFailed +=1}
            "Skipped" {$appsSkipped +=1}
        }
        
    } Else {
        Write-Output "$($appInput.DisplayName) exists. Skipping"
        $appsSkipped += 1
    }
}

## Summary
$rdconfig = Get-RDSessionCollectionConfiguration -CollectionName $collectionName
Write-Output "`n#######`n# SUMMARY  `
`nApps in CSV: $($apps)`
Apps Skipped: $($appsSkipped)`
Apps Published: $($appsCreated)`
Apps Failed to Publish: $($appsFailed)`
The RDP properties are:`n`n$($rdconfig.CustomRdpProperty)"