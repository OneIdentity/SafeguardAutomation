; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are added too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_generic.exe --args "<debug=0|1> {username} {password} {asset} <target> <CSS selector of the username field>  <CSS selector of the password field> <CSS selector of the login> [optional:<CSS selector of the next button>]"
;
; Web portal credential injection use-cases:
;  - Without the last optional next_button CSS input argument: For web applications where the username and password fields are shown on the same page.
;  - With the last optional next_button CSS input argument: For web applications where the password field is shown only after the username is entered and the 'next' button is clicked.
;
; Input parameters:
;  username
;  password
;  asset - Not required by the code however the Launcher requires its presence in its argument list.
;  target - Without https:// and including custom :port if required. Note: This is not the asset name information as stored in SPP.
;  field_username CSS selector
;  field_password CSS selector
;  login_button CSS selector
;  optional: next_button CSS selector


Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 0)

#include <MsgBoxConstants.au3>
#include <Date.au3>

#include 'webdriver\wd_core.au3'
#include 'webdriver\wd_helper.au3'

Local $debug = $CmdLine[1]
Local $username = $CmdLine[2]
Local $password = $CmdLine[3]
; Asset will not be used as cloud targets may be accessible on a different name than the Asset Name / Network Address in SPP, however the {asset} parameter must be given for the Launcher.
Local $asset = $CmdLine[4]
Local $target = $CmdLine[5]
Local $username_css = $CmdLine[6]
Local $password_css = $CmdLine[7]
Local $login_button_css = $CmdLine[8]
Local $next_button_css = ''
If $CmdLine[0] = 9 Then
	$next_button_css = $CmdLine[9]
EndIf

$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\web_generic.log", $FO_APPEND + $FO_CREATEPATH)
Logger('info', "Starting web orchestration with debug logging:" & $debug)
Logger('debug', "Received " & $CmdLine[0] & " attributes: " & $CmdLineRaw)
Logger('debug', "debug= " & $debug)
Logger('debug', "username= " & $username)
Logger('debug', "password= " & "*")
Logger('debug', "asset= " & $asset)
Logger('debug', "target= " & $target)
Logger('debug', "username_css= " & $username_css)
Logger('debug', "password_css= " & $password_css)
Logger('debug', "login_button_css= " & $login_button_css)
Logger('debug', "next_button_css= " & $next_button_css)

Local $sDesiredCapabilities, $sSession

; We use Chrome in this sample. For other browsers lookup the functions at the end of the script.
; Note: Make sure chromedriver is up-to-date. Chrome is updating frequently, chromedriver should have the matching version.
SetupChrome()

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
$userField = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$username_css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate userField HTTPRESULT: ' & $_WD_HTTPRESULT)

; Enter value into the username field
_WD_ElementAction($sSession, $userField, 'value', $username)
Logger('debug', 'Entering username HTTPRESULT: ' & $_WD_HTTPRESULT)

If $next_button_css <> '' Then
	; Locate the next button
	$nextButton = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$next_button_css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
	Logger('debug', 'Locate nextButton HTTPRESULT: ' & $_WD_HTTPRESULT)

	; Click the next button
	_WD_ElementAction($sSession, $nextButton, 'click')
	Logger('debug', 'Click nextButton HTTPRESULT: ' & $_WD_HTTPRESULT)
EndIf

; Locate the password field
$passwordField = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$password_css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate passwordField HTTPRESULT: ' & $_WD_HTTPRESULT)

; Enter the password
_WD_ElementAction($sSession, $passwordField, 'value', $password)
Logger('debug', 'Enter password HTTPRESULT: ' & $_WD_HTTPRESULT)

; Locate the login buttion
$loginButton = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$login_button_css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate loginButton HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the login button
_WD_ElementAction($sSession, $loginButton, 'click')
Logger('debug', 'Click login button HTTPRESULT: ' & $_WD_HTTPRESULT)

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



