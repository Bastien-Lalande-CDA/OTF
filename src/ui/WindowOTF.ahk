#Requires AutoHotkey v2.0

#Include ../Globals.ahk

class WindowOTF extends Gui {
    /**
     * @description Constructor for the WindowOTF class. Initializes a custom GUI window with a tray icon, title, and logo.
     * @returns {void}
     * @example <caption>Create a new WindowOTF instance.</caption>
     * window := WindowOTF()
     */
    __New(){
        LogMessage("WindowOTF.__New() started.")
        TraySetIcon(A_ScriptDir . "\src\image\par-feu.png")
        LogMessage("Tray icon set.")

        this.window_title := AppName . " - v" . AppVersion
        LogMessage("Window title set: " . this.window_title)

        super.__New("-MinimizeBox -MaximizeBox", this.window_title)
        LogMessage("Base GUI initialized with title: " . this.window_title)

        this.Add("Picture", "h20 w-1", A_ScriptDir . "\src\image\logo-chantiers-atlantique.png")
        LogMessage("Logo picture added to window.")

        LogMessage("WindowOTF.__New() completed.")
    }
}