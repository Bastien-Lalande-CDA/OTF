#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "src\Controller.ahk"

; OTF.ahk - Main script for OTF (Outil de Test de Flux)

; Global Configuration
global AppVersion := "1.0"
global AppName := "OTF"
global LogFile := A_ScriptDir . "\outputs\logs\otf.log"

; Main initialization
Main() {
    LogMessage("OTF started - v" . AppVersion)
    c := Controller()
    c.startScript()
}

LogMessage(msg) {
    timeStamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timeStamp . "] " . msg
    FileAppend(logEntry . "`n", LogFile)
}

Main()