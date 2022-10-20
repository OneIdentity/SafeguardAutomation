; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are compiled too
;
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_generic.exe --args "<debug=0|1> <browser=firefox|chrome|edge> targetUrl v::css1::{username}||c::css2||c::css3||s::css4::{password}||c::css4 {asset}"
;
; Altough the code supports Firefox (needs geckodriver.exe) and Edge (needs msedgedriver.exe) too:
; - Edge has not been tested at all
; - It is not reliable with Firefox. Also, it should disable devtools but in the tests not all of them got disabled and users can re-enable them at this point.
;
; The code supports any number of selectors, types of "v" as value or "c" as click or "s" as secret which is not logged, separated by "||".
; Input parameters:
; The actual action is defined with "::" separator.
; Sample: "v::css1::username||c::css2||c::css3||s::css4::password||c::css4"
;
; The code disables user input when not running in debug mode


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
Local $input = $CmdLine[4]
Local $asset = $CmdLine[5] ; Asset will not be used as cloud targets may be accessible on a different name than the Asset Name / Network Address in SPP, however the {asset} parameter must be given for the Launcher.
Local $loglevel = ''

If $debug Then
	$loglevel = 'debug'
Else
	$loglevel = 'info'
EndIf
$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\web_generic.log", $FO_APPEND + $FO_CREATEPATH)
Logger('info', "Starting web orchestration with loglevel:" & $loglevel)
Logger('debug', "browser=" & $browser)

Local $sDesiredCapabilities, $sSession

; We use Chrome in this sample. For other browsers lookup the functions at the end of the script.
; Note: Make sure chromedriver is up-to-date. Chrome is updating frequently, chromedriver should have the matching version.
Switch $browser
	Case 'chrome'
		SetupChrome()
	Case 'firefox'
		SetupGecko()
	Case 'edge'
		SetupEdge()
EndSwitch

; Disable user input
If $debug = 0 Then
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
$_WD_HTTPRESULT = 0
Logger('debug', 'Session: ' & $sSession)

; Hide the WebDriver console
_WD_ConsoleVisible(false)

; Navigate to asset website
$url= 'https://' & $target
While $_WD_HTTPRESULT <> 200
	_WD_Navigate($sSession,  $url)
	Logger('debug', 'Navigate HTTPRESULT: ' & $_WD_HTTPRESULT)
WEnd
$_WD_HTTPRESULT = 0

; Execute login workflow
$steps = StringSplit($input, '||',$STR_ENTIRESPLIT)
If IsArray($steps) Then
	$nrOfSteps = UBound($steps)-1
	Logger('debug', 'Parsed ' & $nrOfSteps & ' steps')
	For $i=1 to $nrOfSteps
		$step = StringSplit($steps[$i],"::",$STR_ENTIRESPLIT)
		If IsArray($step) Then
			$action = $step[1]
			$css = $step[2]
			Logger('debug', 'Action ' & $i & ': ' & $action & ', CSS selector: ' & $css)
			While $_WD_HTTPRESULT <> 200
				$element = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
				Logger('debug', 'Locate element ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
			WEnd
			$_WD_HTTPRESULT = 0
			Switch $action
				Case 'c'
					While $_WD_HTTPRESULT <> 200
						_WD_ElementAction($sSession, $element, 'click')
						Logger('debug', 'Clicked element: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
					WEnd
				Case 'v'
					While $_WD_HTTPRESULT <> 200
						_WD_ElementAction($sSession, $element, 'value', $step[3])
						Logger('debug', 'Entered value: ' & $step[3] & ' into field: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
					WEnd
				Case 's'
					While $_WD_HTTPRESULT <> 200
						_WD_ElementAction($sSession, $element, 'value', $step[3])
						Logger('debug', 'Entered secret into field: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
					WEnd
			EndSwitch
			$_WD_HTTPRESULT = 0
		Else
			Logger('info', 'Cannot parse step: ' & $step & ' -- Exit')
			Exit
		EndIf
	Next
Else
	Logger('info', 'Cannot parse selectors: ' & $input & ' -- Exit')
	Exit
EndIf

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
	_WD_Option('DriverParams', '--log ' & $loglevel)
	_WD_Option('Port', 4444)

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
	_WD_Option('DriverParams', '--log-path="' & @UserProfileDir & '\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\chromedriver.log" --log-level=' & StringUpper($loglevel) & ' --readable-timestamp')

   ; Add chromeOption to not offer saving credentials
	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "excludeSwitches": [ "enable-automation"], "prefs": { "credentials_enable_service": false, "profile": { "password_manager_enabled": false}}} }}}'

EndFunc   ;==>SetupChrome

Func SetupEdge()
	_WD_Option('Driver', 'webdriver\msedgedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\msedge.log"')

	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"ms:edgeOptions": {"excludeSwitches": [ "enable-automation"]}}}}'
EndFunc   ;==>SetupEdge





