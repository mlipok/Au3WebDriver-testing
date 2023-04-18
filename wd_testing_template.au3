#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Array.au3>

#include "wd_helper.au3"
#include "wd_capabilities.au3"

Global $__g_sSession

_Main()

Func _Main()
	; initialize only one browser at once - just leave desired browser uncommented and comment out each other
	_WD_Initialization('firefox', False)
;~ 	_WD_Initialization('chrome', False)
;~ 	_WD_Initialization('msedge', False)
;~ 	_WD_Initialization('opera', False)

	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main

Func _Example()
	_WD_Navigate($__g_sSession, "https://url:portnumber")
	_WD_LoadWait($__g_sSession)

	Local $sElement = _WD_FindElement($__g_sSession, $_WD_LOCATOR_ByXPath, "//button[@id='details-button']")
	_WD_ElementAction($__g_sSession, $sElement, 'click')
	_WD_LoadWait($__g_sSession)
EndFunc   ;==>_Example

#Region - WD SETUP
Func _WD_Initialization($sBrowser, $bHeadless = False)
;~ 	$_WD_DEBUG = $_WD_DEBUG_None ; details are not provided only set @error and @extended
;~ 	$_WD_DEBUG = $_WD_DEBUG_Error ; Gives minimized level of details
	$_WD_DEBUG = $_WD_DEBUG_Info ; Gives you optimized level of details

	#REMARK about $_WD_DEBUG_Full usage ; it will also sent yours sensitive/protected/personal data to the log
;~ 	$_WD_DEBUG = $_WD_DEBUG_Full ; Gives you the greatest level of details
	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	_WD_Option('console', @ScriptDir & "\Au3WebDriver_Testing_" & $sTimeStamp & ".log")
	Local $s_Download_dir = @ScriptDir & "\Au3WebDriver_DownloadDir"

	Local $sCapabilities = ''
	Switch $sBrowser
		Case 'firefox'
			_WD_UpdateDriver('firefox')
			$sCapabilities = SetupGecko($bHeadless)
		Case 'chrome'
			_WD_UpdateDriver('chrome')
			$sCapabilities = SetupChrome($bHeadless, $s_Download_dir)
		Case 'msedge'
			_WD_UpdateDriver('msedge')
			$sCapabilities = SetupEdge($bHeadless, $s_Download_dir)
		Case 'opera'
			_WD_UpdateDriver('opera')
			$sCapabilities = SetupOpera($bHeadless, $s_Download_dir)
	EndSwitch
	_WD_CapabilitiesDump(@ScriptLineNumber) ; dump current Capabilities setting to console - only for testing
	_WD_Startup()
	$__g_sSession = _WD_CreateSession($sCapabilities)
	If Not @error Then _WD_Window($__g_sSession, "maximize")
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "Wait after session creation - to have possibility to check logs, and browser state")
EndFunc   ;==>_WD_Initialization

Func _WD_CleanUp()
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "Wait before end - to have possibility to check logs, and browser state")
	_WD_DeleteSession($__g_sSession)
	_WD_Shutdown()
EndFunc   ;==>_WD_CleanUp

Func SetupGecko($bHeadless)
	_WD_Option('Driver', 'geckodriver.exe')
	_WD_Option('DriverParams', '--log trace')
	_WD_Option('Port', 4444)

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'firefox')
	_WD_CapabilitiesAdd('browserName', 'firefox')
	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
	If $bHeadless Then _WD_CapabilitiesAdd('args', '--headless')
	_WD_CapabilitiesAdd('args', '-profile')
	_WD_CapabilitiesAdd('args', @LocalAppDataDir & '\Mozilla\Firefox\Profiles\WD_Testing_Profile')

	; REMARKS
	; When using 32bit geckodriver.exe, you may need to set 'binary' option.
	; This shouldn't be needed when using 64bit geckodriver.exe,
	;  but at the same time setting it is not affecting the script.
	Local $sPath = _WD_GetBrowserPath("firefox")
	If Not @error Then
		_WD_CapabilitiesAdd('binary', $sPath)
		ConsoleWrite("wd_demo.au3: _WD_GetBrowserPath() > " & $sPath & @CRLF)
	EndIf

	Local $sCapabilities = _WD_CapabilitiesGet()
	Return $sCapabilities
EndFunc   ;==>SetupGecko

