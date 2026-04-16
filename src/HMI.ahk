#Requires AutoHotkey v2.0

class HMI extends Object {
    __Init() {
        TraySetIcon(A_ScriptDir . "\src\par-feu.png")
        this.window_title := AppName . " - v" . AppVersion
        this.window_height := 300
        this.window_width := 800
    }
    createWindow() {
        this.Window := Gui("-MinimizeBox -MaximizeBox", this.window_title)
        return this.Window
    }
    askDataType() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())
        
        window.Add("Text", "x10 y10 w200 h20", "Sélectionez une option:")
        radio1 := window.Add("Radio", "x10 y40 w200 h20 vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := window.Add("Radio", "x10 y70 w200 h20 vDataType2", "Editer une matrice de flux")
        btn := this.Window.Add("Button", "xm w390 Default", "OK")

        btn.OnEvent("Click", (*) => window.Hide()) ; submitt button

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

        window.Add("Text",, "Selected File:")
        PathDisplay := window.Add("Edit", "w300 r1 ReadOnly", "Aucun fichier sélectionné...")
        BrowseBtn := window.Add("Button", "x+10 w80", "Browse")
        SubmitBtn := window.Add("Button", "xm w390 Default", "Confirm Selection")

        BrowseBtn.OnEvent("Click", SelectFile)
        SubmitBtn.OnEvent("Click", ProcessFile)

        window.Show()

        SelectFile(*) {
            SelectedFile := FileSelect(3, , "Select a file", "Documents (*.txt; *.csv; *.docx)")
            if (SelectedFile != "") {
                PathDisplay.Value := SelectedFile
            }
        }

        ProcessFile(*) {
            if (PathDisplay.Value = "Aucun fichier sélectionné...") {
                MsgBox("Choisisez un fichier dabord", "Error", "Icon!")
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

        ; --- Création de la fenêtre principale ---
        this.window := this.createWindow()

        ; --- Section Saisie (Inputs) ---
        this.window.Add("GroupBox", "r6 w620", "Ajouter une nouvelle entrée")
        
        this.window.Add("Text", "xp+10 yp+25 w80", "Source Name:")
        EditSrcName := this.window.Add("Edit", "vSrcName x+5 w120")
        
        this.window.Add("Text", "x+20 w60", "Source IP:")
        EditSrcIP   := this.window.Add("Edit", "vSrcIP x+5 w120")
        
        this.window.Add("Text", "xm+10 yp+30 w80", "Dest. Name:")
        EditDstName := this.window.Add("Edit", "vDstName x+5 w120")
        
        this.window.Add("Text", "x+20 w60", "Dest. IP:")
        EditDstIP   := this.window.Add("Edit", "vDstIP x+5 w120")

        this.window.Add("Text", "xm+10 yp+30 w40", "Port:")
        EditPort    := this.window.Add("Edit", "vPort x+5 w50")
        
        this.window.Add("Text", "x+15 w60", "Protocol:")
        DDLProto    := this.window.Add("DropDownList", "vProtocol x+5 w70", ["TCP", "UDP", "ICMP", "TCP/UDP"])
        
        this.window.Add("Text", "x+15 w50", "Service:")
        EditService := this.window.Add("Edit", "vService x+5 w100")

        ; --- Logique de pré-remplissage ---
        if (IsObject(existingData)) {
            ; Si on passe un tableau (format correspondant au return de cette fonction)
            EditSrcName.Value := existingData[1]
            EditSrcIP.Value   := existingData[2]
            EditDstName.Value := existingData[3]
            EditDstIP.Value   := existingData[4]
            EditPort.Value    := existingData[5]
            
            ; Pour le DropDownList, on cherche l'index correspondant au texte
            try DDLProto.Choose(existingData[6]) 
            catch
                DDLProto.Choose(1) ; Valeur par défaut si non trouvé
                
            EditService.Value := existingData[7]
        } else {
            ; Valeurs par défaut pour une nouvelle entrée
            EditSrcIP.Value := (SysGetIPAddresses().Length > 0) ? SysGetIPAddresses()[1] : ""
            DDLProto.Choose(1)
        }

        BtnAdd := this.window.Add("Button", "Default xm+10 yp+40 w100 h30", "OK")
        BtnAdd.OnEvent("Click", AddEntry)

        this.window.Show()

        ; --- Fonctions internes ---

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
                MsgBox("Veuillez entrer des adresses IP valides.")
                return
            }

            if (!IsNumber(EditPort.Value)) {
                MsgBox("Le port doit être un nombre.")
                return
            }

            this.window.Hide()
        }

        WinWaitClose(this.window.Hwnd)
        return [EditSrcName.Value, EditSrcIP.Value, EditDstName.Value, EditDstIP.Value, EditPort.Value, DDLProto.Text, EditService.Value, "NOT TESTED"]
    }

    askMatrixData() {
        headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]

        tab_headers := headers.Clone()
        tab_headers.RemoveAt(tab_headers.Length)

        window := this.createWindow()

        ; Ajout de -ReadOnly pour plus de flexibilité (optionnel)
        LV := window.Add("ListView", "r15 w600 Grid -Multi -ReadOnly", tab_headers)

        ; --- Boutons de contrôle ---
        window.Add("Button", "w120", "Ajouter").OnEvent("Click", (*) => AddRow())
        
        ; Nouveau bouton Modifier
        window.Add("Button", "x+10 w120", "Modifier").OnEvent("Click", (*) => EditRow())
        
        window.Add("Button", "x+10 w120", "Supprimer").OnEvent("Click", (*) => DeleteSelected())
        window.Add("Button", "xm w600 Default", "Suivant").OnEvent("Click", ProcessData)

        window.OnEvent("Close", (*) => ExitApp())
        window.Show()

        ; --- Fonctions Internes ---

        AddRow(*) {
            data := this.getNewEntry() ; Appelle votre dialogue de saisie vide
            if (data) {
                LV.Add(, data*)
                LV.ModifyCol()
            }
        }

        EditRow(*) {
            if !(RowNum := LV.GetNext(0)) {
                MsgBox("Veuillez sélectionner une ligne à modifier.", "Info", "Iconi")
                return
            }

            ; 1. Récupérer les données actuelles de la ligne
            CurrentRowData := []
            Loop headers.Length {
                CurrentRowData.Push(LV.GetText(RowNum, A_Index))
            }

            ; 2. Appeler getNewEntry avec les données actuelles pour pré-remplir le formulaire
            ; Note : Vous devrez adapter votre méthode getNewEntry pour accepter un paramètre optionnel
            newData := this.getNewEntry(CurrentRowData) 

            if (newData) {
                ; 3. Mettre à jour la ligne existante
                LV.Modify(RowNum, , newData*)
                LV.ModifyCol()
            }
        }

        DeleteSelected(*) {
            if RowNum := LV.GetNext(0)
                LV.Delete(RowNum)
            else
                MsgBox("Veuillez sélectionner une ligne à supprimer.", "Info", "Iconi")
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
            if (row[8] = "Success") {
                nb_of_success++
            }
        }

        main_txt := "Date: " . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  " . nb_of_success . "/"  . rows.Length . " tests passées avec succès [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]"
        window.Add("Text",, main_txt)

        lv := window.Add("ListView", "r20 w800 Grid", headers)

        lv.Opt("-Redraw") ; Performance boost while loading
        for rowData in rows {
            lv.Add(, rowData*) ; The * operator spreads the array into parameters
        }
        lv.Opt("+Redraw")

        lv.ModifyCol()

        CloseBtn := window.Add("Button", "xm w800 Default", "Enregister les résultats")
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