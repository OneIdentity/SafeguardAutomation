; ONLY FOR DEMO USE
;
; Compile with Aut2exe to ensure the include files are added too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_SPS.exe --args "{username} {password} {asset} <CSS selector of the username field> <CSS selector of the password field> <CSS selector of the login> <.example.com:1234>"
;
; Generic web portal scope: login and password input fields are available directly via the asset URL (no further clicks are required like enter the username first then click the login button to get the password field shown)
;
; Input parameters:
;  username
;  password
;  asset
;  field_username CSS selector
;  field_password CSS selector
;  field_login_button CSS selector
;  urlSuffix Optional domain name and/or custom port. Give in format of .example.com || :1234 || .example.com:1234

Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 0)

#include <MsgBoxConstants.au3>

#include 'webdriver\wd_core.au3'
#include 'webdriver\wd_helper.au3'

Local $username = $CmdLine[1]
Local $password = $CmdLine[2]
Local $asset = $CmdLine[3]
Local $username_css = $CmdLine[4]
Local $password_css = $CmdLine[5]
Local $login_button_css = $CmdLine[6]
If $CmdLine[0] = 7 Then
	Local $urlSuffix = $CmdLine[7]
Else
	Local $urlSuffix = ""
EndIf

Local $sDesiredCapabilities, $sSession

; We use Chrome in this sample. For other browsers lookup the functions at the end of the script.
SetupChrome()

_WD_Startup()

$sSession = _WD_CreateSession($sDesiredCapabilities)

; Hide the WebDriver console
_WD_ConsoleVisible(false)

; Navigate to asset website
_WD_Navigate($sSession, 'https://' & $asset & $urlSuffix )


; Set the username field of the local login form
$userField = _WD_FindElement($sSession, $_WD_LOCATOR_ByCSSSelector, $username_css)
_WD_ElementAction($sSession, $userField, 'value', $username)


; Set the password field of the login form
$passwordField = _WD_FindElement($sSession, $_WD_LOCATOR_ByCSSSelector, $password_css)
_WD_ElementAction($sSession, $passwordField, 'value', $password)


; Click the login button
$loginButton = _WD_FindElement($sSession, $_WD_LOCATOR_ByCSSSelector, $login_button_css)
_WD_ElementAction($sSession, $loginButton, 'click')

Func SetupGecko()
	_WD_Option('Driver', 'c:\AutoIT\webdriver\geckodriver.exe')
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
	_WD_Option('Driver', 'c:\AutoIT\webdriver\msedgedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\msedge.log"')

	$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"ms:edgeOptions": {"excludeSwitches": [ "enable-automation"]}}}}'
EndFunc   ;==>SetupEdge





