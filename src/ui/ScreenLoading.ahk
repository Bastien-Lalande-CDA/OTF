#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class ScreenLoading extends WindowOTF {

    /**
     * @description Constructor for the ScreenLoading class. Initializes a loading screen with a progress bar and text.
     * @param {Number} totalTests - The total number of tests to display progress for.
     * @returns {void}
     * @example <caption>Create a loading screen for 10 tests.</caption>
     * loadingScreen := ScreenLoading(10)
     */
    __New(totalTests) {
        LogMessage("ScreenLoading.__New() started. Params: totalTests=" . totalTests)
        super.__New()

        this.totalTests := totalTests

        CloseWindow(*) {
            LogMessage("ScreenLoading window closed by user.")
            ExitApp()
        }
        this.OnEvent("Close", CloseWindow)

        this.Add("Text", "vProgressText w300", "Progression : 0 / " . totalTests)
        this.Add("Progress", "vProgressBar w300 h20 cGreen Range0-" . totalTests, 0)
        LogMessage("Progress bar and text added to loading screen.")

        this.Show()
        LogMessage("ScreenLoading.__New() completed. Loading screen displayed.")
    }

    /**
     * @description Updates the progress bar and text to reflect the current test number.
     * @param {Number} currentTest - The current test number to display.
     * @returns {void}
     * @example <caption>Update loading screen to test 5.</caption>
     * loadingScreen.Update(5)
     */
    Update(currentTest) {
        LogMessage("ScreenLoading.Update() started. Params: currentTest=" . currentTest)
        this["ProgressBar"].Value := currentTest
        this["ProgressText"].Text := "Progression : " . currentTest . " / " . this.totalTests
        LogMessage("ScreenLoading.Update() completed. Progress updated.")
    }

    /**
     * @description Closes the loading screen and destroys the window.
     * @returns {void}
     * @example <caption>Close the loading screen.</caption>
     * loadingScreen.Close()
     */
    Close() {
        LogMessage("ScreenLoading.Close() started.")
        this.Destroy()
        LogMessage("ScreenLoading.Close() completed. Loading screen destroyed.")
    }
}