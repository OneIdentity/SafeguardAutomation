$collection = "OIDEMO collection"
$appdsiplayname = "RemoteApp Program Name as shown in Server Manager"

# For standard application use the icon file in Program Files, for example:
# C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\ssms.ico
$iconpath = "C:\SafeguardAutomation\RemoteApp Samples\icons\icon.ico"

$app = get-rdremoteapp -CollectionName $collection -DisplayName $appdsiplayname
$app
$app.Alias
Set-RDRemoteApp -CollectionName $collection -Alias $app.Alias -IconPath $iconpath
