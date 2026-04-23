#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class ManagerMatrix extends WindowOTF {
    EditMatrixEntry(existingData := "") {

        window := WindowOTF()

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

        if (IsObject(existingData)) {
            EditSrcName.Value := existingData[1]
            EditSrcIP.Value   := existingData[2]
            EditDstName.Value := existingData[3]
            EditDstIP.Value   := existingData[4]
            EditPort.Value    := existingData[5]
            
            try DDLProto.Choose(existingData[6]) 
            catch
                DDLProto.Choose(1)
                
            EditService.Value := existingData[7]
        } else {
            EditSrcIP.Value := (SysGetIPAddresses().Length > 0) ? SysGetIPAddresses()[1] : ""
            DDLProto.Choose(1)
        }

        BtnAdd := window.Add("Button", "Default xm+10 yp+40 w100 h30", "OK")
        BtnAdd.OnEvent("Click", AddEntry)

        window.Show()

        IsValidIP(IP) {
            pattern := "^(\d{1,3}\.){3}\d{1,3}$"
            if (!RegExMatch(IP, pattern))
                return false
            loop Parse IP, "." {
                if (Number(A_LoopField) > 255)
                    return false
            }
            return true
        }

        IsNumber(value) {
            return IsInteger(value) || (value != "" && RegExMatch(value, "^\d+$"))
        }

        AddEntry(*) {
            if (EditSrcIP.Value = "" || EditDstIP.Value = "" || EditPort.Value = "" || DDLProto.Text = "") {
                MsgBox("Veuillez remplir les champs obligatoires.", "Erreur", "Icon! 4096")
                return
            }

            if (!IsValidIP(EditSrcIP.Value) || !IsValidIP(EditDstIP.Value)) {
                MsgBox("Veuillez entrer des adresses IP valides.", "Erreur")
                return
            }

            if (!IsNumber(EditPort.Value)) {
                MsgBox("Le port doit être un nombre.", "Erreur")
                return
            }

            window.Hide()
        }

        WinWaitClose(window.Hwnd)

        if (EditSrcIP.Value = "" || EditDstIP.Value = "" || EditPort.Value = "" || DDLProto.Text = "") {
            return false
        }

        return [EditSrcName.Value, EditSrcIP.Value, EditDstName.Value, EditDstIP.Value, EditPort.Value, DDLProto.Text, EditService.Value, "NON TESTÉ"]
    }
    
    GetFinalMatrix(input_data := []) {
        headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]

        tab_headers := headers.Clone()
        tab_headers.RemoveAt(tab_headers.Length)

        window := WindowOTF()

        LV := window.Add("ListView", "r15 w600 Grid -Multi -ReadOnly", tab_headers)

        for row in input_data {
            LV.Add(, row*)
        }
        LV.ModifyCol()

        window.Add("Button", "w120", "Ajouter").OnEvent("Click", (*) => AddRow())
        window.Add("Button", "x+10 w120", "Modifier").OnEvent("Click", (*) => EditRow())
        window.Add("Button", "x+10 w120", "Supprimer").OnEvent("Click", (*) => DeleteSelected())
        window.Add("Button", "xm w600 Default", "Exécuter les tests").OnEvent("Click", ProcessData)

        window.OnEvent("Close", (*) => ExitApp())
        window.Show()

        AddRow(*) {
            data := this.EditMatrixEntry()
            if (data) {
                LV.Add(, data*)
                LV.ModifyCol()
            }
        }

        EditRow(*) {
            if !(RowNum := LV.GetNext(0)) {
                MsgBox("Veuillez sélectionner une ligne à modifier.", "Info")
                return
            }

            CurrentRowData := []
            Loop headers.Length {
                CurrentRowData.Push(LV.GetText(RowNum, A_Index))
            }

            newData := this.EditMatrixEntry(CurrentRowData) 

            if (newData) {
                LV.Modify(RowNum, , newData*)
                LV.ModifyCol()
            }
        }

        DeleteSelected(*) {
            if RowNum := LV.GetNext(0)
                LV.Delete(RowNum)
            else
                MsgBox("Veuillez sélectionner une ligne à supprimer.", "Info")
        }

        ProcessData(*) {
            window.Hide()
        }

        WinWaitClose(window.Hwnd)
        SavedData := []
        Loop LV.GetCount() {
            RowIndex := A_Index
            RowDetails := []
            Loop headers.Length {
                RowDetails.Push(LV.GetText(RowIndex, A_Index))
            }
            SavedData.Push(RowDetails)
        }

        data_tab := [headers, SavedData]

        window.Destroy()
        return data_tab
    }
}