Func SetupChrome($bHeadless, $s_Download_dir = '')
	_WD_Option('Driver', 'chromedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\chrome.log"')

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch')
	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
	_WD_CapabilitiesAdd('firstMatch', 'chrome')
	_WD_CapabilitiesAdd('browserName', 'chrome')
	_WD_CapabilitiesAdd('w3c', True)
	_WD_CapabilitiesAdd('args', 'user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win' & StringReplace(@OSArch, 'X', '') & '; ' & @CPUArch & ') AppleWebKit/537.36 (KHTML, like Gecko) Chrome/' & _WD_GetBrowserVersion('chrome') & ' Safari/537.36')
	_WD_CapabilitiesAdd('args', 'user-data-dir', @LocalAppDataDir & '\Google\Chrome\User Data\WD_Testing_Profile')
	_WD_CapabilitiesAdd('args', '--profile-directory', Default)
	_WD_CapabilitiesAdd('args', 'start-maximized')
	_WD_CapabilitiesAdd('args', 'disable-infobars')
	_WD_CapabilitiesAdd('args', '--no-sandbox')
	_WD_CapabilitiesAdd('args', '--disable-blink-features=AutomationControlled')
	_WD_CapabilitiesAdd('args', '--disable-web-security')
	_WD_CapabilitiesAdd('args', '--allow-running-insecure-content')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--ignore-certificate-errors')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--guest')
	If $bHeadless Then _
			_WD_CapabilitiesAdd('args', '--headless')

	_WD_CapabilitiesAdd('prefs', 'credentials_enable_service', False)     ; https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-12272021/?do=findComment&comment=1464829
	#Region - downloading files
	If $s_Download_dir Then
		_WD_CapabilitiesAdd('prefs', 'download.default_directory', $s_Download_dir)

		; https://scripteverything.com/download-pdf-selenium-python/
		; https://www.autoitscript.com/forum/topic/209816-download-pdf-file-while-using-webdriver/?do=findComment&comment=1514582
		_WD_CapabilitiesAdd('prefs', 'download.prompt_for_download', False)
		_WD_CapabilitiesAdd('prefs', 'download.open_pdf_in_system_reader', False)
		_WD_CapabilitiesAdd('prefs', 'plugins.always_open_pdf_externally', True)
		_WD_CapabilitiesAdd('prefs', 'profile.default_content_settings.popups', 0)
	EndIf
	#EndRegion - downloading files

	_WD_CapabilitiesAdd('excludeSwitches', 'disable-popup-blocking')     ; https://help.applitools.com/hc/en-us/articles/360007189411--Chrome-is-being-controlled-by-automated-test-software-notification
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-automation')
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-logging')
	_WD_CapabilitiesAdd('excludeSwitches', 'load-extension')
;~ 	_WD_CapabilitiesAdd('excludeSwitches', 'disable-composited-antialiasing') ; ??  https://source.chromium.org/chromium/chromium/src/+/main:cc/base/switches.cc

	Local $sCapabilities = _WD_CapabilitiesGet()
	Return $sCapabilities
EndFunc   ;==>SetupChrome

Func SetupEdge($bHeadless, $s_Download_dir = '')
	_WD_Option('Driver', 'msedgedriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\msedge.log"')

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'msedge')
	If $bHeadless Then _WD_CapabilitiesAdd('args', '--headless')
	_WD_CapabilitiesAdd('args', 'user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win' & StringReplace(@OSArch, 'X', '') & '; ' & @CPUArch & ') AppleWebKit/537.36 (KHTML, like Gecko) Edge/' & _WD_GetBrowserVersion('msedge') & ' Safari/537.36')
	_WD_CapabilitiesAdd('args', 'user-data-dir', @LocalAppDataDir & '\Microsoft\Edge\User Data\WD_Testing_Profile')
	_WD_CapabilitiesAdd('args', '--profile-directory', Default)
	_WD_CapabilitiesAdd('args', 'start-maximized')
	_WD_CapabilitiesAdd('args', 'disable-infobars')
	_WD_CapabilitiesAdd('args', '--no-sandbox')
	_WD_CapabilitiesAdd('args', '--disable-blink-features=AutomationControlled')
	_WD_CapabilitiesAdd('args', '--disable-web-security')
	_WD_CapabilitiesAdd('args', '--allow-running-insecure-content')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--ignore-certificate-errors')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--guest')

	_WD_CapabilitiesAdd('prefs', 'credentials_enable_service', False)     ; https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-12272021/?do=findComment&comment=1464829
	#Region - downloading files
	If $s_Download_dir Then
		_WD_CapabilitiesAdd('prefs', 'download.default_directory', $s_Download_dir)

		; https://scripteverything.com/download-pdf-selenium-python/
		; https://www.autoitscript.com/forum/topic/209816-download-pdf-file-while-using-webdriver/?do=findComment&comment=1514582
		_WD_CapabilitiesAdd('prefs', 'download.prompt_for_download', False)
		_WD_CapabilitiesAdd('prefs', 'download.open_pdf_in_system_reader', False)
		_WD_CapabilitiesAdd('prefs', 'plugins.always_open_pdf_externally', True)
		_WD_CapabilitiesAdd('prefs', 'profile.default_content_settings.popups', 0)
	EndIf
	#EndRegion - downloading files

	_WD_CapabilitiesAdd('excludeSwitches', 'disable-popup-blocking')     ; https://help.applitools.com/hc/en-us/articles/360007189411--Chrome-is-being-controlled-by-automated-test-software-notification
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-automation')
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-logging')
	_WD_CapabilitiesAdd('excludeSwitches', 'load-extension')
