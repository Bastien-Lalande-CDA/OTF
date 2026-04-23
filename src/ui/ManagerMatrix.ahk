#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class ManagerMatrix extends WindowOTF {
    /**
     * @description Opens a dialog for adding or editing a matrix entry (source/destination IP, port, protocol, etc.).
     * @param {Array|String} [existingData=""] - Optional existing data to pre-fill the form.
     * @returns {Array|Boolean} - Array of entry data if valid, or `false` if cancelled.
     * @example <caption>Edit a matrix entry with existing data.</caption>
     * entryData := ManagerMatrix().EditMatrixEntry(["Source1", "192.168.1.1", "Dest1", "192.168.1.2", "80", "TCP", "HTTP"])
     */
    EditMatrixEntry(existingData := "") {
        LogMessage("ManagerMatrix.EditMatrixEntry() started. Params: existingData=" . (IsObject(existingData) ? "object" : existingData))

        window := WindowOTF()
        LogMessage("Creating matrix entry window.")

        window.Add("GroupBox", "r6 w620", "Ajouter une nouvelle entrée")

        window.Add("Text", "xp+10 yp+25 w80", "Nom Source:")
        EditSrcName := window.Add("Edit", "vSrcName x+5 w120")

        window.Add("Text", "x+20 w60", "IP Source:")
        EditSrcIP   := window.Add("Edit", "vSrcIP x+5 w120")

        window.Add("Text", "xm+10 yp+30 w80", "Nom Dest.:")
        EditDstName := window.Add("Edit", "vDstName x+5 w120")

        window.Add("Text", "x+20 w60", "IP Dest.:")
        EditDstIP   := window.Add("Edit", "vDstIP x+5 w120")

        window.Add("Text", "xm+10 yp+30 w40", "Port:")
        EditPort    := window.Add("Edit", "vPort x+5 w50")

        window.Add("Text", "x+15 w60", "Protocole:")
        DDLProto    := window.Add("DropDownList", "vProtocol x+5 w70", ["TCP", "UDP", "ICMP"])

        window.Add("Text", "x+15 w50", "Service:")
        EditService := window.Add("Edit", "vService x+5 w100")

        LogMessage("UI elements added to matrix entry window.")

        if (IsObject(existingData)) {
            LogMessage("Pre-filling form with existing data.")
            EditSrcName.Value := existingData[1]
            EditSrcIP.Value   := existingData[2]
            EditDstName.Value := existingData[3]
            EditDstIP.Value   := existingData[4]
            EditPort.Value    := existingData[5]

            try DDLProto.Choose(existingData[6])
            catch {
                LogMessage("Protocol not found in dropdown, defaulting to TCP.")
                DDLProto.Choose(1)
            }

            EditService.Value := existingData[7]
        } else {
            LogMessage("No existing data provided. Using defaults.")
            EditSrcIP.Value := (SysGetIPAddresses().Length > 0) ? SysGetIPAddresses()[1] : ""
            DDLProto.Choose(1)
        }

        BtnAdd := window.Add("Button", "Default xm+10 yp+40 w100 h30", "OK")
        BtnAdd.OnEvent("Click", AddEntry)

        window.Show()
        LogMessage("Matrix entry window displayed.")

        /**
         * @description Validates if a given string is a valid IP address.
         * @param {String} IP - The IP address to validate.
         * @returns {Boolean} - `true` if valid, `false` otherwise.
         */
        IsValidIP(IP) {
            pattern := "^(\d{1,3}\.){3}\d{1,3}$"
            if (!RegExMatch(IP, pattern)) {
                return false
            }
            loop Parse IP, "." {
                if (Number(A_LoopField) > 255) {
                    return false
                }
            }
            return true
        }

        /**
         * @description Checks if a value is a valid number.
         * @param {String} value - The value to check.
         * @returns {Boolean} - `true` if valid, `false` otherwise.
         */
        IsNumber(value) {
            return IsInteger(value) || (value != "" && RegExMatch(value, "^\d+$"))
        }

        /**
         * @description Validates and processes the entry form data.
         * @returns {void}
         */
        AddEntry(*) {
            LogMessage("AddEntry() started. Validating form data.")
            if (EditSrcIP.Value = "" || EditDstIP.Value = "" || EditPort.Value = "" || DDLProto.Text = "") {
                LogMessage("ERROR: Required fields are empty.")
                MsgBox("Veuillez remplir les champs obligatoires.", "Erreur", "Icon! 4096")
                return
            }

            if (!IsValidIP(EditSrcIP.Value) || !IsValidIP(EditDstIP.Value)) {
                LogMessage("ERROR: Invalid IP addresses provided.")
                MsgBox("Veuillez entrer des adresses IP valides.", "Erreur")
                return
            }

            if (!IsNumber(EditPort.Value)) {
                LogMessage("ERROR: Port is not a number.")
                MsgBox("Le port doit être un nombre.", "Erreur")
                return
            }

            LogMessage("Form data validated. Hiding window.")
            window.Hide()
        }

        WinWaitClose(window.Hwnd)
        LogMessage("Waiting for window to close.")

        if (EditSrcIP.Value = "" || EditDstIP.Value = "" || EditPort.Value = "" || DDLProto.Text = "") {
            LogMessage("ManagerMatrix.EditMatrixEntry() completed. Returned: false (validation failed)")
            return false
        }

        result := [EditSrcName.Value, EditSrcIP.Value, EditDstName.Value, EditDstIP.Value, EditPort.Value, DDLProto.Text, EditService.Value, "NON TESTÉ"]
        LogMessage("ManagerMatrix.EditMatrixEntry() completed. Returned entry data.")
        return result
    }

    /**
     * @description Opens a window for managing a matrix of test entries (add, edit, delete, execute).
     * @param {Array} [input_data=[]] - Optional input data to preload in the matrix.
     * @returns {Array} - Array containing [headers, data] for the final matrix.
     * @example <caption>Get final matrix data with preloaded input.</caption>
     * matrixData := ManagerMatrix().GetFinalMatrix([["Header1", "Header2"], ["Value1", "Value2"]])
     */
    GetFinalMatrix(input_data := []) {
        LogMessage("ManagerMatrix.GetFinalMatrix() started. Params: input_data length=" . input_data.Length)

        headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]
        LogMessage("Headers defined for matrix.")

        tab_headers := headers.Clone()
        tab_headers.RemoveAt(tab_headers.Length)

        window := WindowOTF()
        LogMessage("Creating matrix management window.")

        LV := window.Add("ListView", "r15 w600 Grid -Multi -ReadOnly", tab_headers)
        LogMessage("ListView added to window.")

        for row in input_data {
            LV.Add(, row*)
        }
        LV.ModifyCol()
        LogMessage("Input data loaded into ListView.")

        window.Add("Button", "w120", "Ajouter").OnEvent("Click", (*) => AddRow())
        window.Add("Button", "x+10 w120", "Modifier").OnEvent("Click", (*) => EditRow())
        window.Add("Button", "x+10 w120", "Supprimer").OnEvent("Click", (*) => DeleteSelected())
        window.Add("Button", "xm w600 Default", "Exécuter les tests").OnEvent("Click", ProcessData)

        CloseWindow(*) {
            LogMessage("Matrix management window closed by user.")
            ExitApp()
        }
        window.OnEvent("Close", CloseWindow)
        window.Show()
        LogMessage("Matrix management window displayed.")

        /**
         * @description Adds a new row to the matrix.
         * @returns {void}
         */
        AddRow(*) {
            LogMessage("AddRow() started.")
            data := this.EditMatrixEntry()
            if (data) {
                LV.Add(, data*)
                LV.ModifyCol()
                LogMessage("New row added to ListView.")
            }
        }

        /**
         * @description Edits the selected row in the matrix.
         * @returns {void}
         */
        EditRow(*) {
            LogMessage("EditRow() started.")
            if !(RowNum := LV.GetNext(0)) {
                LogMessage("No row selected for editing.")
                MsgBox("Veuillez sélectionner une ligne à modifier.", "Info")
                return
            }

            CurrentRowData := []
            Loop headers.Length {
                CurrentRowData.Push(LV.GetText(RowNum, A_Index))
            }
            LogMessage("Current row data retrieved for editing.")

            newData := this.EditMatrixEntry(CurrentRowData)

            if (newData) {
                LV.Modify(RowNum, , newData*)
                LV.ModifyCol()
                LogMessage("Row updated in ListView.")
            }
        }

        /**
         * @description Deletes the selected row from the matrix.
         * @returns {void}
         */
        DeleteSelected(*) {
            LogMessage("DeleteSelected() started.")
            if RowNum := LV.GetNext(0) {
                LV.Delete(RowNum)
                LogMessage("Selected row deleted.")
            } else {
                LogMessage("No row selected for deletion.")
                MsgBox("Veuillez sélectionner une ligne à supprimer.", "Info")
            }
        }

        /**
         * @description Processes the matrix data and hides the window.
         * @returns {void}
         */
        ProcessData(*) {
            LogMessage("ProcessData() started. Hiding window.")
            window.Hide()
        }

        WinWaitClose(window.Hwnd)
        LogMessage("Waiting for window to close.")

        SavedData := []
        Loop LV.GetCount() {
            RowIndex := A_Index
            RowDetails := []
            Loop headers.Length {
                RowDetails.Push(LV.GetText(RowIndex, A_Index))
            }
            SavedData.Push(RowDetails)
        }
        LogMessage("Matrix data saved. Total rows: " . SavedData.Length)

        data_tab := [headers, SavedData]
        LogMessage("ManagerMatrix.GetFinalMatrix() completed. Returned matrix data.")

        window.Destroy()
        return data_tab
    }
}