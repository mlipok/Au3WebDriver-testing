# Au3WebDriver-testing
This script is a template for testing [Au3WebDriver](https://github.com/Danp2/au3WebDriver) cases.
The main idea is to include as many possible settings (capabilities) for a given browser.
This is to allow you to easily adjust the required settings to a given test case.

**How it is different than _wd_demo.au3_** ?
- has no gui, thus you can easily start coding your own script, as the structure **_wd_testing_template.au3_** is much simpler
- all configurations try to take advantage of as many capabilities as we already know, based on the principle that they are easier to remove than to add
- code is ready to use just you need to change example to your own stuff and you can start.

**For example:**

FireFox with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('FireFox', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

Google Chrome with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('Chrome', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

Microsoft Edge with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('MSEdge', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

Opera with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('Opera', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

Microsoft Edge (IE Mode) with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('MSEdgeIE', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

# Remarks
/docs was imported from 
https://github.com/Danp2/au3WebDriver/tree/master/docs

Thanks to [@danp2](https://github.com/Danp2) and [@Sven-Seyfert](https://github.com/Sven-Seyfert)


# Links / helps / Docs ...
https://peter.sh/experiments/chromium-command-line-switches/
