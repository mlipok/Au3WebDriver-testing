#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#SciTE4AutoIt3_Dynamic_Include_recursive_check=y
#SciTE4AutoIt3_Dynamic_Include=y
#SciTE4AutoIt3_Dynamic_Include_whiletyping=y

#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Array.au3>

#include "wd_helper.au3"
#include "wd_capabilities.au3"

Global $__g_sSession

#Region - WD SETUP
Func _WD_Initialization($sBrowser, $bHeadless = False, $bLogToFile = True)
;~ 	$_WD_DEBUG = $_WD_DEBUG_None ; details are not provided only set @error and @extended
;~ 	$_WD_DEBUG = $_WD_DEBUG_Error ; Gives minimized level of details
	$_WD_DEBUG = $_WD_DEBUG_Info ; Gives you optimized level of details
	#REMARK about $_WD_DEBUG_Full usage ; it will also sent yours sensitive/protected/personal data to the log
;~ 	$_WD_DEBUG = $_WD_DEBUG_Full ; Gives you the greatest level of details

	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	If $bLogToFile Then
		Local $sLogFile = @ScriptDir & "\Log\" & $sTimeStamp & '_Au3WebDriver_' & $sBrowser & ".log"
		_WD_Option('console', $sLogFile)
		ConsoleWrite("- Logs will be stored in:" & @CRLF)
		ConsoleWrite('"' & $sLogFile & '"' & @CRLF)
	EndIf

	Local $s_Download_dir = @ScriptDir & "\Au3WebDriver_DownloadDir"

	Local $sCapabilities = ''
	Switch $sBrowser
		Case 'firefox'
			_WD_UpdateDriver('firefox')
			$sCapabilities = _WD_SetupGecko($bHeadless, $s_Download_dir)
		Case 'chrome'
			#Region - Chrome driver update
			Local $sBrowserVersion = _WD_GetBrowserVersion($sBrowser)
			If Not @error And $sBrowser = "chrome" Then
				Local $i_Check = _VersionCompare("115.0.0.0", $sBrowserVersion)
				If Not @error And $i_Check = 1 Then $sBrowser = "chrome_legacy"
			EndIf
			#EndRegion - Chrome driver update
			$sCapabilities = _WD_SetupChrome($bHeadless, $s_Download_dir, $bLogToFile)
		Case 'msedge'
			_WD_UpdateDriver('msedge')
			$sCapabilities = _WD_SetupEdge($bHeadless, $s_Download_dir, $bLogToFile)
		Case 'opera'
			_WD_UpdateDriver('opera')
			$sCapabilities = _WD_SetupOpera($bHeadless, $s_Download_dir, $bLogToFile)
		Case 'msedgeie'
			_WD_UpdateDriver('msedgeie', Default, False)
			$sCapabilities = _WD_SetupEdgeIEMode($bHeadless, $s_Download_dir, $bLogToFile)
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

Func _WD_SetupGecko($bHeadless, $s_Download_dir = '')
;~ 	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	_WD_Option('Driver', 'geckodriver.exe')
	_WD_Option('Port', _WD_GetFreePort())
	_WD_Option('DriverParams', '--log trace --port=' & $_WD_PORT)

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'firefox')
	_WD_CapabilitiesAdd('browserName', 'firefox')
	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
	If $bHeadless Then _WD_CapabilitiesAdd('args', '--headless')
	_WD_CapabilitiesAdd('args', '-profile')
	_WD_CapabilitiesAdd('args', @LocalAppDataDir & '\Mozilla\Firefox\Profiles\WD_Testing_Profile')

	; https://stackoverflow.com/questions/33695690/webdriver-set-initial-url
;~ 	_WD_CapabilitiesAdd('prefs', 'rowser.startup.homepage', 'about:blank')
;~ 	_WD_CapabilitiesAdd('prefs', 'startup.homepage_welcome_url', 'about:blank')
;~ 	_WD_CapabilitiesAdd('prefs', 'startup.homepage_welcome_url.additional', 'about:blank')

	; avoid updates
	_WD_CapabilitiesAdd('prefs', 'browser.search.update', False)
	_WD_CapabilitiesAdd('prefs', 'extensions.update.autoUpdate', False)
	_WD_CapabilitiesAdd('prefs', 'extensions.update.autoUpdateEnabled', False)
	_WD_CapabilitiesAdd('prefs', 'extensions.update.enabled', False)
	_WD_CapabilitiesAdd('prefs', 'update_notifications.enabled', False)
	_WD_CapabilitiesAdd('prefs', 'update.showSlidingNotification', False)
	_WD_CapabilitiesAdd('prefs', 'app.update.auto', False)
	_WD_CapabilitiesAdd('prefs', 'app.update.enabled', False)

	; How to prevent Firefox to auto-check “remember decision” in certificates choice?
	; https://discourse.mozilla.org/t/how-to-prevent-firefox-to-auto-check-remember-decision-in-certificates-choice/88062
	_WD_CapabilitiesAdd("prefs", "security.remember_cert_checkbox_default_setting", False)

	If $s_Download_dir Then
		_WD_CapabilitiesAdd("prefs", "pdfjs.disabled", True)
		_WD_CapabilitiesAdd("prefs", "browser.download.folderList", 2)
		_WD_CapabilitiesAdd("prefs", "browser.download.dir", $s_Download_dir)
		_WD_CapabilitiesAdd("prefs", "browser.helperApps.neverAsk.saveToDisk", "application/zip, application/pdf, application/octet-stream, application/xml, text/xml, text/plain")
		_WD_CapabilitiesAdd("prefs", "browser.helperApps.neverAsk.openFile", "application/zip, application/pdf, application/octet-stream, application/xml, text/xml, text/plain")
		_WD_CapabilitiesAdd('prefs', 'browser.helperApps.alwaysAsk.force', False)
		_WD_CapabilitiesAdd("prefs", "browser.download.useDownloadDir", True)
		_WD_CapabilitiesAdd("prefs", "browser.download.alwaysOpenPanel", False)

		; CLEANUP for GDPR reason
		_WD_CapabilitiesAdd('prefs', 'browser.helperApps.deleteTempFileOnExit', True)
	EndIf


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

