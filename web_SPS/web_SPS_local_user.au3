; ONLY FOR DEMO USE
; Created to work with SPS 6.12 or later where multiple authentication backends are configured.
;
; Compile with Aut2exe to ensure the include files are added too
; cmd line arguments for launcher: OI-SG-RemoteApp-Launcher.exe --cmd <path>\web_SPS_local_user.exe --args "{username} {password} {asset}"

Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 0)

#include <MsgBoxConstants.au3>

#include 'webdriver\wd_core.au3'
#include 'webdriver\wd_helper.au3'

Local $username = $CmdLine[1]
Local $password = $CmdLine[2]
Local $asset = $CmdLine[3]

; Configure domain suffix for the asset the user is navigating to
Local $domainSuffix = '.oneidentity.demo'

Local $sDesiredCapabilities, $sSession

; We use Chrome in this script. For other browsers lookup the functions below.
SetupChrome()

_WD_Startup()


$sSession = _WD_CreateSession($sDesiredCapabilities)

; Hide the WebDriver console
_WD_ConsoleVisible(false)

; Navigate to asset website
_WD_Navigate($sSession, 'https://' & $asset & $domainSuffix )

; Open the local login prompt
$localLoginXPath = '/html/body/main/div[2]/div[4]/div[3]/div/small/a'
$localLoginPrompt = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $localLoginXPath)
_WD_ElementAction($sSession, $localLoginPrompt, 'click')


; Set the username field of the local login form
$userFieldXPath = '/html/body/main/div[2]/div[4]/div[3]/div/div/div/form/div[1]/input'
$userField = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $userFieldXPath)
_WD_ElementAction($sSession, $userField, 'value', $username)


; Set the password field of the login form
$passwordFieldXPath = '/html/body/main/div[2]/div[4]/div[3]/div/div/div/form/div[2]/input'
$passwordField = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $passwordFieldXPath)
_WD_ElementAction($sSession, $passwordField, 'value', $password)


; Click the login button
$loginButtonXPath = '/html/body/main/div[2]/div[4]/div[3]/div/div/div/form/div[3]/button[2]'
$loginButton = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $loginButtonXPath)
_WD_ElementAction($sSession, $loginButton, 'click')

; Check if user managed to log in and shutdown the session and the WebDriver in case the user logged out or closed the browser
; NOTE: The case of bad credentials is not implemented.
$loggedInUserXPath = '/html/body/app/sg-shell/div/header/app-masthead/eui-masthead/header/div/button[1]/span[1]/eui-icon[1]'
$loginSuccessful = false
while 1
   $loggedInUserElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $loggedInUserXPath)
   If @error Then
	  If $loginSuccessful = true Then
		 _WD_DeleteSession($sSession)
		 _WD_Shutdown()
		 Exit
	  EndIf
   Else
	  $loginSuccessful = True
   EndIf
WEnd

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





