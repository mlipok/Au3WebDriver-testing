# Au3WebDriver-testing
This script is a template for testing [Au3WebDriver](https://github.com/Danp2/au3WebDriver) cases.
The main idea is to include as many possible settings (capabilities) for a given browser.
This is to allow you to easily adjust the required settings to a given test case.

**How it is different than _wd_demo.au3_** ?
- has no gui, thus you can easily start coding your own script, as the structure **_wd_testing_template.au3_** is much simpler
- all setups try to use as many capabilities as possible, based on the principle that it is easier to remove them than to add them
- code is ready to use just you need to change example to your own stuff and you can start for example FireFox with this following snippet
```autoit
_Main()

Func _Main()
	_WD_Initialization('FireFox', False, False)
	_Example()
	_WD_CleanUp()
EndFunc   ;==>_Main
```

# Remarks
/docs was imported form 
https://github.com/Danp2/au3WebDriver/tree/master/docs

Thanks to [@danp2](https://github.com/Danp2) and [@Sven-Seyfert](https://github.com/Sven-Seyfert)


# Links / helps / Docs ...
https://peter.sh/experiments/chromium-command-line-switches/
