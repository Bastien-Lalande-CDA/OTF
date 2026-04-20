#Requires AutoHotkey v2.0

#Include Globals.ahk

class TestsEngine {
    
    executeTest(data, my_ips) { 
        ; Structure : source_name[1];source_ip[2];dest_name[3];dest_ip[4];port[5];protocol[6];service[7];status[8]
        source_ip := data[2]
        dest_ip   := data[4]
        port      := data[5]
        protocol  := StrUpper(data[6]) ; Standardized v2 function for uppercase

        ; 1. Verify if the source IP is one of ours
        found := false
        for index, value in my_ips {
            if (value = source_ip) {
                found := true
                break
            }
        }

        ; FIX: Removed the restrictive InStr(protocol, "TCP") check that was skipping UDP/ICMP
        if (!found) {
            data[8] := "NOT TESTED (IP MISMATCH)"
            return data
        }

        status := "Failed"

        try {
            switch protocol {
                case "TCP":
                    status := this.TestTCP(dest_ip, port) ? "Success" : "Failed"
                
                case "UDP":
                    status := this.TestUDP(dest_ip, port) ? "Sent/Open" : "Failed"
                
                case "ICMP", "PING":
                    status := this.TestICMP(dest_ip) ? "Success" : "Failed"
                
                default:
                    status := "UNKNOWN PROTOCOL"
            }
        } catch Any as e {
            status := "Error: " . e.Message
        }

        data[8] := status
        
        if (status != "Success" && status != "Sent/Open") {
            try LogMessage("Test " . protocol . " failed for " . dest_ip . ":" . port)
        }

        return data
    }

    ; --- OPTIMIZED NETWORKING FUNCTIONS ---

    TestTCP(ip, port, timeout := 500) {
        ; Initialize Winsock once per call (or move to __New for better performance)
        static WSADATA := Buffer(400)
        if DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA)
            return false
        
        ; Création du Socket TCP
        s := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr") ; AF_INET, SOCK_STREAM, IPPROTO_TCP
        if (s = -1) {
            DllCall("ws2_32\WSACleanup")
            return false
        }

        ; Setup sockaddr structure
        sockaddr := Buffer(16, 0)
        NumPut("Short", 2, sockaddr, 0)
        NumPut("UShort", DllCall("ws2_32\htons", "UShort", port), sockaddr, 2) ; Port
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", ip), sockaddr, 4) ; IP address

        ; Set non-blocking mode
        arg := Buffer(4), NumPut("UInt", 1, arg)
        DllCall("ws2_32\ioctlsocket", "Ptr", s, "Int", 0x8004667E, "Ptr", arg) 

        DllCall("ws2_32\connect", "Ptr", s, "Ptr", sockaddr, "Int", 16) ; tentative de connexion non bloquante

        ; Setup select() for timeout
        writefds := Buffer(520, 0)  ; fd_set structure: DWORD fd_count + 64 sockets (Ptr each)
        NumPut("UInt", 1, writefds, 0)
        NumPut("Ptr", s, writefds, 8)
        
        timeval := Buffer(8, 0)
        NumPut("Int", 0, timeval, 0), NumPut("Int", timeout * 1000, timeval, 4)

        res := DllCall("ws2_32\select", "Int", 0, "Ptr", 0, "Ptr", writefds, "Ptr", 0, "Ptr", timeval)
        
        ; Cleanup
        DllCall("ws2_32\closesocket", "Ptr", s)
        DllCall("ws2_32\WSACleanup")
        return (res > 0)
    }

    TestICMP(ip) {
        ; Use ComSpec for a cleaner hidden execution
        return (RunWait(A_ComSpec ' /c ping -n 1 -w 500 ' . ip, , "Hide") = 0)
    }

    TestUDP(ip, port) {
        static WSADATA := Buffer(400)
        DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA)
        
        s := DllCall("ws2_32\socket", "Int", 2, "Int", 2, "Int", 17, "Ptr") ; SOCK_DGRAM, IPPROTO_UDP
        
        sockaddr := Buffer(16, 0)
        NumPut("Short", 2, sockaddr, 0)
        NumPut("UShort", DllCall("ws2_32\htons", "UShort", port), sockaddr, 2)
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", ip), sockaddr, 4)

        ; Note: UDP connect only checks if the local stack can reach the destination route.
        ; It does not "handshake" like TCP.
        res := DllCall("ws2_32\connect", "Ptr", s, "Ptr", sockaddr, "Int", 16)
        
        DllCall("ws2_32\closesocket", "Ptr", s)
        DllCall("ws2_32\WSACleanup")
        return (res = 0)
    }
}