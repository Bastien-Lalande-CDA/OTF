#Requires AutoHotkey v2.0

; ===== Test_Parser.ahk =====
#Include TestsFramework.ahk
#Include ../src/Parser.ahk

Test_Parse_ValidCSV() {
    parser := Parser()
    
    csv := "
    (
    source_name;source_ip;destination_name;destination_ip;designation_port;protocol;service_name;status
    A;1.1.1.1;B;2.2.2.2;80;TCP;HTTP;
    )"

    result := parser.ParseFromString(csv)

    Assert.True(result.Length > 0, "Le parser doit retourner des lignes")
    Assert.Equal("TCP", result[1].protocol)
}

Test_Parse_InvalidCSV() {
    parser := Parser()

    csv := "bad format"

    try {
        parser.ParseFromString(csv)
        throw Error("Doit échouer")
    } catch {
        Assert.True(true)
    }
}

RunTest("Parser - CSV valide", Test_Parse_ValidCSV)
RunTest("Parser - CSV invalide", Test_Parse_InvalidCSV)