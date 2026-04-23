#Requires AutoHotkey v2.0

#Include ../Globals.ahk

class TestsEngine {

    /**
     * @description Executes a network test based on the provided data and available IPs.
     * @param {Array} data - Array containing test parameters: [source_name, source_ip, dest_name, dest_ip, port, protocol, service_name, status].
     * @param {Array} my_ips - Array of local IP addresses to validate against.
     * @returns {Array} - The modified data array with updated status.
     * @example <caption>Execute a TCP test.</caption>
     * result := TestsEngine().executeTest(["", "192.168.1.1", "", "8.8.8.8", "53", "TCP", "", ""], ["192.168.1.1"])
     */
    executeTest(data, my_ips) {
        LogMessage("TestsEngine.executeTest() started. Params: dest_ip=" . data[4] . ", port=" . data[5] . ", protocol=" . data[6])

        ; Structure : source_name[1];source_ip[2];dest_name[3];dest_ip[4];port[5];protocol[6];service[7];status[8]
        source_ip := data[2]
        dest_ip   := data[4]
        port      := data[5]
        protocol  := StrUpper(data[6]) ; Standardized v2 function for uppercase
        LogMessage("Test parameters extracted: source_ip=" . source_ip . ", dest_ip=" . dest_ip . ", port=" . port . ", protocol=" . protocol)

        ; 1. Verify if the source IP is one of ours
        found := false
        for index, value in my_ips {
            if (value = source_ip) {
                found := true
                break
            }
        }
        LogMessage("Source IP validation: " . (found ? "IP matched" : "IP not matched"))

        ; FIX: Removed the restrictive InStr(protocol, "TCP") check that was skipping UDP/ICMP
        if (!found) {
            data[8] := "NOT TESTED (IP MISMATCH)"
            LogMessage("TestsEngine.executeTest() completed. Status: " . data[8])
            return data
        }

        status := "Failed"
        LogMessage("Starting test execution for protocol: " . protocol)

        try {
            switch protocol {
                case "TCP":
                    status := this.TestTCP(dest_ip, port) ? "Success" : "Failed"
                    LogMessage("TCP test result: " . status)

                case "UDP":
                    status := this.TestUDP(dest_ip, port) ? "Sent/Open" : "Failed"
                    LogMessage("UDP test result: " . status)

                case "ICMP", "PING":
                    status := this.TestICMP(dest_ip) ? "Success" : "Failed"
                    LogMessage("ICMP test result: " . status)

                default:
                    status := "UNKNOWN PROTOCOL"
                    LogMessage("Unknown protocol: " . protocol)
            }
        } catch Any as e {
            status := "Error: " . e.Message
            LogMessage("ERROR in TestsEngine.executeTest(): " . status)
        }

        data[8] := status
        LogMessage("Test status updated: " . status)

        if (status != "Success" && status != "Sent/Open") {
            try LogMessage("Test " . protocol . " failed for " . dest_ip . ":" . port)
        }

        LogMessage("TestsEngine.executeTest() completed. Returned status: " . status)
        return data
    }

    ; --- OPTIMIZED NETWORKING FUNCTIONS ---

    /**
     * @description Tests a TCP connection to the specified IP and port.
     * @param {String} ip - Destination IP address.
     * @param {Number} port - Destination port.
     * @param {Number} [timeout=500] - Timeout in milliseconds.
     * @returns {Boolean} - `true` if the connection is successful, `false` otherwise.
     * @example <caption>Test a TCP connection.</caption>
     * success := TestsEngine().TestTCP("8.8.8.8", 53)
     */
    TestTCP(ip, port, timeout := 500) {
        LogMessage("TestsEngine.TestTCP() started. Params: ip=" . ip . ", port=" . port . ", timeout=" . timeout)

        ; Initialize Winsock once per call (or move to __New for better performance)
        static WSADATA := Buffer(400)
        if DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) {
            LogMessage("ERROR in TestsEngine.TestTCP(): WSAStartup failed.")
            return false
        }

        ; Création du Socket TCP
        s := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr") ; AF_INET, SOCK_STREAM, IPPROTO_TCP
        if (s = -1) {
            LogMessage("ERROR in TestsEngine.TestTCP(): Socket creation failed.")
            DllCall("ws2_32\WSACleanup")
            return false
        }
        LogMessage("TCP socket created successfully.")

