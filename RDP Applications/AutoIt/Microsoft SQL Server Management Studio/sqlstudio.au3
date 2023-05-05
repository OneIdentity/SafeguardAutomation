; ONLY FOR DEMO USE
; Initial version based on the OI SQL Developer launcher:
;   https://github.com/OneIdentity/SafeguardAutomation/blob/master/AutoIt/SQLDeveloper/SQLDeveloper_20.4.1.au3
; Safeguard Launcher Application Command Line parameters: --cmd <path>\sqlstudio.exe --args <environment variable for SSMS folder path> {username} {password} {asset} [sps ip]
; Tested with SSMS v18.4: --cmd "<path>\sqlstudio.exe" --args ssmsfolder {username} {password} {asset} 192.168.1.1
; Make sure you configure the environment variable on the RDS host, for example C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE

#include <MsgBoxConstants.au3>
#include <Date.au3>

Global $debug = $CmdLine[1]
Global $ssms_folder_env_var = $CmdLine[2]
Global $account = $CmdLine[3]
Global $password = $CmdLine[4]
Global $asset = $CmdLine[5]
If $CmdLine[0] = 6 Then
	Global $sps = $CmdLine[6]
Else
	Global $sps = ""
EndIf

Global $loglevel = ''
If $debug Then
	$loglevel = 'debug'
Else
	$loglevel = 'info'
EndIf
$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\sqlstudio.log", $FO_APPEND + $FO_CREATEPATH)

Global $ssms_folder = EnvGet($ssms_folder_env_var)
Global $apppath = $ssms_folder & "\Ssms.exe"
Global $appfolder = $ssms_folder
Global $loginwintitle = "Connect to Server"

; Define server and login values for direct connection or via SPS
If $sps = "" Then
	Global $serverName = $asset
	Global $login = $account
Else
	Global $serverName = $sps
	Global $login = $account & "%" & $asset
EndIf

Logger('debug', "appath: " & $apppath)
Logger('debug', "appfolder: " & $appfolder)
Logger('debug', "serverName: " & $serverName)
Logger('debug', "login: " & $login)

Start($apppath, $appfolder)
Login($serverName, $login, $password)

Func Login($serverInstance, $userName, $passwd)
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
  ControlSetText($handle, "", "[NAME:serverInstance]", $serverInstance)

  ; Disable control and set username
  ControlDisable($handle, "", "[NAME:userName]")
  ControlSetText($handle, "", "[NAME:userName]", $userName)

  ; Disable control and set password
  ControlDisable($handle, "", "[NAME:password]")
  ControlSetText($handle, "", "[NAME:password]", $password)

  ; Connect
  ControlClick($handle, "", "[NAME:connect]")
EndFunc

Func Start($path, $folder)
	Run($path, $folder, @SW_MAXIMIZE)
EndFunc

Func Logger($level, $msg)
	$ts = _NowCalc()
	if $level == "debug" And $debug = 1 Then
		FileWriteLine($logfile, $ts & " -- " & $msg)
	ElseIf $level == "info" Then
		FileWriteLine($logfile, $ts & " -- " & $msg)
	EndIf
EndFunc