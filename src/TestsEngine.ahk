#Requires AutoHotkey v2.0

class TestEngine {
    executeTest(data, my_ips) { ;source_name;source_ip;destination_name;destination_ip;designation_port;protocol;service_name;status
        source_ip := data[2]
        dest_ip := data[4]
        port := data[5]
        protocol := data[6]

        if (data[8] = "") {
            data[8] := "NOT TESTED"
        }

        found := false
        for index, value in my_ips {
            if (value = source_ip) {
                found := true
                break
            }
        }
        if (!found || InStr(protocol, "TCP",, 1) = 0) {
            data[8] := "NOT TESTED"
            return data
        }

        cmd := "powershell -Command `"Test-NetConnection -ComputerName " . dest_ip . " -Port " . port . " | Select-Object -ExpandProperty TcpTestSucceeded`""

        output := ""
        try 
            RunWait(A_ComSpec " /c " cmd " > result.tmp",, 0)
        catch Any as e {
            LogMessage("Error executing command: " . e.Message)
            return
        }

        try
            output := FileRead("result.tmp")
        finally
            FileDelete("result.tmp")

        output := Trim(output, " `r`n`t")

        if (output = "True") {
            data[8] := "Success"
            
        } else {
            data[8] := "Failed"
            LogMessage("Test failed for " . dest_ip . ":" . port . " from " . source_ip)
        }

        return data
    }
}