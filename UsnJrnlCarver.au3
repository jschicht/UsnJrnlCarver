#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Program Files (x86)\autoit-v3.3.14.2\Icons\au3.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Extracts raw UsnJrnl records
#AutoIt3Wrapper_Res_Description=Extracts raw UsnJrnl records
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPIEx.au3>

Global Const $UsnSignature = "000002000000"
Global Const $USN_Page_Size = 4096

ConsoleWrite("UsnJrnlCarver v1.0.0.0" & @CRLF)

$TimestampStart = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC
$logfile = FileOpen(@ScriptDir & "\" & $TimestampStart & ".log",2+32)
If @error Then
	ConsoleWrite("Error creating: " & @ScriptDir & "\" & $TimestampStart & ".log" & @CRLF)
	Exit
EndIf

If $cmdline[0] <> 1 Then ;No parameters passed
	$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
	If @error Then Exit
ElseIf FileExists($cmdline[1]) = 0 Then
	ConsoleWrite("Input file does not exist: " & $cmdline[1] & @CRLF)
	$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
	If @error Then Exit
Else
	$File = $cmdline[1]
EndIf

$OutFileUsnPages = $File&"."&$TimestampStart&".UsnJrnl"
If FileExists($OutFileUsnPages) Then
	_DebugOut("Error outfile exist: " & $OutFileUsnPages)
	Exit
EndIf

$FileSize = FileGetSize($File)
If $FileSize = 0 Then
	ConsoleWrite("Error retrieving file size" & @CRLF)
	Exit
EndIf

_DebugOut("Input: " & $File)
_DebugOut("Input filesize: " & $FileSize & " bytes")
_DebugOut("OutFileUsnPages: " & $OutFileUsnPages)
_DebugOut("USN_PAGE_SIZE configuration: " & $USN_Page_Size)

$hFile = _WinAPI_CreateFile("\\.\" & $File,2,2,7)
If $hFile = 0 Then
	_DebugOut("CreateFile error on " & $File & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf
$hFileOutUsnPages = _WinAPI_CreateFile("\\.\" & $OutFileUsnPages,3,6,7)
If $hFileOutUsnPages = 0 Then
	_DebugOut("CreateFile error on " & $OutFileUsnPages & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf

$rBuffer = DllStructCreate("byte ["&$USN_Page_Size&"]")
$sBuffer = DllStructCreate("byte [512]")
$JumpSize = 512
$SectorSize = $USN_Page_Size
$JumpForward = $USN_Page_Size/$JumpSize
$NextOffset = 0
$UsnPageCounter = 0
$nBytes1 = 0
$nBytes2 = 0
$Timerstart = TimerInit()
Do
	If IsInt(Mod(($NextOffset * $JumpSize),$FileSize)/1000000) Then ConsoleWrite(Round((($NextOffset * $JumpSize)/$FileSize)*100,2) & " %" & @CRLF)
	_WinAPI_SetFilePointerEx($hFile, $NextOffset*$JumpSize, $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($sBuffer), 512, $nBytes1)
	$TestChunk = DllStructGetData($sBuffer, 1)
	If StringMid($TestChunk,7,12) <> $UsnSignature Then
		$NextOffset+=1
		ContinueLoop
	EndIf

	$UsnJrnlRecordLength = StringMid($TestChunk,3,8)
	$UsnJrnlRecordLength = Dec(_SwapEndian($UsnJrnlRecordLength),2)
	If $UsnJrnlRecordLength > $USN_Page_Size Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlFileReferenceNumber = StringMid($TestChunk,19,12)
	$UsnJrnlFileReferenceNumber = Dec(_SwapEndian($UsnJrnlFileReferenceNumber),2)
	If $UsnJrnlFileReferenceNumber = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlMFTReferenceSeqNo = StringMid($TestChunk,31,4)
	$UsnJrnlMFTReferenceSeqNo = Dec(_SwapEndian($UsnJrnlMFTReferenceSeqNo),2)
	If $UsnJrnlMFTReferenceSeqNo = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlParentFileReferenceNumber = StringMid($TestChunk,35,12)
	$UsnJrnlParentFileReferenceNumber = Dec(_SwapEndian($UsnJrnlParentFileReferenceNumber),2)
	If $UsnJrnlParentFileReferenceNumber < 5 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlParentReferenceSeqNo = StringMid($TestChunk,47,4)
	$UsnJrnlParentReferenceSeqNo = Dec(_SwapEndian($UsnJrnlParentReferenceSeqNo),2)
	If $UsnJrnlParentReferenceSeqNo = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlUsn = StringMid($TestChunk,51,16)
	$UsnJrnlUsn = Dec(_SwapEndian($UsnJrnlUsn),2)
	If $UsnJrnlUsn = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf

	$UsnJrnlReason = StringMid($TestChunk,83,8)
	$UsnJrnlReason = Dec(_SwapEndian($UsnJrnlReason),2)
	If $UsnJrnlReason = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlFileNameLength = StringMid($TestChunk,115,4)
	$UsnJrnlFileNameLength = Dec(_SwapEndian($UsnJrnlFileNameLength),2)
	If $UsnJrnlFileNameLength = 0 Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$UsnJrnlFileNameOffset = StringMid($TestChunk,119,4)
	$UsnJrnlFileNameOffset = Dec(_SwapEndian($UsnJrnlFileNameOffset),2)
	If $UsnJrnlFileNameOffset <> 60 Then
		$NextOffset+=1
		ContinueLoop
	EndIf

	_WinAPI_SetFilePointerEx($hFile, $NextOffset*$JumpSize, $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($rBuffer), $SectorSize, $nBytes2)
	$Written = _WinAPI_WriteFile($hFileOutUsnPages, DllStructGetPtr($rBuffer), $SectorSize, $nBytes2)
	If $Written = 0 Then _DebugOut("WriteFile error on " & $OutFileUsnPages & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	$UsnPageCounter+=1

	$NextOffset+=$JumpForward
Until $NextOffset * $JumpSize >= $FileSize

_DebugOut("Job took " & _WinAPI_StrFromTimeInterval(TimerDiff($Timerstart)))
_DebugOut("Found Usn pages: " & $UsnPageCounter)

_WinAPI_CloseHandle($hFile)
_WinAPI_CloseHandle($hFileOutUsnPages)

FileClose($logfile)
If FileGetSize($OutFileUsnPages) = 0 Then FileDelete($OutFileUsnPages)
Exit

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf
    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")
    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)
    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf
    Return SetError(0, 0, DllStructGetData($tOut, 1))
EndFunc  ;==>_HexEncode

Func _DebugOut($text, $var="")
   If $var Then $var = _HexEncode($var) & @CRLF
   $text &= @CRLF & $var
   ConsoleWrite($text)
   If $logfile Then FileWrite($logfile, $text)
EndFunc
