#Requires AutoHotkey v2.0

#Include WindowOTF.ahk
#Include ../services/TCPserver.ahk

class ManagerTCP extends WindowOTF {

    servers := []

    AddServer(ip := "0.0.0.0", port := 80) {
        if (this.servers.Has(ip) && this.servers.Has(port))
            LogMessage("Server with this name already exists")

        server := TCPServer(ip, port)
        this.servers.Push(server)
        return server
    }

    InsertServer(ip := "0.0.0.0", port := 80, index := 1) {
        if (this.servers.Has(ip) && this.servers.Has(port))
            LogMessage("Server with this name already exists")

        server := TCPServer(ip, port)
        this.servers.InsertAt(index, server)
        return server
    }

    GetServer(id) {
        if !this.servers.Has(id)
            LogMessage("No server found with this id")

        return this.servers[id]
    }

    RemoveServer(id) {
        if !this.servers.Has(id)
            LogMessage("No server found with this id")

        this.servers[id].Close()
        this.servers.RemoveAt(id)
    }
    
    EditTCPEntry(existingData := ["",80]) {

        editTCPEntryWindow := WindowOTF()

        editTCPEntryWindow.Add("GroupBox", "r4 w300", "Serveur TCP")

        editTCPEntryWindow.Add("Text", "xp+10 yp+25 w40", "IP:")
        DDLIP := editTCPEntryWindow.Add("DropDownList", "x+5 w150", SysGetIPAddresses())

        editTCPEntryWindow.Add("Text", "xm+10 yp+30 w40", "Port:")
        EditPort := editTCPEntryWindow.Add("Edit", "x+5 w80")

        ; Pré-remplissage
        if (IsObject(existingData)) {
            try DDLIP.Choose(DDLIP.FindString(existingData[1]))
            catch 
                DDLIP.Choose(1)

            EditPort.Value := existingData[2]
        } else {
            DDLIP.Choose(1)
        }

        BtnOK := editTCPEntryWindow.Add("Button", "Default xm+10 yp+40 w100", "OK")
        BtnOK.OnEvent("Click", AddEntry)

        editTCPEntryWindow.Show()

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

            editTCPEntryWindow.Hide()
        }

        WinWaitClose(editTCPEntryWindow.Hwnd)

        if (DDLIP.Text = "" || EditPort.Value = "")
            return false

        return [DDLIP.Text, EditPort.Value]
    }
    ManageTCPServers() {
        
        for sock in SocketManager().GetListeningSockets() {
            this.AddServer(sock.ip, sock.port)
        }

        LV_width := 600

        LV := this.Add("ListView", "w" . LV_width . " h200 Grid -Multi -ReadOnly 0x8000",
            ["IP", "Port", "Status"])

        LV.ModifyCol(1, LV_width // 3-3)
        LV.ModifyCol(2, LV_width // 3-3)
        LV.ModifyCol(3, LV_width // 3-3)

        other_service_use_port_text := "An other service use this port"

        for server IN this.servers {
            LV.Add(, server.ip, server.port, other_service_use_port_text)
        }

        btnAdd    := this.Add("Button", "w100", "Ajouter")
        btnEdit   := this.Add("Button", "x+10 w100", "Modifier")
        btnDelete := this.Add("Button", "x+10 w100", "Supprimer")
        btnStart  := this.Add("Button", "xm w100", "Start")
        btnStop   := this.Add("Button", "x+10 w100", "Stop")

        this.Show()

        ; ===== Actions =====

        AddServer(*) {
            row := LV.GetCount()+1
            data := this.EditTCPEntry()
            if (data) {
                row_exist := false
                for server IN this.servers {
                    if (server.port = data[2]) {
                        row_exist := true
                    }
                }
                if !row_exist {
                    this.AddServer(data[1], data[2])
                    LV.Add(, data[1], data[2], (this.servers[row].IsRunning())? "running" : "stopped")
                } else {
                    MsgBox("Ce port est déja utilisé")
                }
            }
        }

        EditServer(*) {
            if !(row := LV.GetNext(0)) {
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                MsgBox("Stoppez le serveur")
                return
            }

            current := [
                LV.GetText(row, 1), ; IP
                LV.GetText(row, 2)  ; Port
            ]

            data := this.EditTCPEntry(current)

            if (data) {
                this.RemoveServer(row)
                this.InsertServer(data[1], data[2], row)
                LV.Modify(row, , data[1], data[2], (this.servers[row].IsRunning())? "running" : "stopped")
            }
        }

        DeleteServer(*) {
            if !(row := LV.GetNext(0)) {
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                MsgBox("Stoppez le serveur")
                return
            }
            
            this.RemoveServer(row)

            LV.Delete(row)
        }

        StartServer(*) {
            if !(row := LV.GetNext(0)){
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                return
            }

            ; On récupère l'ID en colonne 1 même s'il est invisible
            ip       := LV.GetText(row, 1)
            port     := LV.GetText(row, 2)

            try {
                this.servers[row].Start()
                LV.Modify(row, , , , (this.servers[row].IsRunning())? "running" : "stopped")
            } catch Error as e {
                MsgBox(e.Message . " at line : " . row)
            }
        }

        StopServer(*) {
            if !(row := LV.GetNext(0)){
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            try {
                this.servers[row].Close()
                LV.Modify(row, , , , (this.servers[row].IsRunning())? "running" : "stopped")
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

        WinWaitClose(this.Hwnd)
        return true
    }
}