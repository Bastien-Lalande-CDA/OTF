#Requires AutoHotkey v2.0

class HMI extends Object {
    __Init() {
        TraySetIcon(A_ScriptDir . "\src\image\par-feu.png")
        this.window_title := AppName . " - v" . AppVersion
        this.window_height := 300
        this.window_width := 800
    }
    createWindow() {
        this.Window := Gui("-MinimizeBox -MaximizeBox", this.window_title)

        this.Window.Add("Picture", "h50 w-1", A_ScriptDir . "\src\image\logo-chantiers-atlantique.png")

        return this.Window
    }
    askDataType() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())
        
        window.Add("Text", "", "Sélectionez une option :")
        radio1 := window.Add("Radio", "vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := window.Add("Radio", "vDataType2", "Editer une matrice de flux")
        btn := this.Window.Add("Button", "xm w390 Default", "OK")

        btn.OnEvent("Click", (*) => window.Hide())

        window.Show()

        WinWaitClose(window.Hwnd)
        opt := 0
        if (radio1.Value) {
            opt := 1
        } else if (radio2.Value) {
            opt := 2
        }
        window.Destroy()
        return opt
    }
    askPath() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        path := ""

        window.Add("Text",, "Fichier sélectioné:")
        PathDisplay := window.Add("Edit", "w300 r1 ReadOnly", "Aucun fichier sélectionné...")
        BrowseBtn := window.Add("Button", "x+10 w80", "Parcourir")
        SubmitBtn := window.Add("Button", "xm w390 Default", "Confirmer la selection")

        BrowseBtn.OnEvent("Click", SelectFile)
        SubmitBtn.OnEvent("Click", ProcessFile)

        window.Show()

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
                window.Hide()
            }
        }

        WinWaitClose(window.Hwnd)
        window.Destroy()
        return path
    }
    getNewEntry(existingData := "") {

        window := this.createWindow()

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
        DDLProto    := window.Add("DropDownList", "vProtocol x+5 w70", ["TCP", "UDP", "ICMP", "TCP/UDP"])
        
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

    editMatrixData(input_data := []) {
        headers := ["nom_source","ip_source","nom_destination","ip_destination","port","protocole","nom_service","statut"]

        tab_headers := headers.Clone()
        tab_headers.RemoveAt(tab_headers.Length)

        window := this.createWindow()

        LV := window.Add("ListView", "r15 w600 Grid -Multi -ReadOnly", tab_headers)

        for row in input_data {
            LV.Add(, row*)
        }

        window.Add("Button", "w120", "Ajouter").OnEvent("Click", (*) => AddRow())
        window.Add("Button", "x+10 w120", "Modifier").OnEvent("Click", (*) => EditRow())
        window.Add("Button", "x+10 w120", "Supprimer").OnEvent("Click", (*) => DeleteSelected())
        window.Add("Button", "xm w600 Default", "Exécuter les tests").OnEvent("Click", ProcessData)

        window.OnEvent("Close", (*) => ExitApp())
        window.Show()

        AddRow(*) {
            data := this.getNewEntry()
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

            newData := this.getNewEntry(CurrentRowData) 

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
    showResults(data) {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        headers := data[1]
        rows := data[2]

        nb_of_success := 0
        for row in rows {
            if (row[8] = "Succès") {
                nb_of_success++
            }
        }

        main_txt := "Date: " . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  " . nb_of_success . "/"  . rows.Length . " tests réussis [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]"
        window.Add("Text",, main_txt)

        lv := window.Add("ListView", "r20 w800 Grid", headers)

        lv.Opt("-Redraw")
        for rowData in rows {
            lv.Add(, rowData*)
        }
        lv.Opt("+Redraw")

        lv.ModifyCol()

        CloseBtn := window.Add("Button", "xm w800 Default", "Enregistrer les résultats")
        CloseBtn.OnEvent("Click", (*) => window.Hide())

        window.Show()

        WinWaitClose(window.Hwnd)
        window.Destroy()
        return true
    }
    initLoadingScreen(totalTests) {
        this.window_loading := this.createWindow()
        this.window_loading.OnEvent("Close", (*) => ExitApp())

        this.window_loading.Add("Text", "vProgressText w300", "Progression :    0 / " . totalTests)
        progress := this.window_loading.Add("Progress", "vProgressBar w300 h20 cGreen Range-0-" . totalTests, 0)

        this.window_loading.Show()

        return this.window_loading
    }
    updateLoadingScreen(currentTest, totalTests) {
        this.window_loading["ProgressBar"].Value := currentTest
        this.window_loading["ProgressText"].Value := "Progression :     " . currentTest . " / " . totalTests
    }
    closeLoadingScreen() {
        if (this.window_loading) {
            this.window_loading.Hide()
            this.window_loading.Destroy()
        }
    }
}
