#include <MsgBoxConstants.au3>
#include <File.au3>
#include <Array.au3>

const $fileProperty = "properties.ini"

Dim $autoSaveFrequence = Int(IniRead($fileProperty, "AUTO SAVE", "frequence", "600000"))
Dim $doRetrySave = Int(IniRead($fileProperty, "AUTO SAVE", "retry", "1"))
Dim $retrySaveDelay = Int(IniRead($fileProperty, "AUTO SAVE", "retry_delay", "10000"))

Dim $doBackups = Int(IniRead($fileProperty, "BACKUPS", "enabled", "1"))
Dim $backupCounts = Int(IniRead($fileProperty, "BACKUPS", "count", "3"))
Dim $region = IniRead($fileProperty, "BACKUPS", "region", "")

Dim $regionDir = @MyDocumentsDir & "\SimCity 4\Regions\" & $region
Dim $backupDir = @MyDocumentsDir & "\SimCity 4\Regions\" & $region & "_backups"

If ( $doBackups ) then
	If ( StringLen($region) == 0 ) then
		MsgBox(0, "Error", "No region. "  & @CRLF & "Edit properties.ini file."  & @CRLF & "Closing")
		Exit (1)
	EndIf

	If Not( FileExists($regionDir) ) then
		MsgBox(0, "Error", "Region does not exist. "  & @CRLF & "Edit properties.ini file."  & @CRLF & "Closing")
		Exit (1)
	EndIf

EndIf


init()

Func init ()
	MsgBox(0, "Launched", "Program launched.")
	; Init stuff
	if($doBackups) Then
		If Not(FileExists($backupDir)) Then
			DirCreate($backupDir)
		EndIf
	EndIf

	While 1
		While 1
			Local $ActiveWindow = WinGetHandle("[active]")
			Local $ActiveWindowPid = WinGetProcess($ActiveWindow)
			Local $ActiveWindowProcessName = _Findpidname($ActiveWindowPid)

			if( ($doRetrySave == 1) And $ActiveWindowProcessName <> "SimCity 4.exe" ) Then ; -- If Window is not active, wait and try again.
				Sleep($retrySaveDelay)
			Else
				ExitLoop(1)
			EndIf
		WEnd
		Send("^s")
		if($doBackups) Then
			createBackups($regionDir, $backupDir, $backupCounts)
		EndIf

		Sleep($autoSaveFrequence)
		If Not ProcessExists ("SimCity 4.exe") then ExitLoop(1)
	WEnd

	MsgBox(0, "Ended", "Program endend.")

EndFunc


Func createBackups ($regionDir, $backupDir, $count)

	Dim $backupsFiles = _FileListToArray($backupDir, "*", 2, True)

	Dim $length = UBound($backupsFiles) - 1;

	_ArrayDelete($backupsFiles, 0)

	if ($length >= $count) Then
		_ArrayReverse($backupsFiles)
		For $i = ($count -1) to $length - 1
			DirRemove($backupsFiles[$i])
		Next
	EndIf

	Dim $backupDestinationDirectory = $backupDir & "\" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "h" & @MIN

	DirCopy($regionDir, $backupDestinationDirectory, 1)

EndFunc

Func _Findpidname($Pid)
	Local $Processlist = ProcessList()
	For $i = 1 To $Processlist[0][0]
		If $Processlist[$i][1] = $Pid Then Return $Processlist[$i][0]
	Next
EndFunc   ;==>_Findpidname
