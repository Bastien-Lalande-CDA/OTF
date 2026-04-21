#Requires AutoHotkey v2.0

; ===== Test_Register.ahk =====
#Include ../src/Register.ahk
#Include ../Lib/Yunit/Yunit.ahk

class Test_Register {

    Test_Add_Result() {
        reg := Register()

        reg.Add({status: "Success"})

        Yunit.AssertEquals(1, reg.results.Length)
    }

    Test_Save_File() {
        reg := Register()

        reg.Add({status: "Success"})
        path := reg.Save("test.csv")

        Yunit.Assert(FileExist(path))
    }
}