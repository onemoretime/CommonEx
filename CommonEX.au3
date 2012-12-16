#Region Header

#include-once

; #INDEX# =======================================================================================================================
; Title .............: Common Functions
; Filename...........: CommonEX.au3
; AutoIt Version ....: 3.3++
; Requirements ......: AutoIt v3.3 +
; Uses...............:
; Language ..........: English
; Description .......: Common functions for heavy dev in AutoIt. For example: read a config files, debug in a log file, ...
; Author(s) .........: onemoretime
; Notes .............:
; Available Functions:
;		_Common_Log
;		_Common_SendLog
;		_Common_RaiseError
;		_Common_ReadConfig
; ===============================================================================================================================

#include <Date.au3>

#EndRegion Header

#Region Initialization

#EndRegion Initialization

#Region Global Variables and Constants
Global $fDebugLevel, $sConfigLogFilePath, $sLogFilePath

#EndRegion Global Variables and Constants

#Region Local Variables and Constants
Local $sDefaultLogFilePath = @ScriptDir & "\unconfiguredLogFile.log"
#EndRegion Local Variables and Constants

#Region Public Functions
; #FUNCTION# ====================================================================================================================
; Name...........: _Common_Log
; Description....: Format and send a message in logfile
; Syntax.........: _Common_Debug ( $sLevel, $sMessage )
; Parameters.....: $sLevel    - Set the debug level for $sMessage - One of the following:
;				   | debug    = log a debug level message. Need $fDebugLevel sets at 1
;				   | info     = log an info message
;				   | warning  = log a warning error
;				   | critical = log a critical error
;				   | fatal    = log a fatal error
;                  $sMessage  - Set the message
; Return values..: Nothing
; Author.........: onemoretime
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Todo...........: Add a mechanism to prevent infinite loop
; Example........: Yes
; ===============================================================================================================================

Func _Common_Log($sLevel,$sMessage)
	; The format of a log is as follows :
	; <mm/dd/yyyy hh:mm:ss> - <log type> - <message>
	Local $sLogPrefix = ""
	Local $sPreservedLevel
	Local $tCur, $sEventDateTime

	; Set the date & time of the log
	$tCur = _Date_Time_GetLocalTime()
	$sEventDateTime = _Date_Time_SystemTimeToDateTimeStr($tCur)

	; Check if the $sConfigLogFilePath is set.
	; if not, use $sDefaultLogFilePath
	If Not ($sConfigLogFilePath = "") Then
		$sLogFilePath = $sConfigLogFilePath
	Else
		$sLogFilePath = $sDefaultLogFilePath
	EndIf
	If Not FileExists($sLogFilePath) Then
		; Create and Initialize LogFile
		$hLogFile = FileOpen($sLogFilePath,2)
		FileClose($hLogFile)
	EndIf

	; Set the prefix $sLogPrefix for the message
	Select
		Case StringLower($sLevel) = "debug"
			$sLogPrefix = " - [DEBUG] - "
		Case StringLower($sLevel) = "info"
			$sLogPrefix = " - [INFO] - "
		Case StringLower($sLevel) = "warning"
			$sLogPrefix = " - [WARN] - "
		Case StringLower($sLevel) = "critical"
			$sLogPrefix = " - [CRIT] - "
		Case StringLower($sLevel) = "fatal"
			$sLogPrefix = " - [FATAL] - "
		Case Else
			; set the $sLevel at a warning level
			; add a error message for the unkown level set
			$sPreservedLevel = $sLevel
			$sLevel = "warning"
			_Common_Log($sLevel,"Unknown error level set : " & $sPreservedLevel _
								& ". Please reconsider your code. The log message was set as following:")
			_Common_Log($sLevel, $sMessage)
			_Common_Log($sLevel,"End of unknown error.")
	EndSelect

	; Now open the logFile in append mode
	$hLogFile = FileOpen($sLogFilePath,1)
	; WriteLine the message
	FileWriteLine($hLogFile,$sEventDateTime & $sLogPrefix & $sMessage)

	FileClose($hLogFile)
	Return 1
