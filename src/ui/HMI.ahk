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
    /**
     * @description Prompts the user to select a data type (CSV import, new matrix, or TCP server).
     * @returns {Number} - The selected option (1: CSV import, 2: New matrix, 3: TCP server).
     * @example <caption>Ask user for data type selection.</caption>
     * dataType := HMI().askDataType()
     */
    askDataType() {
        result := DialogueRadio().GetOpt()
        return result
    }

    /**
     * @description Prompts the user to select a file path.
     * @returns {String} - The selected file path.
     * @example <caption>Ask user for a file path.</caption>
     * filePath := HMI().askPath()
     */
    askPath() {
        result := DialogueGetPath().GetPath()
        return result
    }

    /**
     * @description Opens a matrix data management dialog for editing or creating matrix data.
     * @param {Array} [input_data=[]] - Optional input data to preload in the matrix manager.
     * @returns {Array} - The final matrix data as returned by the matrix manager.
     * @example <caption>Manage matrix data with optional input.</caption>
     * matrixData := HMI().manageMatrixData([["Header1", "Header2"], ["Value1", "Value2"]])
     */
    manageMatrixData(input_data := []) {
        result := ManagerMatrix().GetFinalMatrix(input_data)
        return result
    }

    /**
     * @description Displays the test results in a results screen.
     * @param {Array} data - The data to display (headers and results).
     * @returns {Boolean} - `true` if the user confirms the results, `false` otherwise.
     * @example <caption>Show test results to the user.</caption>
     * userConfirmed := HMI().showResults([["Header1", "Header2"], ["Result1", "Result2"]])
     */
    showResults(data) {
        result := ScreenResults().ShowResults(data)
        return result
    }

    /**
     * @description Initializes the loading screen with the total number of tests.
     * @param {Number} totalTests - The total number of tests to be executed.
     * @returns {void}
     * @example <caption>Initialize loading screen for 10 tests.</caption>
     * HMI().initLoadingScreen(10)
     */
    initLoadingScreen(totalTests) {
        this.window_loading := ScreenLoading(totalTests)
    }

    /**
     * @description Updates the loading screen with the current test progress.
     * @param {Number} currentTest - The index of the current test being executed.
     * @returns {void}
     * @example <caption>Update loading screen to test 5.</caption>
     * HMI().updateLoadingScreen(5)
     */
    updateLoadingScreen(currentTest) {
        this.window_loading.Update(currentTest)
    }

    /**
     * @description Closes the loading screen.
     * @returns {void}
     * @example <caption>Close the loading screen.</caption>
     * HMI().closeLoadingScreen()
     */
    closeLoadingScreen() {
        this.window_loading.Close()
    }

    /**
     * @description Opens the TCP server management interface.
     * @returns {void}
     * @example <caption>Manage TCP servers.</caption>
     * HMI().manageTCPServers()
     */
    manageTCPServers() {
        ManagerTCP().ManageTCPServers()
    }
}