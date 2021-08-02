#include-once
#include <crypt.au3>

$_crypt_PASSWORD_DEFAULT = "TH" ;

Func _crypt_setPassDefault($_passDef)
	$_crypt_PASSWORD_DEFAULT = $_passDef ;
EndFunc   ;==>_crypt_setPassDefault

Func _crypt_deEAS256File($path, $pathOut, $password = $_crypt_PASSWORD_DEFAULT)
	Return _Crypt_DecryptFile($path, $pathOut, $password, $CALG_AES_256) ;
EndFunc   ;==>_crypt_deEAS256File

Func _crypt_hashEAS256File($path, $pathOut, $password = $_crypt_PASSWORD_DEFAULT)
	$result = _Crypt_EncryptFile($path, $pathOut, $password, $CALG_AES_256) ;
EndFunc   ;==>_crypt_hashEAS256File

Func _crypt_deEAS256($data, $password = $_crypt_PASSWORD_DEFAULT)
	$result = _Crypt_DecryptData($data, $password, $CALG_AES_256) ;
	$result = @error <> 0 ? False : BinaryToString($result) ;
	Return $result ;
EndFunc   ;==>_crypt_deEAS256

Func _crypt_hashEAS256($data, $password = $_crypt_PASSWORD_DEFAULT)
	$result = _Crypt_EncryptData($data, $password, $CALG_AES_256) ;
	$result = @error <> 0 ? False : $result ;
	Return $result ;
EndFunc   ;==>_crypt_hashEAS256

Func _crypt_hashMd5($data)
	Return StringLower(StringMid(_Crypt_HashData($data, $CALG_MD5), 3)) ;
EndFunc   ;==>_crypt_hashMd5
