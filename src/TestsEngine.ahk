#Requires AutoHotkey v2.0

class TestEngine {
    executeTest(data) { ;source_name;source_ip;destination_name;destination_ip;designation_port;protocol;service_name;last_time_tested;status
        ;data[8] := "00/00/0001" ; date [dd/mm/yyyy]
        ;data[9] := "Default" ; status [Success, Failed, Warning, Filtered]
        Sleep(200) ; Simulate test execution time
        return data
    }
}