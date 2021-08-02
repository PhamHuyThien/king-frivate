#include-once

#include <..\controller\ConfigController.au3>
#include <..\controller\FormController.au3>
#include <..\crypt\Crypt.au3>
#include <..\uti\Utils.au3>

#include <Array.au3>

Func _box_init()
	If MsgBox(32 + 4, "Cảnh báo", _util_copyright() & "Khởi động lần đầu bạn muốn khởi tạo?") == 7 Then
		Exit ;
	EndIf
	Do
		$password = InputBox("Thông báo", _util_copyright() & "Nhập mật khẩu khởi tạo:") ;
	Until $password <> "" ;
	Do
		$suggestions = InputBox("Thông báo", _util_copyright() & "Nhập gợi ý cho mật khẩu (" & $password & "):") ;
	Until $suggestions <> "" ;
	If MsgBox(32 + 4, "Cảnh báo", _util_copyright() & "Bạn đã nhớ nội dung [" & $suggestions & "] sẽ gợi nhớ ra [" & $password & "] chứ?") == 7 Then
		Exit ;
	EndIf
	Local $result[2] = [$password, $suggestions] ;
	Return $result ;
EndFunc   ;==>_box_init

Func _box_start($passwordMd5, $suggestions)
	Do
		MsgBox(32, "Thông báo", _util_copyright() & "Gợi ý mật khẩu:" & @CRLF & $suggestions) ;
		$password = InputBox("Thông báo", _util_copyright() & "Nhập mật khẩu để giải mã hoặc mã hóa file:") ;
		If @error <> 0 Then
			Exit ;
		EndIf
		$passwordMd5New = _crypt_hashMd5($password) ;
		If $passwordMd5New <> $passwordMd5 Then
			MsgBox(16, "Lỗi", _util_copyright() & "Mật khẩu sai!") ;
		EndIf
	Until $passwordMd5New == $passwordMd5 ;
	Return $password ;
EndFunc   ;==>_box_start

Func _box_waitEvent($password)
	Do
		$type = MsgBox(32 + 3, "Thông báo", _util_copyright() & "Bạn muốn giải giải mã hay mãi hóa?" & @CRLF & "- Yes: Mã hóa" & @CRLF & "- No: Giải mã" & @CRLF & "Cannel: Thoát") ;
		If $type == 2 Then
			Exit ;
		EndIf
		If $type == 6 Then
			$path = @ScriptDir & "\inputs\" ;
			$listFile = _util_scanFile($path) ;
			If $listFile == False Then
				MsgBox(32, "Cảnh báo", _util_copyright() & "Không tìm thấy file nào!" & @CRLF & $path) ;
				ContinueLoop ;
			EndIf
			$size = $listFile[0] ;
			If MsgBox(32 + 4, "Thông báo", _util_copyright() & "Có tất cả " & $size & " file!" & @CRLF & "Bạn muốn mã hóa chứ?") == 7 Then
				ContinueLoop ;
			EndIf
			$deleteFileRoot = False ;
			If MsgBox(32 + 4, "Cảnh báo", _util_copyright() & "Mã hóa và giữ lại file gốc?") == 7 Then
				$deleteFileRoot = True    ;
			EndIf
			$success = 0 ;
			$error = 0 ;
			For $i = 1 To $size
				$pathRoot = $listFile[$i] ;
				$fileNameNew = _util_parseNameInPath($pathRoot) ;
				$fileNameExt = _util_splitNameFile($fileNameNew)[1] ;
				$folderSave = _crypt_hashEAS256(StringLower($fileNameExt) & ".TH") ;
				$fileNameNew = _crypt_hashEAS256($fileNameNew) & ".TH" ;
				$pathNew = @ScriptDir & "\" & $folderSave & "\" & $fileNameNew ;
				_Crypt_hashEAS256File($pathRoot, $pathNew, $password) ;
				If @error Then
					$error = $error + 1 ;
					ContinueLoop ;
				EndIf
				$success = $success + 1 ;
				If $deleteFileRoot Then
					FileDelete($pathRoot)    ;
				EndIf
			Next
			MsgBox(64, "Thông báo", _util_copyright() & "Mã hóa hoàn tất!" & @CRLF & "Thành công: " & $success & ", Thất bại: " & $error) ;
		Else
			_fs_init(@ScriptDir, $password) ;
			_fs_show() ;
			_fs_waitEvent() ;
		EndIf
	Until False ;
EndFunc   ;==>_box_waitEvent


