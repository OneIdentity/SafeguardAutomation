; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are added too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_Okta.exe --args "<debug=0|1> <target> {username} {password} {asset}"
;
;
; Input parameters:
;  username
;  password
;  asset - Not required by the code however the Launcher requires its presence in its argument list.
;  target - Without https:// and including custom :port if required. Note: This is not the asset name information as stored in SPP.
;
; Input is blocked until OTP input field is shown


Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 0)

#include <MsgBoxConstants.au3>
#include <Date.au3>

#include 'webdriver\wd_core.au3'
#include 'webdriver\wd_helper.au3'

#include "webdriver\BlockInputEX.au3"

Local $debug = $CmdLine[1]
Local $target = $CmdLine[2]
Local $username = $CmdLine[3]
Local $password = $CmdLine[4]
; Asset will not be used as cloud targets may be accessible on a different name than the Asset Name / Network Address in SPP, however the {asset} parameter must be given for the Launcher.
Local $asset = $CmdLine[5]

Local $username_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[3]/div[1]/div[2]/span/input"
Local $next_button_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
Local $password_select_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/div/div[3]/div[2]/div[2]/a"
Local $password_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[4]/div/div[2]/span/input"
Local $login_button_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
Local $otp_select_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/div/div[1]/div[2]/div[2]/a"
;Local $otp_input_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[4]/div/div[2]/span/input"
;Local $otp_verify = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
;LocaL $otp_seed = ""

$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\web_Okta.log", $FO_APPEND + $FO_CREATEPATH)
Logger('info', "Starting web orchestration with debug logging:" & $debug)
Logger('debug', "Received " & $CmdLine[0] & " attributes: " & $CmdLineRaw)
Logger('debug', "debug= " & $debug)
Logger('debug', "username= " & $username)
Logger('debug', "password= " & "*")
Logger('debug', "asset= " & $asset)
Logger('debug', "target= " & $target)

Local $sDesiredCapabilities, $sSession

; We use Chrome in this sample. For other browsers lookup the functions at the end of the script.
; Note: Make sure chromedriver is up-to-date. Chrome is updating frequently, chromedriver should have the matching version.
SetupChrome()

; Disable user input
_BlockInput($BI_DISABLE)
Logger('debug', 'User input disabled')

_WD_Startup()

; Create session
Logger('debug', 'Creating session with capabilities: ' & $sDesiredCapabilities)
While $_WD_HTTPRESULT <> 200
	$sSession = _WD_CreateSession($sDesiredCapabilities)
	Logger('debug', 'HTTPRESULT: ' & $_WD_HTTPRESULT)
WEnd
Logger('debug', 'Session: ' & $sSession)

; Hide the WebDriver console
_WD_ConsoleVisible(false)

; Navigate to asset website
$url= 'https://' & $target
_WD_Navigate($sSession,  $url)
Logger('debug', 'Navigate HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the username field
$userField = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$username_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate userField HTTPRESULT: ' & $_WD_HTTPRESULT)

; Enter value into the username field
_WD_ElementAction($sSession, $userField, 'value', $username)
Logger('debug', 'Entering username HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the next button
$nextButton = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$next_button_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate nextButton HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the next button
_WD_ElementAction($sSession, $nextButton, 'click')
Logger('debug', 'Click nextButton HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the password method button
$pwdMethod = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$password_select_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the password method button
_WD_ElementAction($sSession, $pwdMethod, 'click')
Logger('debug', 'Click password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the password field
$passwordField = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$password_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate passwordField HTTPRESULT: ' & $_WD_HTTPRESULT)

; Enter value into the password field
_WD_ElementAction($sSession, $passwordField, 'value', $password)
Logger('debug', 'Entering password HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the password button
$passwordButton = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$login_button_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate passwordButton HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the password button
_WD_ElementAction($sSession, $passwordButton, 'click')
Logger('debug', 'Click passwordButton HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the OTP method button
$otp_button = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$otp_select_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the OTP method button
_WD_ElementAction($sSession, $otp_button, 'click')
Logger('debug', 'Click password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)


; User input enabled
_BlockInput($BI_ENABLE, Default)
Logger('debug', 'User input enabled')

FileClose($logfile)

Func Logger($level, $msg)
	$ts = _NowCalc()
	if $level == "debug" And $debug = 1 Then
		FileWriteLine($logfile, $ts & " -- " & $msg)
	ElseIf $level == "info" Then
		FileWriteLine($logfile, $ts & " -- " & $msg)
	EndIf
EndFunc

Func SetupGecko()
	_WD_Option('Driver', 'webdriver\geckodriver.exe')
	_WD_Option('DriverParams', '--log trace')
	_WD_Option('Port', 4444)

	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"browserName": "firefox", "acceptInsecureCerts":true}}}'

EndFunc   ;==>SetupGecko

Func SetupChrome()
	_WD_Option('Driver', 'webdriver\chromedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\chrome.log"')

   ; Add chromeOption to not offer saving credentials
	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "excludeSwitches": [ "enable-automation"], "prefs": { "credentials_enable_service": false, "profile": { "password_manager_enabled": false}}} }}}'


EndFunc   ;==>SetupChrome

Func SetupEdge()
	_WD_Option('Driver', 'webdriver\msedgedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\msedge.log"')

	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"ms:edgeOptions": {"excludeSwitches": [ "enable-automation"]}}}}'
EndFunc   ;==>SetupEdge



