#Requires AutoHotkey v2.0
#SingleInstance Force

#Include src\Controller.ahk
#Include src\Globals.ahk

; OTF.ahk - Main script for OTF (Outil de Test de Flux)

; Main initialization
Main() {
    LogMessage("OTF started - v" . AppVersion)
    c := Controller()
    c.startScript()
}

Main()