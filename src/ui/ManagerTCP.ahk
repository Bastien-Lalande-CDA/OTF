#Requires AutoHotkey v2.0

#Include WindowOTF.ahk
#Include ../services/TCPserver.ahk

class ManagerTCP extends WindowOTF {
    servers := []

    /**
     * @description Adds a new TCP server to the servers list.
     * @param {String} [ip="0.0.0.0"] - IP address for the server.
     * @param {Number} [port=80] - Port for the server.
     * @returns {TCPServer} - The created TCP server instance.
     * @example <caption>Add a new TCP server.</caption>
     * server := ManagerTCP().AddServer("192.168.1.1", 8080)
     */
    AddServer(ip := "0.0.0.0", port := 80) {
        if (this.servers.Has(ip) && this.servers.Has(port)) {
            LogMessage("ERROR: Server with this IP and port already exists.")
        }

        server := TCPServer(ip, port)
        this.servers.Push(server)
        LogMessage("ManagerTCP.AddServer() completed. Server added. Params: ip=" . ip . ", port=" . port)
        return server
    }

    /**
     * @description Inserts a new TCP server at a specific index in the servers list.
     * @param {String} [ip="0.0.0.0"] - IP address for the server.
     * @param {Number} [port=80] - Port for the server.
     * @param {Number} [index=1] - Index at which to insert the server.
     * @returns {TCPServer} - The created TCP server instance.
     * @example <caption>Insert a new TCP server at index 1.</caption>
     * server := ManagerTCP().InsertServer("192.168.1.1", 8080, 1)
     */
    InsertServer(ip := "0.0.0.0", port := 80, index := 1) {
        if (this.servers.Has(ip) && this.servers.Has(port)) {
            LogMessage("ERROR: Server with this IP and port already exists.")
        }

        server := TCPServer(ip, port)
        this.servers.InsertAt(index, server)
        LogMessage("ManagerTCP.InsertServer() completed. Server inserted. Params: ip=" . ip . ", port=" . port . ", index=" . index)
        return server
    }

    /**
     * @description Removes a server by its ID and closes its socket.
     * @param {Number} index - The index of the server in the servers list.
     * @returns {void}
     * @example <caption>Remove server at index 0.</caption>
     * ManagerTCP().RemoveServer(0)
     */
    RemoveServer(index) {
        if !this.servers.Has(index) {
            LogMessage("ERROR: No server found with this id: " . index)
        }

        this.servers[index].Close()
        this.servers.RemoveAt(index)
        LogMessage("ManagerTCP.RemoveServer() completed. Server at index " . index . " removed and closed.")
    }

    /**
     * @description Opens a dialog for adding or editing a TCP server entry (IP and port).
     * @param {Array|String} [existingData=["",80]] - Optional existing data to pre-fill the form.
     * @returns {Array|Boolean} - Array of [ip, port] if valid, or `false` if cancelled.
     * @example <caption>Edit a TCP server entry.</caption>
     * tcpData := ManagerTCP().EditTCPEntry(["192.168.1.1", 8080])
     */
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
            catch {
                LogMessage("IP not found in dropdown, defaulting to first entry.")
                DDLIP.Choose(1)
            }

