#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "src\Controller.ahk"

; VAPF.ahk - Main script for VAPF (Vérifiaction Automatisé du Pare-Feu)

; Global Configuration
global AppVersion := "1.0"
global AppName := "VAPF"
global LogFile := A_ScriptDir . "\outputs\logs\vapf.log"

; Main initialization
Main() {
    LogMessage("VAPF started - v" . AppVersion)
    c := Controller()
    c.startScript()
}

LogMessage(msg) {
    timeStamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timeStamp . "] " . msg
    FileAppend(logEntry . "`n", LogFile)
}

Main()