;~ 	_WD_CapabilitiesAdd('excludeSwitches', 'disable-composited-antialiasing') ; ??  https://source.chromium.org/chromium/chromium/src/+/main:cc/base/switches.cc

	Local $sCapabilities = _WD_CapabilitiesGet()
	Return $sCapabilities
EndFunc   ;==>SetupEdge

Func SetupOpera($bHeadless, $s_Download_dir = '')
	_WD_Option('Driver', 'operadriver.exe')
	_WD_Option('Port', 9515)
	_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\opera.log"')

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'opera')
	_WD_CapabilitiesAdd('w3c', True)
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-automation')
	If $bHeadless Then _WD_CapabilitiesAdd('args', '--headless')
	_WD_CapabilitiesAdd('args', 'user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win' & StringReplace(@OSArch, 'X', '') & '; ' & @CPUArch & ') AppleWebKit/537.36 (KHTML, like Gecko) Opera/' & _WD_GetBrowserVersion('opera') & ' Safari/537.36')
	_WD_CapabilitiesAdd('args', 'user-data-dir', @AppDataDir & '\Opera Software\WD_Testing_Profile') ; default is c:\Users\LOGIN\AppData\Roaming\Opera Software\Opera Stable\
	_WD_CapabilitiesAdd('args', '--profile-directory', Default)
	_WD_CapabilitiesAdd('args', 'start-maximized')
	_WD_CapabilitiesAdd('args', 'disable-infobars')
	_WD_CapabilitiesAdd('args', '--no-sandbox')
	_WD_CapabilitiesAdd('args', '--disable-blink-features=AutomationControlled')
	_WD_CapabilitiesAdd('args', '--disable-web-security')
	_WD_CapabilitiesAdd('args', '--allow-running-insecure-content')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--ignore-certificate-errors')     ; https://stackoverflow.com/a/60409220
	_WD_CapabilitiesAdd('args', '--guest')
	If $bHeadless Then _
			_WD_CapabilitiesAdd('args', '--headless')

	_WD_CapabilitiesAdd('prefs', 'credentials_enable_service', False)     ; https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-12272021/?do=findComment&comment=1464829
	#Region - downloading files
	If $s_Download_dir Then
		_WD_CapabilitiesAdd('prefs', 'download.default_directory', $s_Download_dir)

		; https://scripteverything.com/download-pdf-selenium-python/
		; https://www.autoitscript.com/forum/topic/209816-download-pdf-file-while-using-webdriver/?do=findComment&comment=1514582
		_WD_CapabilitiesAdd('prefs', 'download.prompt_for_download', False)
		_WD_CapabilitiesAdd('prefs', 'download.open_pdf_in_system_reader', False)
		_WD_CapabilitiesAdd('prefs', 'plugins.always_open_pdf_externally', True)
		_WD_CapabilitiesAdd('prefs', 'profile.default_content_settings.popups', 0)
	EndIf
	#EndRegion - downloading files

	_WD_CapabilitiesAdd('excludeSwitches', 'disable-popup-blocking')     ; https://help.applitools.com/hc/en-us/articles/360007189411--Chrome-is-being-controlled-by-automated-test-software-notification
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-automation')
	_WD_CapabilitiesAdd('excludeSwitches', 'enable-logging')
	_WD_CapabilitiesAdd('excludeSwitches', 'load-extension')
;~ 	_WD_CapabilitiesAdd('excludeSwitches', 'disable-composited-antialiasing') ; ??  https://source.chromium.org/chromium/chromium/src/+/main:cc/base/switches.cc

	; REMARKS
	; When using 32bit operadriver.exe, you may need to set 'binary' option.
	; This shouldn't be needed when using 64bit operadriver.exe,
	;  but at the same time setting it is not affecting the script.
	Local $sPath = _WD_GetBrowserPath("opera")
	If Not @error Then
		_WD_CapabilitiesAdd('binary', $sPath)
		ConsoleWrite("wd_demo.au3: _WD_GetBrowserPath() > " & $sPath & @CRLF)
	EndIf

	Local $sCapabilities = _WD_CapabilitiesGet()
	Return $sCapabilities
EndFunc   ;==>SetupOpera

#EndRegion - WD SETUP
