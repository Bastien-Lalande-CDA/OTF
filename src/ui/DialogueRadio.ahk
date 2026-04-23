#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class DialogueRadio extends WindowOTF {
    GetOpt() {
        this.OnEvent("Close", (*) => ExitApp())
        this.Add("Text", "", "Sélectionez une option :")
        radio1 := this.Add("Radio", "vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := this.Add("Radio", "vDataType2", "Créer une nouvelle matrice de flux")
        radio3 := this.Add("Radio", "vDataType3", "Créer un serveur TCP")
        btn := this.Add("Button", "xm w390 Default", "OK")

        btn.OnEvent("Click", (*) => this.Hide())

        this.Show()

        WinWaitClose(this.Hwnd)
        opt := 0
        if (radio1.Value) {
            opt := 1
        } else if (radio2.Value) {
            opt := 2
        } else if (radio3.Value) {
            opt := 3
        }
        this.Destroy()
        return opt
    }
}