#Requires AutoHotkey v2.0

; Global Configuration
global AppVersion := "2.0"
global AppName := "OTF"
global LogFile := A_ScriptDir . "\outputs\logs\otf.log"

; Créer les dossiers parents si nécessaire
if (!DirExist(A_ScriptDir . "\outputs")) {
    DirCreate(A_ScriptDir . "\outputs")
}
if (!DirExist(A_ScriptDir . "\outputs\logs")) {
    DirCreate(A_ScriptDir . "\outputs\logs")
}
; Créer le fichier s'il n'existe pas
if (!FileExist(LogFile)) {
    FileOpen(LogFile, "w").Close()
}

LogMessage(msg) {
    timeStamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timeStamp . "] " . msg
    FileAppend(logEntry . "`n", LogFile)
}