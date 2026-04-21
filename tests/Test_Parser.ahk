#Requires AutoHotkey v2.0

; ===== Test_Parser.ahk =====
#Include ../src/Parser.ahk
#Include ../Lib/Yunit/Yunit.ahk

class Test_Parser {

    Test_Parse_ValidCSV() {
        parser := Parser()

        csv :=
        (
        "source_name;source_ip;destination_name;destination_ip;designation_port;protocol;service_name;status`n"
        "A;1.1.1.1;B;2.2.2.2;80;TCP;HTTP;"
        )

        result := parser.ParseFromString(csv)

        Yunit.Assert(result.Length > 0)
        Yunit.AssertEquals("TCP", result[1].protocol)
    }

    Test_Parse_InvalidCSV() {
        parser := Parser()

        try {
            parser.ParseFromString("invalid")
            Yunit.Fail("Une erreur était attendue")
        } catch {
            Yunit.Assert(true)
        }
    }
}