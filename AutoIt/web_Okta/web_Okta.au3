; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are added too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_Okta.exe --args "<debug=0|1> <browser:chrome|edge> <target> {username} {password} {asset}"
;
;
; Input parameters:
;  browser: chrome|firefox
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
Local $browser = $CmdLine[2]
Local $target = $CmdLine[3]
Local $username = $CmdLine[4]
Local $password = $CmdLine[5]
; Asset will not be used as cloud targets may be accessible on a different name than the Asset Name / Network Address in SPP, however the {asset} parameter must be given for the Launcher.
Local $asset = $CmdLine[6]

Local $username_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[3]/div[1]/div[2]/span/input"
Local $next_button_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
Local $password_select_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/div/div[3]/div[2]/div[2]/a"
Local $password_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[4]/div/div[2]/span/input"
Local $login_button_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
;Local $otp_select_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/div/div[1]/div[2]/div[2]/a"
;Local $otp_input_xpath = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[1]/div[4]/div/div[2]/span/input"
;Local $otp_verify = "/html/body/div[2]/div[2]/main/div[2]/div/div/div[2]/form/div[2]/input"
;LocaL $otp_seed = ""
Local $log_level = ''

If $debug Then
	$loglevel = 'debug'
Else
	$loglevel = 'info'
EndIf

$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\web_Okta.log", $FO_APPEND + $FO_CREATEPATH)
Logger('info', "Starting web orchestration with debug logging:" & $debug)
Logger('debug', "Received " & $CmdLine[0] & " attributes: " & $CmdLineRaw)
Logger('debug', "debug= " & $debug)
Logger('debug', "username= " & $username)
Logger('debug', "password= " & "*")
Logger('debug', "asset= " & $asset)
Logger('debug', "target= " & $target)

Local $sDesiredCapabilities, $sSession

; Note: Make sure drivers are up-to-date. For example, Chrome is updating frequently, chromedriver should have the matching version.
Switch $browser
	Case 'chrome'
		SetupChrome()
	Case 'firefox'
		SetupGecko()
EndSwitch

; Disable user input
if $debug = 0 Then
	_BlockInput($BI_DISABLE)
	Logger('debug', 'User input disabled')
EndIf

_WD_Startup()

; Create session
Logger('debug', 'Creating session with capabilities: ' & $sDesiredCapabilities)
While $_WD_HTTPRESULT <> 200
	$sSession = _WD_CreateSession($sDesiredCapabilities)
	Logger('debug', 'HTTPRESULT: ' & $_WD_HTTPRESULT)
WEnd
Logger('debug', 'Session: ' & $sSession)

; Hide the WebDriver console
If $debug = 0 Then
	_WD_ConsoleVisible(false)
EndIf

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