            EditPort.Value := existingData[2]
        } else {
            DDLIP.Choose(1)
        }

        BtnOK := editTCPEntryWindow.Add("Button", "Default xm+10 yp+40 w100", "OK")
        BtnOK.OnEvent("Click", AddEntry)

        editTCPEntryWindow.Show()

        /**
         * @description Validates if a given string is a valid IP address.
         * @param {String} ip - The IP address to validate.
         * @returns {Boolean} - `true` if valid, `false` otherwise.
         */
        IsValidIP(ip) {
            return RegExMatch(ip, "^(\d{1,3}\.){3}\d{1,3}$")
        }

        /**
         * @description Validates and processes the TCP entry form data.
         * @returns {void}
         */
        AddEntry(*) {
            if (DDLIP.Text = "" || EditPort.Value = "") {
                LogMessage("ERROR: Required fields are empty.")
                MsgBox("Champs obligatoires manquants")
                return
            }

            if (!IsValidIP(DDLIP.Text)) {
                LogMessage("ERROR: Invalid IP address provided.")
                MsgBox("IP invalide")
                return
            }

            if (!RegExMatch(EditPort.Value, "^\d+$") || Number(EditPort.Value) > 65536) {
                LogMessage("ERROR: Invalid port provided.")
                MsgBox("Port invalide")
                return
            }

            editTCPEntryWindow.Hide()
        }

        WinWaitClose(editTCPEntryWindow.Hwnd)

        if (DDLIP.Text = "" || EditPort.Value = "") {
            LogMessage("ManagerTCP.EditTCPEntry() completed. Returned: false (validation failed)")
            return false
        }

        result := [DDLIP.Text, EditPort.Value]
        LogMessage("ManagerTCP.EditTCPEntry() completed. Returned TCP entry data: " . result[1] . ":" . result[2])
        return result
    }

    /**
     * @description Opens a window for managing TCP servers (add, edit, delete, start, stop).
     * @returns {Boolean} - `true` if the window was closed properly.
     * @example <caption>Manage TCP servers.</caption>
     * ManagerTCP().ManageTCPServers()
     */
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

        /**
         * @description Adds a new server to the list and ListView.
         * @returns {void}
         */
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
                    LogMessage("New server added to ListView.")
                } else {
                    LogMessage("ERROR: Port already in use.")
                    MsgBox("Ce port est déja utilisé")
                }
            }
        }

        /**
         * @description Edits the selected server in the ListView.
         * @returns {void}
         */
        EditServer(*) {
            if !(row := LV.GetNext(0)) {
                LogMessage("ERROR: No row selected for editing.")
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                LogMessage("ERROR: Cannot edit, port used by another service.")
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                LogMessage("ERROR: Cannot edit running server.")
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

        /**
         * @description Deletes the selected server from the ListView and servers list.
         * @returns {void}
         */
        DeleteServer(*) {
            if !(row := LV.GetNext(0)) {
                LogMessage("ERROR: No row selected for deletion.")
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                LogMessage("ERROR: Cannot delete, port used by another service.")
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                LogMessage("ERROR: Cannot delete running server.")
                MsgBox("Stoppez le serveur")
                return
            }

            this.RemoveServer(row)
            LV.Delete(row)
        }

        /**
         * @description Starts the selected server.
         * @returns {void}
         */
        StartServer(*) {
            if !(row := LV.GetNext(0)){
                LogMessage("ERROR: No row selected for starting.")
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                LogMessage("ERROR: Cannot start, port used by another service.")
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            if (this.servers[row].IsRunning()){
                return
            }

            ; On récupère l'ID en colonne 1 même s'il est invisible
            ip       := LV.GetText(row, 1)
            port     := LV.GetText(row, 2)
            LogMessage("Starting server at IP: " . ip . ", Port: " . port)

            try {
                this.servers[row].Start()
                LV.Modify(row, , , , (this.servers[row].IsRunning())? "running" : "stopped")
            } catch Error as e {
                LogMessage("ERROR: Failed to start server. " . e.Message)
                MsgBox(e.Message . " at line : " . row)
            }
        }

        /**
         * @description Stops the selected server.
         * @returns {void}
         */
        StopServer(*) {
            if !(row := LV.GetNext(0)){
                LogMessage("ERROR: No row selected for stopping.")
                MsgBox("Sélectionne une ligne")
                return
            }

            if (LV.GetText(row, 3) = other_service_use_port_text) {
                LogMessage("ERROR: Cannot stop, port used by another service.")
                MsgBox("Vous ne pouvez pas utilisé cela, un autre service utilise ce port")
                return
            }

            try {
                this.servers[row].Close()
                LV.Modify(row, , , , (this.servers[row].IsRunning())? "running" : "stopped")
            } catch Error as e {
                LogMessage("ERROR: Failed to stop server. " . e.Message)
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