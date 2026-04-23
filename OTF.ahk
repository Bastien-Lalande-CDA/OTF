#Requires AutoHotkey v2.0
#SingleInstance Force

#Include src/controllers/Controller.ahk
#Include src/Globals.ahk

; OTF.ahk - Main script for OTF (Outil de Test de Flux)

; Create directories if they don't exist
if (!DirExist(A_ScriptDir . "\outputs")) {
    DirCreate(A_ScriptDir . "\outputs")
}
if (!DirExist(A_ScriptDir . "\outputs\logs")) {
    DirCreate(A_ScriptDir . "\outputs\logs")
}
; Create the log file if it doesn't exist
if (!FileExist(LogFile)) {
    FileOpen(LogFile, "w").Close()
}

/**
 * @description Main entry point for the OTF script. Initializes the application and starts the controller.
 * @returns {void}
 * @example <caption>Start the OTF script.</caption>
 * Main()
 */
Main() {
    LogMessage("OTF started - v" . AppVersion)

    Controller().startScript()
    LogMessage("Program completed.")
}

Main()