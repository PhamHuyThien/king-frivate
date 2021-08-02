#include-once
#include <..\crypt\Crypt.au3>

#include <File.au3>
#include <Array.au3>

$_uti_name = "KingFrivate.TH"     ;
$_uti_version = "1.0.1"     ;
$_uti_alg = "AES 256 bit"     ;
$_uti_auth = "PhamHuyThien"     ;

Func _util_strDate()
	return @MDAY&"_"&@MON&"_"&@YEAR;
EndFunc

Func _util_copyright()

	Return "Name: " & $_uti_name &" v"&$_uti_version&@CRLF & _
			"Algorithm: " & $_uti_alg & @CRLF & _
			"Author: " & $_uti_auth & @CRLF & _
			"--------------------------------" & @CRLF ;
EndFunc   ;==>_util_copyright

Func _util_parseNameInPath($path)
	$spl = StringSplit($path, "") ;
	$dot = -1 ;
	For $i = $spl[0] To 1 Step -1
		If $spl[$i] == "\" Or $spl[$i] == "/" Then
			$dot = $i ;
			ExitLoop ;
		EndIf
	Next
	If $dot == -1 Then
		Return $path ;
	EndIf
	Return StringMid($path, $dot + 1) ;
EndFunc   ;==>_util_parseNameInPath

Func _util_splitNameFile($name)
	$spl = StringSplit($name, "") ;
	$dot = -1 ;
	For $i = $spl[0] To 1 Step -1
		If $spl[$i] == "." Then
			$dot = $i ;
			ExitLoop ;
		EndIf
	Next
	Local $split[2] ;
	If $dot == -1 Then
		$split[0] = $name ;
	Else
		$namef = StringMid($name, 1, $i - 1) ;
		$ext = StringMid($name, $i + 1) ;
		$split[0] = $namef ;
		$split[1] = $ext ;
	EndIf
	Return $split ;
EndFunc   ;==>_util_splitNameFile

Func _util_scanDir($path, $findFullPath = 1, $showFullPath = 2)
	$list = _FileListToArrayRec($path, "*", 2, $findFullPath, 0, $showFullPath) ;
	If @error <> 0 Then
		Return False ;
	EndIf
	Return $list ;
EndFunc   ;==>_util_scanDir

Func _util_scanFile($path, $findFullPath = 1, $showFullPath = 2)
	$list = _FileListToArrayRec($path, "*", 1, $findFullPath, 0, $showFullPath) ;
	If @error <> 0 Then
		Return False ;
	EndIf
	Return $list ;
EndFunc   ;==>_util_scanFile
