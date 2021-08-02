#include-once

#include <GUIConstantsEx.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <GuiTreeView.au3>

#include <..\uti\Utils.au3>
#include <..\crypt\Crypt.au3>


Global $_fs_hGUI, $_fs_treeview, $_fs_controlTreeview, $_fs_decrypt, $_fs_exit, $_fs_stopEvent = true;
Global $_fs_items[1][2], $_fs_itemstmp[1][2], $_fs_root ;

Global $_fs_scriptPath, $_fs_password ;

Func _fs_init($scriptPath, $password)
	$_fs_scriptPath = $scriptPath ;
	$_fs_password = $password ;
	$_fs_items = $_fs_itemstmp;
	$_fs_hGUI = GUICreate("Show file - " & $_uti_auth, 415, 275, 444, 245)
	$_fs_treeview = GUICtrlCreateTreeView(8, 8, 393, 225, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_CHECKBOXES), $WS_EX_CLIENTEDGE) ;
	$_fs_controlTreeview = ControlGetHandle($_fs_hGUI, "", $_fs_treeview) ;
	$_fs_root = GUICtrlCreateTreeViewItem("Root", $_fs_treeview)
	Local $listIdItems[1][2] ;
	$idDirs = _util_scanDir($_fs_scriptPath, 0, 1) ;
	For $i = 0 To $idDirs[0]
		$folderName = _crypt_deEAS256($idDirs[$i]) ;
		If $folderName == False Or StringRight($folderName, 3) <> ".TH" Then
			ContinueLoop ;
		EndIf
		$idRoot2 = GUICtrlCreateTreeViewItem($folderName & "  ~~> (" & $idDirs[$i] & ")", $_fs_root) ;
		$pathFolder2 = _util_scanFile($_fs_scriptPath & "\" & $idDirs[$i] & "\", 0, 1) ;
		If $pathFolder2 == False Then
			ContinueLoop ;
		EndIf
		For $j = 1 To $pathFolder2[0]
			$fileName = $pathFolder2[$j] ;
			If StringRight($fileName, 3) <> ".TH" Then
				ContinueLoop ;
			EndIf
			$fileName = StringMid($fileName, 1, StringLen($fileName) - 3) ;
			$fileName = _crypt_deEAS256($fileName) ;
			If $fileName == False Then
				ContinueLoop ;
			EndIf
			$idRoot3 = GUICtrlCreateTreeViewItem($fileName & "  ~~> (" & $pathFolder2[$j] & ")", $idRoot2) ;
			_ArrayAdd($_fs_items, $idRoot2 & "|" & $idRoot3)     ;
		Next
	Next
	$_fs_items[0][0] = UBound($_fs_items) - 1 ;
	ControlTreeView($_fs_hGUI, "", $_fs_controlTreeview, "Expand", "Root") ;
	$_fs_decrypt = GUICtrlCreateButton("Giải mã", 232, 240, 75, 25)
	$_fs_exit = GUICtrlCreateButton("Thoát", 328, 240, 75, 25)
EndFunc   ;==>_fs_init

Func _fs_show($state = @SW_SHOW)
	GUISetState($state)
EndFunc   ;==>_fs_show

Func _fs_waitEvent()
	While $_fs_stopEvent;
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $_fs_exit
				_fs_destroy();
				ExitLoop ;
			Case $_fs_root
				Local $state = $GUI_UNCHECKED
				If BitAND(GUICtrlRead($_fs_root), $GUI_CHECKED) Then
					$state = $GUI_CHECKED ;
					GUICtrlSetState($_fs_root, $GUI_DEFBUTTON + $GUI_CHECKED)
				Else
					GUICtrlSetState($_fs_root, $GUI_UNCHECKED)
				EndIf
				For $j = 1 To $_fs_items[0][0]
					GUICtrlSetState($_fs_items[$j][1], $state) ;
					_GUICtrlTreeView_SetChecked($_fs_treeview, $_fs_items[$j][0], $state == $GUI_CHECKED) ;
					_GUICtrlTreeView_Expand($_fs_treeview, $_fs_items[$j][0], $state == $GUI_CHECKED) ;
				Next
			Case $_fs_decrypt
				Local $itemsDec[1][2]    ;
				For $i = 1 To $_fs_items[0][0]
					If _GUICtrlTreeView_GetChecked($_fs_treeview, $_fs_items[$i][1]) Then
						_ArrayAdd($itemsDec, $_fs_items[$i][0] & "|" & $_fs_items[$i][1]) ;
					EndIf
				Next
				$itemsDec[0][0] = UBound($itemsDec) - 1  ;
				Local $pathDec[1] ;
				For $i = 1 To $itemsDec[0][0]
					$idFolder = $itemsDec[$i][0] ;
					$idFile = $itemsDec[$i][1] ;
					$nameFolder = _GUICtrlTreeView_GetText($_fs_treeview, $idFolder) ;
					$nameFile = _GUICtrlTreeView_GetText($_fs_treeview, $idFile) ;
					$nameFolder = __fs_getNameEncrypt($nameFolder) ;
					$nameFile = __fs_getNameEncrypt($nameFile) ;
					_ArrayAdd($pathDec, $_fs_scriptPath & "\" & $nameFolder & "\" & $nameFile) ;
				Next
				$pathDec[0] = UBound($pathDec) - 1 ;
				If $pathDec[0] == 0 Then
					MsgBox(32, "Cảnh báo", _util_copyright() & "Phải chọn một file để giải mã!") ;
					ContinueLoop ;
				EndIf
				If MsgBox(32 + 4, "Thông báo", _util_copyright() & "Bạn muốn giải mã " & $pathDec[0] & " file chứ?") == 7 Then
					ContinueLoop ;
				EndIf
				$deleteFileRoot = False ;
				If MsgBox(32 + 4, "Cảnh báo", _util_copyright() & "Giải mã và giữ lại file gốc?") == 7 Then
					$deleteFileRoot = True ;
				EndIf
				_fs_show(@SW_HIDE) ;
				$success = 0 ;
				$error = 0 ;
				For $i = 1 To $pathDec[0]
					$fileName = _util_parseNameInPath($pathDec[$i]) ;
					$fileExt = _util_splitNameFile($fileName) ;
					$fileNameDec = _crypt_deEAS256($fileExt[0]) ;
					$pathOut = $_fs_scriptPath & "\outputs\" & _util_strDate() ;
					if Not FileExists($pathOut) Then
						DirCreate($pathOut);
					EndIf
					$pathOut = $pathOut &"\"& $fileNameDec ;
					If Not _crypt_deEAS256File($pathDec[$i], $pathOut, $_fs_password) Then
						$error = $error + 1 ;
						ContinueLoop ;
					EndIf
					$success = $success + 1 ;
					If $deleteFileRoot Then
						FileDelete($pathDec[$i]) ;
					EndIf
				Next
				MsgBox(64, "Thông báo", _util_copyright() & "Giải mã hoàn tất!" & @CRLF & "Thành công " & $success & ", Thất bại: " & $error) ;
				_fs_destroy();
				ExitLoop;
		EndSwitch
		For $i = 1 To $_fs_items[0][0]
			If $nMsg == $_fs_items[$i][0] Then
				Local $state = $GUI_UNCHECKED
				If BitAND(GUICtrlRead($_fs_items[$i][0]), $GUI_CHECKED) Then
					$state = $GUI_CHECKED
					GUICtrlSetState($_fs_items[$i][0], $GUI_DEFBUTTON + $GUI_CHECKED)
				Else
					GUICtrlSetState($_fs_items[$i][0], $GUI_UNCHECKED)
				EndIf
				For $j = 1 To $_fs_items[0][0]
					If $_fs_items[$j][0] == $_fs_items[$i][0] Then
						GUICtrlSetState($_fs_items[$j][1], $state) ;
					EndIf
				Next
			EndIf
		Next
	WEnd
EndFunc   ;==>_fs_waitEvent

Func _fs_destroy()
	GUIDelete($_fs_hGUI) ;
EndFunc   ;==>_fs_destroy

Func __fs_getNameEncrypt($name)
	$start = -1 ;
	$end = -1 ;
	$names = StringSplit($name, "") ;
	For $i = $names[0] To 1 Step -1
		If $names[$i] == ")" Then
			$end = $i ;
		EndIf
		If $names[$i] == "(" Then
			$start = $i ;
		EndIf
		If $start <> -1 And $end <> -1 Then
			ExitLoop ;
		EndIf
	Next
	$mid = "" ;
	If $start <> -1 And $end <> -1 Then
		$mid = StringMid($name, $start + 1, $end - $start - 1) ;
	EndIf
	Return $mid ;
EndFunc   ;==>__fs_getNameEncrypt
