#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#SciTE4AutoIt3_Dynamic_Include_recursive_check=y
#SciTE4AutoIt3_Dynamic_Include=y
#SciTE4AutoIt3_Dynamic_Include_whiletyping=y

#include "wd_testing_helper.au3"

_Main()

Func _Main()
	ConsoleWrite('! TESTING Line #' & @ScriptLineNumber & @CRLF)
	Local $bIsInitialized = Null
	; initialize only one browser at once - just leave desired browser uncommented and comment out each other
	$bIsInitialized = _WD_Initialization('FireFox', False, False)
;~ 	$bIsInitialized = _WD_Initialization('Chrome', False, False)
;~ 	$bIsInitialized = _WD_Initialization('MSEdge', False, False)
;~ 	$bIsInitialized = _WD_Initialization('Opera', False, False)
;~ 	$bIsInitialized = _WD_Initialization('MSEdgeIE', False, False)
	ConsoleWrite('! TESTING Line #' & @ScriptLineNumber & @CRLF)

	If $bIsInitialized = Null Then Return

	_Example()
	ConsoleWrite('! TESTING Line #' & @ScriptLineNumber & @CRLF)

	_WD_CleanUp()
	ConsoleWrite('! TESTING Line #' & @ScriptLineNumber & @CRLF)

EndFunc   ;==>_Main

Func _Example()
	_WD_Navigate($__g_sSession, "https://www.google.com")

;~ 	_WD_LoadWait($__g_sSession)

	Local $sElement = _WD_FindElement($__g_sSession, $_WD_LOCATOR_ByCSSSelector, "textarea[name='q']")
	_WD_ElementAction($__g_sSession, $sElement, 'click')
;~ 	_WD_LoadWait($__g_sSession)
EndFunc   ;==>_Example
