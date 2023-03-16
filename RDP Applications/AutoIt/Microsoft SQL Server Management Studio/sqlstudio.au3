; ONLY FOR DEMO USE
; Based on the OI SQL Developer launcher:
;   https://github.com/OneIdentity/SafeguardAutomation/blob/master/AutoIt/SQLDeveloper/SQLDeveloper_20.4.1.au3
; cmd line arguments for lacunher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\sqlstudio.exe --args {username} {password} {asset}

Global $apppath = ""
Global $appfolder = ""
Global $account = $CmdLine[1]
Global $password = $CmdLine[2]
Global $asset = $CmdLine[3]

$apppath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
$appfolder = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE"

Global $loginwintitle = "Connect to Server"

Start($apppath, $appfolder)
Login($asset, $account, $password)

Func Login($asst, $acct, $passwd)
  ; Wait for login window and get window handle when ready.
  Local $handle = WinWaitActive($loginwintitle)

  ; Disable the options and help buttons
  ControlDisable($handle, "", "[NAME:help]")
  ControlDisable($handle, "", "[NAME:options]")

  ; Disable control and set server type
  ControlDisable($handle, "", "[NAME:comboBoxServerType]")
  ControlSend($handle, "", "[NAME:comboBoxAuthentication]", "SelectString", "Database Engine")

  ; Disable control and set authentication to SQL
  ControlDisable($handle, "", "[NAME:comboBoxAuthentication]")
  ControlSend($handle, "", "[NAME:comboBoxAuthentication]", "SelectString", "SQL Server Authentication")

  ; Hide save password option
  ControlHide($handle, "", "[NAME:savePassword]")

  ; Disable control and set servername
  ControlDisable($handle, "", "[NAME:serverInstance]")
  ControlSetText($handle, "", "[NAME:serverInstance]", $asset)

  ; Disable control and set username
  ControlDisable($handle, "", "[NAME:userName]")
  ControlSetText($handle, "", "[NAME:userName]", $account)

  ; Disable control and set password
  ControlDisable($handle, "", "[NAME:password]")
  ControlSetText($handle, "", "[NAME:password]", $password)

  ; Connect
  ControlClick($handle, "", "[NAME:connect]")
EndFunc

Func Start($path, $folder)
	Run($path, $folder, @SW_MAXIMIZE)
EndFunc