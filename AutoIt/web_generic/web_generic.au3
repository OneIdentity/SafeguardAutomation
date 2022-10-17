; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are compiled too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_generic.exe --args "<debug=0|1> targetUrl v::css1::{username}||c::css2||c::css3||s::css4::{password}||c::css4 {asset}"
;
; The code supports any number of selectors, types of "v" as value or "c" as click or "s" as secret which is not logged, separated by "||".
; Input parameters:
; The actual action is defined with "::" separator.
; Sample: "v::css1::username||c::css2||c::css3||s::css4::password||c::css4"


Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 0)

#include <MsgBoxConstants.au3>
#include <Date.au3>

#include 'webdriver\wd_core.au3'
#include 'webdriver\wd_helper.au3'

#include "webdriver\BlockInputEX.au3"

Local $debug = $CmdLine[1]
Local $target = $CmdLine[2]

Local $input = $CmdLine[3]
; Asset will not be used as cloud targets may be accessible on a different name than the Asset Name / Network Address in SPP, however the {asset} parameter must be given for the Launcher.
Local $asset = $CmdLine[4]

$logfile = FileOpen(@UserProfileDir & "\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher-Orchestration\web_generic.log", $FO_APPEND + $FO_CREATEPATH)
Logger('info', "Starting web orchestration with debug logging:" & $debug)
Logger('debug', "debug=" & $debug)

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
			$element = _WD_WaitElement($sSession, $_WD_LOCATOR_ByCSSSelector,$css, Default,Default, BitOR($_WD_OPTION_Visible, $_WD_OPTION_Enabled))
			Logger('debug', 'Locate element ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
			Switch $action
				Case 'c'
					_WD_ElementAction($sSession, $element, 'click')
					Logger('debug', 'Clicked element: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)

				Case 'v'
					_WD_ElementAction($sSession, $element, 'value', $step[3])
					Logger('debug', 'Entered value: ' & $step[3] & ' into field: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
				Case 's'
					_WD_ElementAction($sSession, $element, 'value', $step[3])
					Logger('debug', 'Entered secret into field: ' & $css & ' -- HTTPRESULT: ' & $_WD_HTTPRESULT)
			EndSwitch
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



