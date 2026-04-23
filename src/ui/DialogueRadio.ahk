#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class DialogueRadio extends WindowOTF {
    /**
     * @description Opens a dialog window with radio buttons for selecting an option.
     * @returns {Number} - The selected option (1: Import CSV matrix, 2: Create new matrix, 3: Create TCP server).
     * @example <caption>Open a radio button dialog for option selection.</caption>
     * selectedOption := DialogueRadio().GetOpt()
     */
    GetOpt() {
        LogMessage("DialogueRadio.GetOpt() started.")

        CloseWindow(*) {
            LogMessage("DialogueRadio window closed by user.")
            ExitApp()
        }
        this.OnEvent("Close", CloseWindow)

        LogMessage("Adding UI elements to dialog.")
        this.Add("Text", "", "Sélectionez une option :")
        radio1 := this.Add("Radio", "vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := this.Add("Radio", "vDataType2", "Créer une nouvelle matrice de flux")
        radio3 := this.Add("Radio", "vDataType3", "Créer un serveur TCP")
        btn := this.Add("Button", "xm w390 Default", "OK")

        OkButton(*){
            LogMessage("OK button clicked. Hiding dialog.")
            this.Hide()
        }
        btn.OnEvent("Click", OkButton)

        this.Show()
        LogMessage("Dialog window displayed.")

        WinWaitClose(this.Hwnd)
        LogMessage("Waiting for window to close.")

        opt := 0
        if (radio1.Value) {
            opt := 1
            LogMessage("Option 1 selected: Import CSV matrix.")
        } else if (radio2.Value) {
            opt := 2
            LogMessage("Option 2 selected: Create new matrix.")
        } else if (radio3.Value) {
            opt := 3
            LogMessage("Option 3 selected: Create TCP server.")
        }

        this.Destroy()
        LogMessage("DialogueRadio.GetOpt() completed. Returned option: " . opt)
        return opt
    }
}