Func _WD_SetupChrome($bHeadless, $s_Download_dir = '', $bLogToFile = False)
	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	_WD_Option('Driver', 'chromedriver.exe')
	_WD_Option('Port', _WD_GetFreePort())
	Local $sDriverParams = '--verbose --log trace --port=' & $_WD_PORT
	If $bLogToFile Then $sDriverParams &= ' --log-path="' & @ScriptDir & '\log\' & $sTimeStamp & '_WebDriver_chrome.log"'
	_WD_Option('DriverParams', $sDriverParams)

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'chrome')
	_WD_CapabilitiesAdd('browserName', 'chrome')
	_WD_CapabilitiesAdd('w3c', True)
	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
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
	_WD_CapabilitiesAdd('prefs', 'profile.password_manager_enabled', False)     ; https://sqa.stackexchange.com/a/26515/14581
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

Func _WD_SetupEdge($bHeadless, $s_Download_dir = '', $bLogToFile = False)
	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	_WD_Option('Driver', 'msedgedriver.exe')
	_WD_Option('Port', _WD_GetFreePort())
	Local $sDriverParams = '--verbose --log trace --port=' & $_WD_PORT
	If $bLogToFile Then $sDriverParams &= ' --log-path="' & @ScriptDir & '\log\' & $sTimeStamp & '_WebDriver_msedge.log"'
	_WD_Option('DriverParams', $sDriverParams)

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'msedge')
;~ 	_WD_CapabilitiesAdd('browserName', 'msedge')
	_WD_CapabilitiesAdd('w3c', True)
	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
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

Func _WD_SetupOpera($bHeadless, $s_Download_dir = '', $bLogToFile = False)
	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	_WD_Option('Driver', 'operadriver.exe')
	_WD_Option('Port', _WD_GetFreePort())
	Local $sDriverParams = '--verbose --log trace --port=' & $_WD_PORT
	If $bLogToFile Then $sDriverParams &= ' --log-path="' & @ScriptDir & '\log\' & $sTimeStamp & '_WebDriver_opera.log"'
	_WD_Option('DriverParams', $sDriverParams)

	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'opera')
;~ 	_WD_CapabilitiesAdd('browserName', 'opera')
	_WD_CapabilitiesAdd('w3c', True)
;~ 	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
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

Func _WD_SetupEdgeIEMode($bHeadless, $s_Download_dir = '', $bLogToFile = False) ; this is for MS Edge IE Mode
	#forceref $bHeadless, $s_Download_dir ; it is Not passed from MSEdge To IE instance, like many others capabilities
	Local $sTimeStamp = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & @MIN & @SEC
	; https://www.selenium.dev/documentation/ie_driver_server/#required-configuration
	_WD_Option('Driver', 'IEDriverServer.exe')
	_WD_Option('Port', _WD_GetFreePort())
	Local $sDriverParams = '-log-level=INFO -port=' & $_WD_PORT & ' -host=127.0.0.1'
	If $bLogToFile Then $sDriverParams &= ' -log-file="' & @ScriptDir & '\log\' & $sTimeStamp & '_WebDriver_EdgeIEMode.log"'
	_WD_Option('DriverParams', $sDriverParams)

;~ 	Local $sCapabilities = '{"capabilities": {"alwaysMatch": { "se:ieOptions" : { "ie.edgepath":"C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe", "ie.edgechromium":true, "ignoreProtectedModeSettings":true,"excludeSwitches": ["enable-automation"]}}}}'
	_WD_CapabilitiesStartup()
	_WD_CapabilitiesAdd('alwaysMatch', 'msedgeie')
	_WD_CapabilitiesAdd('w3c', True)
;~ 	_WD_CapabilitiesAdd('acceptInsecureCerts', True)
	Local $sPath = _WD_GetBrowserPath("msedge")
	If $sPath Then _WD_CapabilitiesAdd("ie.edgepath", $sPath)
	_WD_CapabilitiesAdd("ie.edgechromium", True)
	_WD_CapabilitiesAdd("ignoreProtectedModeSettings", True)
	_WD_CapabilitiesAdd("initialBrowserUrl", "https://google.com")

	_WD_CapabilitiesDump(@ScriptLineNumber)
	Local $sCapabilities = _WD_CapabilitiesGet()
	Return $sCapabilities
EndFunc   ;==>SetupEdgeIEMode

#EndRegion - WD SETUP
