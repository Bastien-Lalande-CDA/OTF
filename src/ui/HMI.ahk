#Requires AutoHotkey v2.0

#Include ../Globals.ahk
#Include WindowOTF.ahk
#Include DialogueRadio.ahk
#Include DialogueGetPath.ahk
#Include ScreenResults.ahk
#Include ScreenLoading.ahk
#Include ManagerMatrix.ahk
#Include ManagerTCP.ahk

class HMI extends Object {
    askDataType() {
        return DialogueRadio().GetOpt()
    }
    askPath() {
        return DialogueGetPath().GetPath()
    }
    manageMatrixData(input_data := []) {
        return ManagerMatrix().GetFinalMatrix(input_data)
    }
    showResults(data) {
        return ScreenResults().ShowResults(data)
    }
    initLoadingScreen(totalTests) {
        this.window_loading := ScreenLoading(totalTests)
    }
    updateLoadingScreen(currentTest) {
        this.window_loading.Update(currentTest)
    }
    closeLoadingScreen() {
        this.window_loading.Close()
    }
    manageTCPServers() {
        ManagerTCP().ManageTCPServers()
    }
}


