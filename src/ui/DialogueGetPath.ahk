#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class DialogueGetPath extends WindowOTF {
    /**
     * @description Opens a dialog window for selecting a file path. Allows the user to browse and confirm a file selection.
     * @returns {String} - The selected file path, or an empty string if no file was selected.
     * @example <caption>Open a file selection dialog.</caption>
     * selectedPath := DialogueGetPath().GetPath()
     */
    GetPath() {
        LogMessage("DialogueGetPath.GetPath() started.")

        CloseWindow() {
            LogMessage("DialogueGetPath window closed by user.")
            ExitApp()
        }

        this.OnEvent("Close", CloseWindow)

        path := ""
        LogMessage("Initializing file selection dialog UI.")

        this.Add("Text",, "Fichier sélectioné:")
        PathDisplay := this.Add("Edit", "w300 r1 ReadOnly", "Aucun fichier sélectionné...")
        BrowseBtn := this.Add("Button", "x+10 w80", "Parcourir")
        SubmitBtn := this.Add("Button", "xm w390 Default", "Confirmer la selection")

        LogMessage("UI elements added to dialog.")

        BrowseBtn.OnEvent("Click", SelectFile)
        SubmitBtn.OnEvent("Click", ProcessFile)

        this.Show()
        LogMessage("Dialog window displayed.")

        /**
         * @description Handles the file selection process when the "Browse" button is clicked.
         * @returns {void}
         */
        SelectFile(*) {
            LogMessage("Browse button clicked. Opening file selection dialog.")
            SelectedFile := FileSelect(3, , "Selectionnez un document", "Documents (*.txt; *.csv; *.docx)")
            if (SelectedFile != "") {
                PathDisplay.Value := SelectedFile
                LogMessage("File selected: " . SelectedFile)
            } else {
                LogMessage("File selection cancelled by user.")
            }
        }

        /**
         * @description Processes the selected file when the "Confirm" button is clicked.
         * @returns {void}
         */
        ProcessFile(*) {
            LogMessage("Confirm button clicked.")
            if (PathDisplay.Value = "Aucun fichier sélectionné...") {
                LogMessage("ERROR: No file selected.")
                MsgBox("Choisissez un fichier d'abord", "Erreur", "Icon!")
            } else {
                path := PathDisplay.Value
                LogMessage("File path confirmed: " . path)
                this.Hide()
            }
        }

        WinWaitClose(this.Hwnd)
        this.Destroy()
        LogMessage("DialogueGetPath.GetPath() completed. Returned path: " . (path != "" ? path : "empty"))

        return path
    }
}