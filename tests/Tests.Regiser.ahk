#Requires AutoHotkey v2.0

; ===== Test_Register.ahk =====
#Include ../src/Register.ahk
#Include TestsFramework.ahk

Test_Add_Result() {
    reg := Register()

    reg.Add({status: "Success"})

    Assert.Equal(1, reg.results.Length)
}

Test_Save_File() {
    reg := Register()

    reg.Add({status: "Success"})
    path := reg.Save("test.csv")

    Assert.True(FileExist(path), "Le fichier doit exister")
}

RunTest("Register - ajout", Test_Add_Result)
RunTest("Register - sauvegarde", Test_Save_File)