#Requires AutoHotkey v2.0

#Include ../Globals.ahk

class TCPServer {
    __New(ip := "0.0.0.0", port := 12345) {
        this.ip := ip
        this.port := port
        this.listenSocket := 0
        this.clients := []
        this.timer := 0
    }

    Start() {
        ; Init Winsock
        wsa := Buffer(394)
        if (DllCall("ws2_32\WSAStartup", "UShort", 0x202, "Ptr", wsa) != 0)
            throw Error("WSAStartup failed")

        ; Create socket
        this.listenSocket := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")

        ; Non-blocking
        mode := 1
        DllCall("ws2_32\ioctlsocket", "Ptr", this.listenSocket, "UInt", 0x8004667E, "UInt*", mode)

        ; Bind
        addr := Buffer(16, 0)
        NumPut("UShort", 2, addr, 0)
        NumPut("UShort", this.htons(this.port), addr, 2)
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", this.ip, "UInt"), addr, 4)

        if (DllCall("ws2_32\bind", "Ptr", this.listenSocket, "Ptr", addr, "Int", 16) != 0)
            throw Error("Bind failed")

        DllCall("ws2_32\listen", "Ptr", this.listenSocket, "Int", 10)

        ; Timer loop
        this.timer := ObjBindMethod(this, "_loop")
        SetTimer(this.timer, 50)
    }

    IsRunning() {
        return this.listenSocket != 0 && this.timer != 0
    }

    _loop() {
        ; --- fd_set init ---
        fdset := Buffer(4 + (64 * A_PtrSize), 0)
        NumPut("UInt", 0, fdset, 0)

        ; add listen socket (si valide)
        if (this.listenSocket)
            this._fdsetAdd(fdset, this.listenSocket)

        ; add clients
        for client in this.clients
            this._fdsetAdd(fdset, client)

        ; --- timeout (non bloquant) ---
        tv := Buffer(8, 0)
        NumPut("Int", 0, tv, 0)
        NumPut("Int", 0, tv, 4)

        res := DllCall("ws2_32\select"
            , "Int", 0
            , "Ptr", fdset
            , "Ptr", 0
            , "Ptr", 0
            , "Ptr", tv
        )

        if (res <= 0)
            return

        ; === new client ===
        if (this.listenSocket && this._fdsetHas(fdset, this.listenSocket)) {
            clientAddr := Buffer(16, 0)
            len := 16

            client := DllCall("ws2_32\accept"
                , "Ptr", this.listenSocket
                , "Ptr", clientAddr
                , "Int*", len
                , "Ptr")

            if (client != -1) {
                this.clients.Push(client)
                LogMessage("Client connecté")
            }
        }

        ; === clients data ===
        i := 1
        while (i <= this.clients.Length) {
            client := this.clients[i]

            if (this._fdsetHas(fdset, client)) {
                ; ✅ buffer toujours initialisé
                buf := Buffer(1024, 0)

                recv := DllCall("ws2_32\recv"
                    , "Ptr", client
                    , "Ptr", buf
                    , "Int", 1024
                    , "Int", 0)

                if (recv <= 0) {
                    ; disconnect
                    DllCall("ws2_32\closesocket", "Ptr", client)
                    this.clients.RemoveAt(i)
                    continue
                }

                msg := StrGet(buf, recv, "UTF-8")
                LogMessage("Reçu: " msg)

                ; réponse
                response := "OK`n"
                DllCall("ws2_32\send"
                    , "Ptr", client
                    , "AStr", response
                    , "Int", StrLen(response)
                    , "Int", 0)
            }

            i++
        }
    }

    Close() {
        if (this.timer) {
            SetTimer(this.timer, 0)
            this.timer := 0
        }

        for client in this.clients
            DllCall("ws2_32\closesocket", "Ptr", client)

        this.clients := []

        if (this.listenSocket) {
            DllCall("ws2_32\closesocket", "Ptr", this.listenSocket)
            this.listenSocket := 0
        }

        DllCall("ws2_32\WSACleanup")
    }

    ; ===== Helpers =====

    _fdsetAdd(fdset, sock) {
        count := NumGet(fdset, 0, "UInt")
        NumPut("UInt", count + 1, fdset, 0)
        NumPut("Ptr", sock, fdset, 4 + (count * A_PtrSize))
    }

    _fdsetHas(fdset, sock) {
        count := NumGet(fdset, 0, "UInt")
        Loop count {
            if (NumGet(fdset, 4 + ((A_Index - 1) * A_PtrSize), "Ptr") = sock)
                return true
        }
        return false
    }

    htons(p) {
        return ((p & 0xFF) << 8) | ((p >> 8) & 0xFF)
    }
}