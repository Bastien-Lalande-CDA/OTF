#Requires AutoHotkey v2.0

#Include Globals.ahk
#Include TCPservers.ahk

class HMI extends Object {
    __Init() {
        TraySetIcon(A_ScriptDir . "\src\image\par-feu.png")
        this.window_title := AppName . " - v" . AppVersion
        this.window_height := 300
        this.window_width := 800
    }
    createWindow() {
        this.Window := Gui("-MinimizeBox -MaximizeBox", this.window_title)

        this.Window.Add("Picture", "h20 w-1", A_ScriptDir . "\src\image\logo-chantiers-atlantique.png")

        return this.Window
    }
    askDataType() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())
        
        window.Add("Text", "", "Sélectionez une option :")
        radio1 := window.Add("Radio", "vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := window.Add("Radio", "vDataType2", "Créer une nouvelle matrice de flux")
        radio3 := window.Add("Radio", "vDataType3", "Créer un server TCP")
        btn := this.Window.Add("Button", "xm w390 Default", "OK")

        btn.OnEvent("Click", (*) => window.Hide())

        window.Show()

        WinWaitClose(window.Hwnd)
        opt := 0
        if (radio1.Value) {
            opt := 1
        } else if (radio2.Value) {
            opt := 2
        } else if (radio3.Value) {
            opt := 3
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
    EditMatrixEntry(existingData := "") {

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

    editMatrixData(input_data := []) {
        headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]

        tab_headers := headers.Clone()
        tab_headers.RemoveAt(tab_headers.Length)

        window := this.createWindow()

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
    showResults(data) {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        headers := data[1]

        rows := data[2]

        SortArray(rows, CompareStatus, 8)

        CompareStatus(a, b, col) {
            order := Map("Success", 1, "Sent/Open", 2, "Failed", 3, "NOT TESTED (IP MISMATCH)", 4)
            return order[a[col]] - order[b[col]]
        }

        SortArray(arr, cmp, col) {
            len := arr.Length
            Loop len - 1 {
                i := A_Index
                Loop len - i {
                    j := A_Index
                    if (cmp(arr[j], arr[j+1], col) > 0) {
                        temp := arr[j]
                        arr[j] := arr[j+1]
                        arr[j+1] := temp
                    }
                }
            }
        }
    

        nb_of_success := 0
        nb_of_fail := 0
        for row in rows {
            if (row[8] = "Success") {
                nb_of_success++
            }
            if (row[8] = "Failed") {
                nb_of_fail++
            }
        }

        main_txt := "Date: " 
        . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  " 
        . nb_of_success . "/"  . rows.Length . " tests réussis [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]" . "  |  " 
        . nb_of_fail . "/"  . rows.Length . " échecs [" . Format("{:.2f}", (nb_of_fail / rows.Length) * 100) . "%]"
        window.Add("Text",, main_txt)

        lv := window.Add("ListView", "r20 w800 Grid NoSortHdr NoSort", headers)

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


    manageTCPServers() {
        this.tcpManager := TCPServers()
        gui := this.createWindow()

        LV_width := 600

        LV := gui.Add("ListView", "w" . LV_width . " h200 Grid -Multi -ReadOnly",
            ["IP", "Port", "Status"])

        LV.ModifyCol(1, LV_width/3-3)
        LV.ModifyCol(2, LV_width/3-3)
        LV.ModifyCol(3, LV_width/3-3)

        btnAdd    := gui.Add("Button", "w100", "Ajouter")
        btnEdit   := gui.Add("Button", "x+10 w100", "Modifier")
        btnDelete := gui.Add("Button", "x+10 w100", "Supprimer")
        btnStart  := gui.Add("Button", "xm w100", "Start")
        btnStop   := gui.Add("Button", "x+10 w100", "Stop")

        gui.Show()

        ; ===== Actions =====

        AddServer(*) {
            row := LV.GetCount()+1
            data := this.EditTCPEntry()
            if (data) {
                row_exist := false
                for server IN this.tcpManager.servers {
                    if (server.ip = data[1] && server.port = data[2]) {
                        row_exist := true
                    }
                }
                if !row_exist {
                    this.tcpManager.Add(data[1], data[2])
                    LV.Add(, data[1], data[2], (this.tcpManager.servers[row].IsRunning())? "running" : "stopped")
                } else {
                    MsgBox("Ce serveur TCP existe déja")
                }
            }
        }

        EditServer(*) {
            if !(row := LV.GetNext(0)) {
                MsgBox("Sélectionne une ligne")
                return
            }

            if (this.tcpManager.servers[row].IsRunning()){
                MsgBox("Stoppez le serveur")
                return
            }

            current := [
                LV.GetText(row, 1), ; IP
                LV.GetText(row, 2)  ; Port
            ]

            data := this.EditTCPEntry(current)

            if (data) {
                this.tcpManager.Remove(row)
                this.tcpManager.Insert(data[1], data[2], row)
                LV.Modify(row, , data[1], data[2], (this.tcpManager.servers[row].IsRunning())? "running" : "stopped")
            }
        }

        DeleteServer(*) {
            if !(row := LV.GetNext(0)) {
                MsgBox("Sélectionne une ligne")
                return
            }

            if (this.tcpManager.servers[row].IsRunning()){
                MsgBox("Stoppez le serveur")
                return
            }
            
            this.tcpManager.Remove(row)

            LV.Delete(row)
        }

        StartServer(*) {
            if !(row := LV.GetNext(0)){
                MsgBox("Sélectionne une ligne")
                return
            }
            if (this.tcpManager.servers[row].IsRunning()){
                return
            }
            ; On récupère l'ID en colonne 1 même s'il est invisible
            ip       := LV.GetText(row, 1)
            port     := LV.GetText(row, 2)

            try {
                this.tcpManager.servers[row].Start()
                LV.Modify(row, , , , (this.tcpManager.servers[row].IsRunning())? "running" : "stopped")
            } catch Error as e {
                MsgBox(e.Message . " at line : " . row)
            }
        }

        StopServer(*) {
            if !(row := LV.GetNext(0)){
                MsgBox("Sélectionne une ligne")
                return
            }

            if (!this.tcpManager.servers[row].IsRunning()){
                return
            }

            try {
                this.tcpManager.servers[row].Close()
                LV.Modify(row, , , , (this.tcpManager.servers[row].IsRunning())? "running" : "stopped")
            } catch Error as e {
                MsgBox(e.Message . " at line : " . row)
            }
        }

        ; ===== Events =====

        btnAdd.OnEvent("Click", (*) => AddServer())
        btnEdit.OnEvent("Click", (*) => EditServer())
        btnDelete.OnEvent("Click", (*) => DeleteServer())
        btnStart.OnEvent("Click", (*) => StartServer())
        btnStop.OnEvent("Click", (*) => StopServer())

        WinWaitClose(gui.Hwnd)
        return true
    }

    EditTCPEntry(existingData := ["",80]) {
        window := this.createWindow()

        window.Add("GroupBox", "r4 w300", "Serveur TCP")

        window.Add("Text", "xp+10 yp+25 w40", "IP:")
        DDLIP := window.Add("DropDownList", "x+5 w150", SysGetIPAddresses())

        window.Add("Text", "xm+10 yp+30 w40", "Port:")
        EditPort := window.Add("Edit", "x+5 w80")

        ; Pré-remplissage
        if (IsObject(existingData)) {
            try DDLIP.Choose(DDLIP.FindString(existingData[1]))
            catch 
                DDLIP.Choose(1)

            EditPort.Value := existingData[2]
        } else {
            DDLIP.Choose(1)
        }

        BtnOK := window.Add("Button", "Default xm+10 yp+40 w100", "OK")
        BtnOK.OnEvent("Click", AddEntry)

        window.Show()

        ; ===== Validation =====

        IsValidIP(ip) {
            return RegExMatch(ip, "^(\d{1,3}\.){3}\d{1,3}$")
        }

        AddEntry(*) {
            if (DDLIP.Text = "" || EditPort.Value = "") {
                MsgBox("Champs obligatoires manquants")
                return
            }

            if (!IsValidIP(DDLIP.Text)) {
                MsgBox("IP invalide")
                return
            }

            if (!RegExMatch(EditPort.Value, "^\d+$") || Number(EditPort.Value) > 65536) {
                MsgBox("Port invalide")
                return
            }

            window.Hide()
        }

        WinWaitClose(window.Hwnd)

        if (DDLIP.Text = "" || EditPort.Value = "")
            return false

        return [DDLIP.Text, EditPort.Value]
    }
}


