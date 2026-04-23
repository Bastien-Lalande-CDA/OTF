#Requires AutoHotkey v2.0

#Include ../Globals.ahk

class TCPServer {
    /**
     * @description Constructor for the TCPServer class. Initializes IP, port, and socket-related properties.
     * @param {String} [ip="0.0.0.0"] - IP address to bind the server to.
     * @param {Number} [port=12345] - Port to listen on.
     * @returns {void}
     * @example <caption>Create a new TCPServer instance.</caption>
     * server := TCPServer("127.0.0.1", 8080)
     */
    __New(ip := "0.0.0.0", port := 12345) {
        this.ip := ip
        this.port := port
        this.listenSocket := 0
        this.clients := []
        this.timer := 0
    }

    /**
     * @description Starts the TCP server, initializes Winsock, creates a socket, binds it, and starts listening.
     * @returns {void}
     * @throws {Error} If WSAStartup or bind fails.
     * @example <caption>Start the TCP server.</caption>
     * server.Start()
     */
    Start() {

        ; Init Winsock
        wsa := Buffer(394)
        if (DllCall("ws2_32\WSAStartup", "UShort", 0x202, "Ptr", wsa) != 0) {
            LogMessage("ERROR in TCPServer.Start(): WSAStartup failed.")
            throw Error("WSAStartup failed")
        }

        ; Create socket
        this.listenSocket := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")

        ; Non-blocking
        mode := 1
        DllCall("ws2_32\ioctlsocket", "Ptr", this.listenSocket, "UInt", 0x8004667E, "UInt*", mode)

        ; Bind
        LogMessage("Binding socket to IP: " . this.ip . ", Port: " . this.port)
        addr := Buffer(16, 0)
        NumPut("UShort", 2, addr, 0)
        NumPut("UShort", this.htons(this.port), addr, 2)
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", this.ip, "UInt"), addr, 4)

        if (DllCall("ws2_32\bind", "Ptr", this.listenSocket, "Ptr", addr, "Int", 16) != 0) {
            LogMessage("ERROR in TCPServer.Start(): Bind failed.")
            throw Error("Bind failed")
        }

        DllCall("ws2_32\listen", "Ptr", this.listenSocket, "Int", 10)

        ; Timer loop
        this.timer := ObjBindMethod(this, "_loop")
        SetTimer(this.timer, 50)
        LogMessage("TCPServer.Start() completed.")
    }

    /**
     * @description Checks if the TCP server is currently running.
     * @returns {Boolean} - `true` if the server is running, `false` otherwise.
     * @example <caption>Check if the server is running.</caption>
     * isRunning := server.IsRunning()
     */
    IsRunning() {
        result := this.listenSocket != 0 && this.timer != 0
        return result
    }

    /**
     * @description Main loop for handling socket events (new connections, data reception).
     * @returns {void}
     * @example <caption>Internal method, called automatically by the timer.</caption>
     */
    _loop() {

        ; --- fd_set init ---
        fdset := Buffer(4 + (64 * A_PtrSize), 0)
        NumPut("UInt", 0, fdset, 0)

        ; Add listen socket (if valid)
        if (this.listenSocket) {
            this._fdsetAdd(fdset, this.listenSocket)
        }

        ; Add clients
        for client in this.clients {
            this._fdsetAdd(fdset, client)
        }

        ; --- timeout (non-blocking) ---
        tv := Buffer(8, 0)
        NumPut("Int", 0, tv, 0)
        NumPut("Int", 0, tv, 4)

        res := DllCall("ws2_32\select"
            , "Int", 0
            , "Ptr", fdset
            , "Ptr", 0
            , "Ptr", 0
            , "Ptr", tv)

        if (res <= 0) {
            return
        }

        ; === New client ===
        if (this.listenSocket && this._fdsetHas(fdset, this.listenSocket)) {
            LogMessage("New client connection detected.")
            clientAddr := Buffer(16, 0)
            len := 16

            client := DllCall("ws2_32\accept"
                , "Ptr", this.listenSocket
                , "Ptr", clientAddr
                , "Int*", len
                , "Ptr")

            if (client != -1) {
                this.clients.Push(client)
                LogMessage("Client connected. Total clients: " . this.clients.Length)
            }
        }

        ; === Clients data ===
        i := 1
        while (i <= this.clients.Length) {
            client := this.clients[i]

            if (this._fdsetHas(fdset, client)) {
                LogMessage("Data received from client: " . client)
                ; Buffer always initialized
                buf := Buffer(1024, 0)

                recv := DllCall("ws2_32\recv"
                    , "Ptr", client
                    , "Ptr", buf
                    , "Int", 1024
                    , "Int", 0)

                if (recv <= 0) {
                    ; Disconnect
                    LogMessage("Client disconnected: " . client)
                    DllCall("ws2_32\closesocket", "Ptr", client)
                    this.clients.RemoveAt(i)
                    continue
                }

                msg := StrGet(buf, recv, "UTF-8")
                LogMessage("Received: " . msg)

                ; Response
                response := "OK`n"
                DllCall("ws2_32\send"
                    , "Ptr", client
                    , "AStr", response
                    , "Int", StrLen(response)
                    , "Int", 0)
                LogMessage("Response sent to client: " . client)
            }

            i++
        }
    }

