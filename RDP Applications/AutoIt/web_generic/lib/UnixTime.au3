#include <Date.au3>
#include <Array.au3>
#include <Constants.au3>

;Local $iUnixTime1 = _GetUnixTime()

;MsgBox($MB_SYSTEMMODAL, 'Seconds Since Jan, 1st, 1970 00:00:00 GMT', $iUnixTime1)

;Local $sUnixDate1 = _GetDate_fromUnixTime($iUnixTime1)
;MsgBox($MB_SYSTEMMODAL, "", $sUnixDate1)

;$sUnixDate1 = _GetDate_fromUnixTime($iUnixTime1, False)
;MsgBox($MB_SYSTEMMODAL, "", $sUnixDate1)

;$sUnixDate1 = _GetDate_fromUnixTime($iUnixTime1, False, False)
;MsgBox($MB_SYSTEMMODAL, "", $sUnixDate1)

;Local $iUnixTime2 = _GetUnixTime('2013/01/01 00:00:00')
;MsgBox($MB_SYSTEMMODAL, "", $iUnixTime2)

; Get timestamp for input datetime (or current datetime).
Func _GetUnixTime($sDate = 0);Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se

    Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
    Local $utcTime = ""

    If Not $sDate Then $sDate = _NowCalc()

    If Int(StringLeft($sDate, 4)) < 1970 Then Return ""

    If $aSysTimeInfo[0] = 2 Then ; if daylight saving time is active
        $utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate) ; account for time zone and daylight saving time
    Else
        $utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate) ; account for time zone
    EndIf

    Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
EndFunc   ;==>_GetUnixTime

;$blTrim: Year in short format and no seconds.
Func _GetDate_fromUnixTime($iUnixTime, $blTrim = True, $iReturnLocal = True)
    Local $aRet = 0, $aDate = 0
    Local $aMonthNumberAbbrev[13] = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    Local $timeAdj = 0
    If Not $iReturnLocal Then
        Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
        Local $timeAdj = $aSysTimeInfo[1] * 60
        If $aSysTimeInfo[0] = 2 Then $timeAdj += $aSysTimeInfo[7] * 60
    EndIf

    $aRet = DllCall("msvcrt.dll", "str:cdecl", "ctime", "int*", $iUnixTime + $timeAdj )

    If @error Or Not $aRet[0] Then Return ""

    $aDate = StringSplit(StringTrimRight($aRet[0], 1), " ", 2)

    If $blTrim Then Return  StringRight($aDate[4], 2) & "/" & StringFormat("%.2d",_ArraySearch($aMonthNumberAbbrev, $aDate[1])) & "/" & $aDate[2] & " " & StringTrimRight($aDate[3], 3)

    Return $aDate[4] & "/" & StringFormat("%.2d", _ArraySearch($aMonthNumberAbbrev, $aDate[1])) & "/" & $aDate[2] & " " & $aDate[3]
EndFunc   ;==>_GetUnixDate