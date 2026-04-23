#Requires AutoHotkey v2.0

#Include ../ui/HMI.ahk
#Include ../services/Parser.ahk
#Include ../services/Register.ahk
#Include ../services/TestsEngine.ahk
#Include ../Globals.ahk

class Controller {
    /**
     * @description Constructor for the Controller class. Initializes instances of Parser, TestsEngine, Register, and HMI.
     * @returns {void}
     * @example <caption>Create a new Controller instance.</caption>
     * controller := Controller()
     */
    __New() {
        this.parser := Parser()
        this.testEngine := TestsEngine()
        this.register := Register()
        this.hmi := HMI()
    }

    /**
     * @description Starts the script workflow by calling runWorkflow().
     * @returns {void}
     * @example <caption>Start the script workflow.</caption>
     * controller.startScript()
     */
    startScript() {
        this.runWorkflow()
    }

    /**
     * @description Manages the workflow for data input, test execution, and result handling.
     * @returns {void}
     * @example <caption>Run the workflow for CSV import and test execution.</caption>
     * controller.runWorkflow()
     */
    runWorkflow() {
        data_type := this.hmi.askDataType() ; 1=CSV import, 2=Matrix editing, 3=TCP server management
        input_data := ""

        if (data_type = 1) {
            LogMessage("Processing CSV import workflow.")
            conform_csv_col := false

            while (!conform_csv_col) {

                LogMessage("CSV path requested.")
                csv_path := this.hmi.askPath() ; Ask for CSV file path

                csv_data := this.parser.parseCSV(csv_path) ; Parse the CSV file
                LogMessage("CSV parsing attempted for path: " . csv_path)

                if (csv_data) {
                    conform_csv_col := true
                    LogMessage("CSV data conform and loaded successfully.")
                } else {
                    MsgBox("Fichier au mauvais format ou introuvable. Veuillez réessayer.", "Erreur", "Icon!")
                    LogMessage("ERROR: File not conform at path: " . csv_path)
                }
            }

            input_data := this.hmi.manageMatrixData(csv_data[2]) ; Allow user to edit the parsed data
            LogMessage("Matrix data managed for CSV import.")

        } else if (data_type = 2) {
            LogMessage("Processing matrix editing workflow.")
            input_data := this.hmi.manageMatrixData() ; Ask for matrix data input
            LogMessage("Matrix data managed for manual input.")

        } else if (data_type = 3) {
            LogMessage("Processing TCP server management workflow.")
            this.hmi.manageTCPServers() ; Manage TCP server creation and data reception
            LogMessage("Program completed.")
            ExitApp()

        } else {
            MsgBox("Invalid selection. Please restart the application.")
            LogMessage("ERROR: Invalid data type selection, data_type: " . data_type)
            ExitApp()
        }

        test_results := []
        LogMessage("Initializing test execution workflow.")

        rows := input_data[2]
        totalTests := rows.Length
        LogMessage("Total tests to execute: " . totalTests)

        this.hmi.initLoadingScreen(totalTests) ; Initialize the loading screen

        my_ips := SysGetIPAddresses()

        for i, row in rows {
            result := this.testEngine.executeTest(row, my_ips) ; Execute tests on each row of data
            test_results.Push(result)
            this.hmi.updateLoadingScreen(i) ; Update the loading screen after each test
            LogMessage("Test completed " . i . "/" . totalTests)
        }

        this.hmi.closeLoadingScreen()
        LogMessage("All tests executed.")

        results_tab := [input_data[1], test_results] ; Combine headers with results

        if this.hmi.showResults(results_tab) {
            this.register.registerTests(input_data, A_ScriptDir . "\outputs\results_" . FormatTime(A_Now, 'yyyyMMdd_HHmmss') . ".csv")
            LogMessage("Results saved at: " . A_ScriptDir . "\outputs\results_" . FormatTime(A_Now, 'yyyyMMdd_HHmmss') . ".csv")
        } else {
            LogMessage("Results not saved.")
        }
    }
}