#Requires AutoHotkey v2.0

; Global Configuration
global AppVersion := "3.0"
global AppName := "OTF"
global LogFile := A_ScriptDir . "\outputs\logs\otf.log"

/**
 * @description Logs a message with a timestamp to the specified log file.
 * @param {String} msg - The message to log.
 * @returns {void}
 * @example <caption>Log an informational message.</caption>
 * LogMessage("Application started")
 */
LogMessage(msg) {
    timeStamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timeStamp . "] " . msg
    FileAppend(logEntry . "`n", LogFile)
}