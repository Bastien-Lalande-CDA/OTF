#Requires AutoHotkey v2.0

; ==== Init ====
window_title := "VAPF"
TraySetIcon("src/pare-feu.png",,)
window_min_width := 600
window_min_height := 300




Window := Gui("+Resize +MinSize" . window_min_width . "x" . window_min_height, window_title)

FontFile := "src/Nulshock Bd.otf"

if FileExist(FontFile) DllCall("Gdi32.dll\AddFontResourceEx", "Str", FontFile, "UInt", 0x10, "UInt", 0)

Window.SetFont("s11", "Nulshock")

db_in_file_path := ""

; ==== Clean Closure ====

Window.OnEvent("Close", (*) => (
    DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", FontFile, "UInt", 0x10, "UInt", 0),
    ExitApp()
))








; ==== Main ====

Window.Show("X" . A_ScreenWidth/2 - window_min_width . " Y" . A_ScreenHeight/2 - window_min_height)