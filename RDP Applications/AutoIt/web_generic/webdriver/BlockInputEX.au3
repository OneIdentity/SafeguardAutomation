#include-once
#include <WinAPIConstants.au3>
#include <WinAPISys.au3>

Global Enum $BI_MOUSE = 1, $BI_KEYBOARD, $BI_ALLINPUT
Global $_BI_State[2][3] ; Stub | Hook | Flag

; #FUNCTION# ====================================================================================================================
; Name...........: _BlockInput
; Description ...: Block all mouse and keyboard inputs
; Syntax.........: _BlockInput($bFlag, $iInput = $BI_ALLINPUT)
; Parameters ....: $bFlag : $BI_DISABLE (1) = Disable user input
;                           $BI_ENABLE (0) = Enable user input
;                 : $iInput : $BI_MOUSE (1) = Affect Mouse only
;                 :           $BI_KEYBOARD(2) = Affect KeyBoard only
;                 :           $BI_ALLINPUT(3) = Both Mouse and Keyboard
;                  Constants are defined in "AutoItConstants.au3".
; Return values .: Success - 1 and @error is set to 0
;                  Failure - 0 and @error is set
;                    @error = 1 invalid input type
;                    @error = 2 invalid flag
; Author ........: Nine
; Modified ......: Nine
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _BlockInput($bFlag, $iInput = $BI_ALLINPUT)
  If $iInput = Default Then $iInput = $BI_ALLINPUT
  If $iInput <> $BI_ALLINPUT And $iInput <> $BI_MOUSE And $iInput <> $BI_KEYBOARD Then Return SetError(1)
  If $bFlag <> $BI_ENABLE And $bFlag <> $BI_DISABLE Then Return SetError(2)
  If BitAND($iInput, $BI_MOUSE) Then __BlockInputEX($bFlag, $BI_MOUSE, $WH_MOUSE_LL)
  If BitAND($iInput, $BI_KEYBOARD) Then __BlockInputEX($bFlag, $BI_KEYBOARD, $WH_KEYBOARD_LL)
  Return 1
EndFunc   ;==>_BlockInput

; Internal use only ========================================

Func __BlockInputEX($bFlag, $iInput, $iHook)
  $iInput -= 1
  If Not BitXOR($bFlag, $_BI_State[$iInput][2]) Then Return
  $_BI_State[$iInput][2] = Not $_BI_State[$iInput][2]
  If Not $_BI_State[$iInput][2] Then Return __BlockInput_Cleanup($iInput)
  $_BI_State[$iInput][0] = DllCallbackRegister(__BlockInput_MouseKeyProc, "long", "int;wparam;lparam")
  Local $hMod = _WinAPI_GetModuleHandle(0)
  $_BI_State[$iInput][1] = _WinAPI_SetWindowsHookEx($iHook, DllCallbackGetPtr($_BI_State[$iInput][0]), $hMod)
EndFunc   ;==>__BlockInputEX

; ===========================================================

Func __BlockInput_MouseKeyProc($nCode, $wParam, $lParam)
  Return 1
EndFunc   ;==>__BlockInput_MouseKeyProc

; ===========================================================

Func __BlockInput_Cleanup($iInput)
  _WinAPI_UnhookWindowsHookEx($_BI_State[$iInput][1])
  DllCallbackFree($_BI_State[$iInput][0])
EndFunc   ;==>__BlockInput_Cleanup
