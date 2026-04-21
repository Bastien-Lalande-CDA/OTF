#Requires AutoHotkey v2.0

; ===== Test_Register.ahk =====
#Include ../src/Register.ahk
#Include ../Lib/Yunit/Yunit.ahk

class Test_Register {

    Test_Add_Result() {
        reg := Register()

        reg.Add({status: "Success"})

        if (reg.results.Length != 1)
            throw Error("Expected 1 result")
    }

    Test_Save_File() {
        reg := Register()

        reg.Add({status: "Success"})
        path := reg.Save("test.csv")

        if !FileExist(path)
            throw Error("File was not created")
    }
}