EndFunc   ;==>_Common_Log

; #FUNCTION# ====================================================================================================================
; Name...........: _Common_SplashLog
; Description....: Send the logfile to splashText (see AutoIt Function) if $fDebugLevel set.
; Syntax.........: _Common_SplashLog ()
; Parameters.....: None required. Require a config file
; Return values..: Nothing
; Author.........: onemoretime
; Modified.......:
; Remarks........: maybe discard in future
; Related........:
; Link...........:
; Todo...........:
; Example........: No
; ===============================================================================================================================
Func _Common_SplashLog()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Common_SendLog
; Description....: Send the logfile to an email address
; Syntax.........: _Common_SendLog ()
; Parameters.....: None required. Require a config file
; Return values..: Nothing
; Author.........: onemoretime
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Todo...........:
; Example........: Yes
; ===============================================================================================================================
Func _Common_SendLog()
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _Common_RaiseError
; Description....: Set a used defined error
; Syntax.........: _Common_RaiseError ( $sLevel, $sMessage )
; Parameters.....: $sLevel    - Set the debug level for $sMessage - One of the following:
;				   | debug    = Need $fDebugLevel sets at 1
;				   | info     = log an info
;				   | warning  = log a warning
;				   | critical = log and ask if we want to continue the prog
;				   | fatal    = log and terminate the prog
;                  $sMessage  - Set the message
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: onemoretime
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Todo...........: Add a mechanism to prevent infinite loop
; Example........: Yes
; ===============================================================================================================================

Func _Common_RaiseError($sLevel,$sMessage)
	Local $iCriticalAnswer
	Select
		Case StringLower($sLevel) = "debug"
			_Common_Log($sLevel, $sMessage)
		Case StringLower($sLevel) = "info"
			_Common_Log($sLevel, $sMessage)
		Case StringLower($sLevel) = "warning"
			_Common_Log($sLevel, $sMessage)
		Case StringLower($sLevel) = "critical"
			_Common_Log($sLevel, $sMessage)
			; The user must choose to continue or not
			$iCriticalAnswer = MsgBox(36, "Continue ?", "The application encounter a critical problem" & @CRLF & _
									 "Do you want to continue and ignore the problem ?")
			If $iCriticalAnswer = 6 Then		; The answer is "Yes"
				_Common_RaiseError("Info","Continue on user choice. See previous critical error")
			ElseIf $iCriticalAnswer = 7 Then	; The answer is "No"
				_Common_RaiseError("Fatal","Halted on user choice. See previous critical error")
			EndIf

		Case StringLower($sLevel) = "fatal"
			_Common_Log($sLevel, $sMessage)
			MsgBox(0,"Fatal Error !",$sMessage & @CRLF & "The script will be stopped.")
			Exit -1
		Case Else
			; set the $sLevel at a warning level
			; add a error message for the unkown level set
			Local $sPreservedLevel = $sLevel
			$sLevel = "warning"
			_Common_Log($sLevel,"Unknown error level set : " & $sPreservedLevel _
								& ". Please reconsider your code. The error was as following:")
			_Common_Log($sLevel, $sMessage)
			_Common_Log($sLevel,"End of unknown error.")
	EndSelect

	Return 1
EndFunc   ;==>_Common_RaiseError

; #FUNCTION# ====================================================================================================================
; Name...........: _Common_ReadConfig
; Description....: Read a config file and initialize global variables. Config file are .ini compliant.
; Syntax.........: _Common_ReadConfig ( [$sIniSection] [, $sIniVariable = ""] )
; Parameters.....: $sIniSection  - the section name to read.
;                  $sIniVariable - the variable name to read.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: onemoretime
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Todo...........:
; Example........: Yes
; ===============================================================================================================================
Func _Common_ReadConfig( $sIniSection = "", $sIniVariable ="")

EndFunc


#EndRegion Public Functions

#Region Embedded DLL Functions
#EndRegion Embedded DLL Functions

#Region Internal Functions
#EndRegion Internal Functions

