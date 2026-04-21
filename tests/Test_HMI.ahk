#Requires AutoHotkey v2.0

; ===== Test_HMI.ahk =====
#Include ../src/HMI.ahk
#Include ../Lib/Yunit/Yunit.ahk

class Test_HMI {

    Test_Format_Result() {
        hmi := HMI()

        formatted := hmi.FormatResult({status: "Success"})

        if !(InStr(formatted, "Success"))
            throw Error("Formatted result does not contain 'Success'")
    }
}