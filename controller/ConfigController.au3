#include-once
#include <..\crypt\Crypt.au3>

$_CC_CONFIG_PATH = "0x2363538F4EF416F97254D8F955063B54.TH" ;

Func _cc_confExists()
	Return FileExists($_CC_CONFIG_PATH) ;
EndFunc   ;==>_cc_confExists

Func _cc_getAllSectionNames()
	Return IniReadSectionNames($_CC_CONFIG_PATH) ;
EndFunc   ;==>_cc_getAllSectionNames

Func _cc_getAllSection($section)
	Return IniReadSection($_CC_CONFIG_PATH, $section) ;
EndFunc   ;==>_cc_getAllSection

Func _cc_accountGet($key)
	Return IniRead($_CC_CONFIG_PATH, "account", $key, "") ;
EndFunc   ;==>_cc_accountGet

Func _cc_confInit($password, $suggestions)
	Local $folderNotEncs[2] = ["inputs", "outputs"] ;
	;
	IniWrite($_CC_CONFIG_PATH, "account", "password", _crypt_hashMd5($password))     ;
	IniWrite($_CC_CONFIG_PATH, "account", "suggestions", $suggestions)     ;
	;
	For $i = 0 To UBound($folderNotEncs) - 1
		If Not FileExists($folderNotEncs[$i]) Then
			DirCreate($folderNotEncs[$i])    ;
		EndIf
	Next
EndFunc   ;==>_cc_confInit
