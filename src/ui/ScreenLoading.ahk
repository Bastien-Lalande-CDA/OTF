#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

#Requires AutoHotkey v2.0
#Include WindowOTF.ahk

class ScreenLoading extends WindowOTF {

    __New(totalTests) {
        super.__New()
        
        this.totalTests := totalTests

        this.OnEvent("Close", (*) => ExitApp())

        this.Add("Text", "vProgressText w300", "Progression : 0 / " . totalTests)

        this.Add("Progress", "vProgressBar w300 h20 cGreen Range0-" . totalTests, 0)

        this.Show()
    }

    Update(currentTest) {
        this["ProgressBar"].Value := currentTest
        this["ProgressText"].Text := "Progression : " . currentTest . " / " . this.totalTests
    }

    Close() {
        this.Destroy()
    }
}