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
;~ 	$bIsInitialized = _WD_Initialization('FireFox', False, False)
	$bIsInitialized = _WD_Initialization('Chrome', False, False)
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
	Local Const $sArrayHeader = 'Absolute Identifiers > _WD_FrameEnter|Relative Identifiers > _WD_FrameEnter|FRAME attributes|URL|Body ElementID|IsHidden|MatchedElements'


	#Region - navigation
	Local $s_URL = '' ; place here website URL which you plan to automate
	_WD_Navigate($__g_sSession, $s_URL)
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - navigation


	#Region - wait until the page has finished loading
	_WD_LoadWait($__g_sSession)
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - wait until the page has finished loading


	#Region - wait for all frames to finish loading the page and get infromation about all frames
	Local $aFrameList = _WD_FrameList($__g_sSession, True, 1000, Default)
	If @error Then Return SetError(@error, @extended, 0)

	; show all frames
	_ArrayDisplay($aFrameList, 'Frames - get frame list as array', 0, 0, Default, $sArrayHeader)
	#EndRegion - wait for all frames to finish loading the page and get infromation about all frames


	#Region - Find element by XPath
	Local $sXpath = '' ; place here your XPath expression
	Local $aLocationOfElement1 = _WD_FrameListFindElement($__g_sSession, $_WD_LOCATOR_ByXPath, $sXpath)
	If @error Then Return SetError(@error, @extended, 0)

	_ArrayDisplay($aLocationOfElement1, '$aLocationOfElement1', 0, 0, Default, $sArrayHeader)

	Local $sElement1 = _WD_FindElement($__g_sSession, $_WD_LOCATOR_ByXPath, $sXpath)
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - Find element by XPath


	#Region - Perform some actions using the element found by XPath
	_WD_ElementAction($__g_sSession, $sElement1, 'click')
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - Perform some actions using the element found by XPath


	#Region - Find element by CSSSelector
	Local $sCSSSelector = '' ; place here your CSSSelector expression
	Local $aLocationOfElement2 = _WD_FrameListFindElement($__g_sSession, $_WD_LOCATOR_ByCSSSelector, $sCSSSelector)
	If @error Then Return SetError(@error, @extended, 0)

	_ArrayDisplay($aLocationOfElement2, '$aLocationOfElement1', 0, 0, Default, $sArrayHeader)

	Local $sElement2 = _WD_FindElement($__g_sSession, $_WD_LOCATOR_ByCSSSelector, $sCSSSelector)
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - Find element by CSSSelector


	#Region - Perform some actions using the element found by CSSSelector
	_WD_ElementAction($__g_sSession, $sElement2, 'click')
	If @error Then Return SetError(@error, @extended, 0)
	#EndRegion - Perform some actions using the element found by CSSSelector


EndFunc   ;==>_Example
