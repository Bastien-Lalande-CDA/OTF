#Requires AutoHotkey v2.0

; Global Configuration
global AppVersion := "1.0"
global AppName := "OTF"
global LogFile := A_ScriptDir . "\outputs\logs\otf.log"

LogMessage(msg) {
    timeStamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timeStamp . "] " . msg
    FileAppend(logEntry . "`n", LogFile)
}