    /**
     * @description Closes the TCP server, all client connections, and cleans up Winsock.
     * @returns {void}
     * @example <caption>Close the TCP server.</caption>
     * server.Close()
     */
    Close() {

        if (this.timer) {
            SetTimer(this.timer, 0)
            this.timer := 0
            LogMessage("Timer stopped.")
        }

        for client in this.clients {
            DllCall("ws2_32\closesocket", "Ptr", client)
        }
        this.clients := []

        if (this.listenSocket) {
            DllCall("ws2_32\closesocket", "Ptr", this.listenSocket)
            this.listenSocket := 0
        }

        DllCall("ws2_32\WSACleanup")
        LogMessage("Winsock cleaned up. TCPServer.Close() completed.")
    }

    ; ===== Helpers =====

    /**
     * @description Adds a socket to an fd_set buffer.
     * @param {Buffer} fdset - The fd_set buffer.
     * @param {Ptr} sock - The socket to add.
     * @returns {void}
     * @example <caption>Internal helper method.</caption>
     * this._fdsetAdd(fdset, socket)
     */
    _fdsetAdd(fdset, sock) {
        count := NumGet(fdset, 0, "UInt")
        NumPut("UInt", count + 1, fdset, 0)
        NumPut("Ptr", sock, fdset, 4 + (count * A_PtrSize))
    }

    /**
     * @description Checks if a socket is present in an fd_set buffer.
     * @param {Buffer} fdset - The fd_set buffer.
     * @param {Ptr} sock - The socket to check.
     * @returns {Boolean} - `true` if the socket is in the fd_set, `false` otherwise.
     * @example <caption>Internal helper method.</caption>
     * hasSocket := this._fdsetHas(fdset, socket)
     */
    _fdsetHas(fdset, sock) {
        count := NumGet(fdset, 0, "UInt")
        Loop count {
            if (NumGet(fdset, 4 + ((A_Index - 1) * A_PtrSize), "Ptr") = sock) {
                return true
            }
        }
        return false
    }

    /**
     * @description Converts a port number from host byte order to network byte order.
     * @param {Number} p - The port number to convert.
     * @returns {Number} - The port number in network byte order.
     * @example <caption>Convert port 12345 to network byte order.</caption>
     * networkPort := this.htons(12345)
     */
    htons(p) {
        return ((p & 0xFF) << 8) | ((p >> 8) & 0xFF)
    }
}

class SocketManager {
    /**
     * @description Retrieves a list of all listening TCP sockets on the system.
     * @returns {Array} - Array of objects with `ip` and `port` properties for each listening socket.
     * @example <caption>Get all listening TCP sockets.</caption>
     * sockets := SocketManager().GetListeningSockets()
     */
    GetListeningSockets() {
        result := []

        AF_INET := 2
        TCP_TABLE_OWNER_PID_LISTENER := 3

        size := 0

        ; Get required size
        DllCall("iphlpapi\GetExtendedTcpTable"
            , "ptr", 0
            , "uint*", &size
            , "int", false
            , "int", AF_INET
            , "int", TCP_TABLE_OWNER_PID_LISTENER
            , "uint", 0)

        buf := Buffer(size, 0)

        ; Retrieve data
        if DllCall("iphlpapi\GetExtendedTcpTable"
            , "ptr", buf
            , "uint*", &size
            , "int", false
            , "int", AF_INET
            , "int", TCP_TABLE_OWNER_PID_LISTENER
            , "uint", 0) != 0
        {
            LogMessage("ERROR in SocketManager.GetListeningSockets(): Failed to retrieve TCP table.")
            return result
        }

        numEntries := NumGet(buf, 0, "uint")
        offset := 4

        LogMessage("Processing " . numEntries . " entries from TCP table.")
        loop numEntries {
            state      := NumGet(buf, offset + 0, "uint")
            localAddr  := NumGet(buf, offset + 4, "uint")
            localPort  := NumGet(buf, offset + 8, "uint")

            ; IP
            ip := Format("{:d}.{:d}.{:d}.{:d}"
                , localAddr & 0xFF
                , (localAddr >> 8) & 0xFF
                , (localAddr >> 16) & 0xFF
                , (localAddr >> 24) & 0xFF)

            ; Port (network -> host)
            port := ((localPort >> 8) & 0xFF) | ((localPort & 0xFF) << 8)

            result.Push({ ip: ip, port: port })

            offset += 24
        }

        LogMessage("SocketManager.GetListeningSockets() completed. Found " . result.Length . " listening sockets.")
        return result
    }
}