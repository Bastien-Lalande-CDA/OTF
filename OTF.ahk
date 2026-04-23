#Requires AutoHotkey v2.0
#SingleInstance Force

#Include src/controllers/Controller.ahk
#Include src/Globals.ahk

; OTF.ahk - Main script for OTF (Outil de Test de Flux)

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

; Main initialization
Main() {
    LogMessage("OTF started - v" . AppVersion)
    c := Controller()
    c.startScript()
}

Main()