#comments-start
; Locate the OTP method button
$otp_button = _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath,$otp_select_xpath, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
Logger('debug', 'Locate password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)

; Click the OTP method button
_WD_ElementAction($sSession, $otp_button, 'click')
Logger('debug', 'Click password method selection button HTTPRESULT: ' & $_WD_HTTPRESULT)
#comments-end

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


	;this goes into "prefs":{}
	Logger('debug','Disable devtools in Firefox')
	Local $ff_preferences=''

	$ff_preferences&='"devtools.accessibility.enabled": false,'
	$ff_preferences&='"devtools.accessibility.enabled": false,'
	$ff_preferences&='"devtools.application.enabled": false,'
	$ff_preferences&='"devtools.accessibility.enabled": false,'
	$ff_preferences&='"devtools.application.enabled": false,'
	$ff_preferences&='"devtools.chrome.enabled": false,'
	$ff_preferences&='"devtools.command-button-errorcount.enabled": false,'
	$ff_preferences&='"devtools.command-button-frames.enabled": false,'
	$ff_preferences&='"devtools.command-button-measure.enabled": false,'
	$ff_preferences&='"devtools.command-button-noautohide.enabled": false,'
	$ff_preferences&='"devtools.command-button-pick.enabled": false,'
	$ff_preferences&='"devtools.command-button-responsive.enabled": false,'
	$ff_preferences&='"devtools.command-button-rulers.enabled": false,'
	$ff_preferences&='"devtools.command-button-screenshot.enabled": false,'
	$ff_preferences&='"devtools.command-button-splitconsole.enabled": false,'
	$ff_preferences&='"devtools.custom-formatters.enabled": false,'
	$ff_preferences&='"devtools.debugger.enabled": false,'
	$ff_preferences&='"devtools.debugger.map-scopes-enabled": false,'
	$ff_preferences&='"devtools.debugger.pretty-print-enabled": false,'
	$ff_preferences&='"devtools.debugger.remote-enabled": false,'
	$ff_preferences&='"devtools.debugger.ui.variables-sorting-enabled": false,'
	$ff_preferences&='"devtools.dom.enabled": false,'
	$ff_preferences&='"devtools.every-frame-target.enabled": false,'
	$ff_preferences&='"devtools.inspector.chrome.three-pane-enabled": false,'
	$ff_preferences&='"devtools.inspector.compatibility.enabled": false,'
	$ff_preferences&='"devtools.inspector.enabled": false,'
	$ff_preferences&='"devtools.inspector.inactive.css.enabled": false,'
	$ff_preferences&='"devtools.inspector.ruleview.inline-compatibility-warning.enabled": false,'
	$ff_preferences&='"devtools.inspector.three-pane-enabled": false,'
	$ff_preferences&='"devtools.jsonview.enabled": false,'
	$ff_preferences&='"devtools.markup.mutationBreakpoints.enabled": false,'
	$ff_preferences&='"devtools.memory.enabled": false,'
	$ff_preferences&='"devtools.netmonitor.enabled": false,'
	$ff_preferences&='"devtools.overflow.debugging.enabled": false,'
	$ff_preferences&='"devtools.performance.enabled": false,'
	$ff_preferences&='"devtools.performance.recording.active-tab-view.enabled": false,'
	$ff_preferences&='"devtools.responsive.leftAlignViewport.enabled": false,'
	$ff_preferences&='"devtools.responsive.reloadNotification.enabled": false,'
	$ff_preferences&='"devtools.responsive.touchSimulation.enabled": false,'
	$ff_preferences&='"devtools.screenshot.audio.enabled": false,'
	$ff_preferences&='"devtools.screenshot.clipboard.enabled": false,'
	$ff_preferences&='"devtools.serviceWorkers.testing.enabled": false,'
	$ff_preferences&='"devtools.source-map.client-service.enabled": false,'
	$ff_preferences&='"devtools.storage.enabled": false,'
	$ff_preferences&='"devtools.storage.extensionStorage.enabled": false,'
	$ff_preferences&='"devtools.styleeditor.autocompletion-enabled": false,'
	$ff_preferences&='"devtools.styleeditor.enabled": false,'
	$ff_preferences&='"devtools.target-switching.server.enabled": false,'
	$ff_preferences&='"devtools.toolbox.splitconsoleEnabled": false,'
	$ff_preferences&='"devtools.webconsole.enabled": false'
	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"moz:firefoxOptions":{"prefs": {' & $ff_preferences & '}},"browserName": "firefox", "acceptInsecureCerts":true}}}'
	Logger('debug',"Capabilities: " &$sDesiredCapabilities)

EndFunc   ;==>SetupGecko

Func SetupChrome()
	_WD_Option('Driver', 'webdriver\chromedriver.exe')
	_WD_Option('Port', 9515)
	If $debug = 1 Then
		_WD_Option('DriverParams', '--log-path="' & @UserProfileDir & '\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\chromedriver.log" --log-level=' & StringUpper($loglevel) & ' --readable-timestamp')
	Else
		_WD_Option('DriverParams', '--silent')
	EndIf

   ; Add chromeOption to not offer saving credentials
	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "excludeSwitches": [ "enable-automation", "enable-logging"], "prefs": { "credentials_enable_service": false, "profile": { "password_manager_enabled": false, "URLAllowList": "[' & $target & ']"}}} }}}'
	


EndFunc   ;==>SetupChrome

Func SetupEdge()
	_WD_Option('Driver', 'webdriver\msedgedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\msedge.log"')

	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"ms:edgeOptions": {"excludeSwitches": [ "enable-automation"]}}}}'
EndFunc   ;==>SetupEdge



