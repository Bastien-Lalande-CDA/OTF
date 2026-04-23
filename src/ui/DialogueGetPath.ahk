#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class DialogueGetPath extends WindowOTF {
    GetPath() {
        this.OnEvent("Close", (*) => ExitApp())

        path := ""

        this.Add("Text",, "Fichier sélectioné:")
        PathDisplay := this.Add("Edit", "w300 r1 ReadOnly", "Aucun fichier sélectionné...")
        BrowseBtn := this.Add("Button", "x+10 w80", "Parcourir")
        SubmitBtn := this.Add("Button", "xm w390 Default", "Confirmer la selection")

        BrowseBtn.OnEvent("Click", SelectFile)
        SubmitBtn.OnEvent("Click", ProcessFile)

        this.Show()

        SelectFile(*) {
            SelectedFile := FileSelect(3, , "Selectionnez un document", "Documents (*.txt; *.csv; *.docx)")
            if (SelectedFile != "") {
                PathDisplay.Value := SelectedFile
            }
        }

        ProcessFile(*) {
            if (PathDisplay.Value = "Aucun fichier sélectionné...") {
                MsgBox("Choisissez un fichier d'abord", "Erreur", "Icon!")
            } else {
                path := PathDisplay.Value
                this.Hide()
            }
        }

        WinWaitClose(this.Hwnd)
        this.Destroy()
        return path
    }
}