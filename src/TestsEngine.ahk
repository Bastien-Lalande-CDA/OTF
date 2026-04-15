#Requires AutoHotkey v2.0

class TestEngine {
    executeTest(data, my_ips) { ;source_name;source_ip;destination_name;destination_ip;designation_port;protocol;service_name;last_time_tested;status
        source_ip := data[2]
        dest_ip := data[4]
        port := data[5]
        protocol := data[6]

        found := false
        for index, value in my_ips {
            if (value = source_ip) {
                found := true
                break
            }
        }
        if (!found && InStr(protocol, "TCP",, 1) = 0) {
            return data
        }

        cmd := "powershell -Command `"Test-NetConnection -ComputerName " . dest_ip . " -Port " . port . " | Select-Object -ExpandProperty TcpTestSucceeded`""

        output := ""
        try 
            RunWait(A_ComSpec " /c " cmd " > result.txt",, 0)
        catch Any as e {
            LogMessage("Error executing command: " . e.Message)
            return
        }

        try
            output := FileRead("result.txt")
        finally
            FileDelete("result.txt")

        output := Trim(output, " `r`n`t")

        if (output = "True") {
            data[9] := "Success"
            data[8] := FormatTime(A_Now, "dd/MM/yyyy")
        } else {
            data[9] := "Failed"
            data[8] := FormatTime(A_Now, "dd/MM/yyyy")
        }

        return data
    }
}