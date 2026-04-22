#Requires AutoHotkey v2.0

window := Gui("", "w400 h200")

window.Add("Text", "xm+10 yp+10 w40", "Serveurs TCP:")

window.Add("Text", "xm+10 yp+30 w40", "Sélect:")
DropDownIP := window.Add("DropDownList", "vSelectIP x+5 w120", SysGetIPAddresses())
DropDownIP.Choose(1)

window.Add("Text", "xm+10 yp+30 w40", "Port:")
EditPort := window.Add("Edit", "vPort x+5 w50")

window.Add("Button", "xm+10 yp+30 w80", "Ajouter").OnEvent("Click", (*) => AddTCPEntry())

AddTCPEntry(){
    window.Hide()
}

window.Show()

WinWaitClose(window.Hwnd)

return (DropDownIP.Value, EditPort.Value)
