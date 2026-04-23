#Requires AutoHotkey v2.0

#Include ../Globals.ahk

class WindowOTF extends Gui {
    __Init(){
        TraySetIcon(A_ScriptDir . "\src\image\par-feu.png")
        this.window_title := AppName . " - v" . AppVersion
        this := Gui("-MinimizeBox -MaximizeBox", this.window_title)
        this.Add("Picture", "h20 w-1", A_ScriptDir . "\src\image\logo-chantiers-atlantique.png")
    }
}