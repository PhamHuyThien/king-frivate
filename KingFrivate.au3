
#include <controller\ConfigController.au3>
#include <controller\BoxController.au3>
#include <crypt\Crypt.au3>

If Not _cc_confExists() Then
	$result = _box_init();
	_cc_confInit($result[0], $result[1]) ;
EndIf

DirCreate(@ScriptDir&"\inputs\");
DirCreate(@ScriptDir&"\outputs\");

$suggestions = _cc_accountGet("suggestions") ;
$passwordMd5 = _cc_accountGet("password") ;

$password = _box_start($passwordMd5, $suggestions);
_crypt_setPassDefault($password);

_box_waitEvent($password);