        ; Setup sockaddr structure
        sockaddr := Buffer(16, 0)
        NumPut("Short", 2, sockaddr, 0)
        NumPut("UShort", DllCall("ws2_32\htons", "UShort", port), sockaddr, 2) ; Port
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", ip), sockaddr, 4) ; IP address
        LogMessage("Socket address structure configured.")

        ; Set non-blocking mode
        arg := Buffer(4), NumPut("UInt", 1, arg)
        DllCall("ws2_32\ioctlsocket", "Ptr", s, "Int", 0x8004667E, "Ptr", arg)
        LogMessage("Socket set to non-blocking mode.")

        DllCall("ws2_32\connect", "Ptr", s, "Ptr", sockaddr, "Int", 16) ; tentative de connexion non bloquante
        LogMessage("Non-blocking connection attempt initiated.")

        ; Setup select() for timeout
        writefds := Buffer(520, 0)  ; fd_set structure: DWORD fd_count + 64 sockets (Ptr each)
        NumPut("UInt", 1, writefds, 0)
        NumPut("Ptr", s, writefds, 8)

        timeval := Buffer(8, 0)
        NumPut("Int", 0, timeval, 0), NumPut("Int", timeout * 1000, timeval, 4)
        LogMessage("Timeout configured: " . timeout . "ms.")

        res := DllCall("ws2_32\select", "Int", 0, "Ptr", 0, "Ptr", writefds, "Ptr", 0, "Ptr", timeval)
        LogMessage("Select result: " . res)

        ; Cleanup
        DllCall("ws2_32\closesocket", "Ptr", s)
        DllCall("ws2_32\WSACleanup")
        LogMessage("TCP socket and Winsock cleaned up.")

        result := (res > 0)
        LogMessage("TestsEngine.TestTCP() completed. Result: " . result)
        return result
    }

    /**
     * @description Tests an ICMP (ping) connection to the specified IP.
     * @param {String} ip - Destination IP address.
     * @returns {Boolean} - `true` if the ping is successful, `false` otherwise.
     * @example <caption>Test an ICMP connection.</caption>
     * success := TestsEngine().TestICMP("8.8.8.8")
     */
    TestICMP(ip) {
        LogMessage("TestsEngine.TestICMP() started. Params: ip=" . ip)
        ; Use ComSpec for a cleaner hidden execution
        result := (RunWait(A_ComSpec ' /c ping -n 1 -w 500 ' . ip, , "Hide") = 0)
        LogMessage("TestsEngine.TestICMP() completed. Result: " . result)
        return result
    }

    /**
     * @description Tests a UDP connection to the specified IP and port.
     * @param {String} ip - Destination IP address.
     * @param {Number} port - Destination port.
     * @returns {Boolean} - `true` if the UDP connection is successful, `false` otherwise.
     * @example <caption>Test a UDP connection.</caption>
     * success := TestsEngine().TestUDP("8.8.8.8", 53)
     */
    TestUDP(ip, port) {
        LogMessage("TestsEngine.TestUDP() started. Params: ip=" . ip . ", port=" . port)

        static WSADATA := Buffer(400)
        DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA)
        LogMessage("Winsock initialized for UDP test.")

        s := DllCall("ws2_32\socket", "Int", 2, "Int", 2, "Int", 17, "Ptr") ; SOCK_DGRAM, IPPROTO_UDP
        LogMessage("UDP socket created: " . s)

        sockaddr := Buffer(16, 0)
        NumPut("Short", 2, sockaddr, 0)
        NumPut("UShort", DllCall("ws2_32\htons", "UShort", port), sockaddr, 2)
        NumPut("UInt", DllCall("ws2_32\inet_addr", "AStr", ip), sockaddr, 4)
        LogMessage("Socket address structure configured for UDP.")

        ; Note: UDP connect only checks if the local stack can reach the destination route.
        ; It does not "handshake" like TCP.
        res := DllCall("ws2_32\connect", "Ptr", s, "Ptr", sockaddr, "Int", 16)
        LogMessage("UDP connect result: " . res)

        DllCall("ws2_32\closesocket", "Ptr", s)
        DllCall("ws2_32\WSACleanup")
        LogMessage("UDP socket and Winsock cleaned up.")

        result := (res = 0)
        LogMessage("TestsEngine.TestUDP() completed. Result: " . result)
        return result
    }
}