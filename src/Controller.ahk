#Requires AutoHotkey v2.0

#Include "HMI.ahk"
#Include "Parser.ahk"
#Include "Register.ahk"
#Include "TestsEngine.ahk"


class Controller {
    startScript() {
        ; Initialize components
        this.hmi := HMI()
        this.parser := Parser()
        this.register := Register()
        this.testEngine := TestEngine()
        
        this.runWorkflow()
    }
    
    runWorkflow() {

        data_type := this.hmi.askDataType() ; 1=CSV import, 2=Matrix editing
        input_data := ""

        if (data_type = 1) {

            conform_csv_col := false

            while (!conform_csv_col) {
                csv_path := this.hmi.askPath() ; Ask for CSV file path
            
                csv_data := this.parser.parseCSV(csv_path) ; Parse the CSV file

                if (csv_data) {
                    conform_csv_col := true
                } else {
                    MsgBox("Fichier au mauvais format ou introuvable. Veuillez réessayer.", "Erreur", "Icon!")
                    LogMessage("File not conform at path: " . csv_path)
                }
            }

            input_data := this.hmi.editMatrixData(csv_data[2]) ; Allow user to edit the parsed data

        } else if (data_type = 2) {
            input_data := this.hmi.editMatrixData() ; Ask for matrix data input

        } else {
            MsgBox("Invalid selection. Please restart the application.")
            LogMessage("Invalid data type selection, data_type:" . data_type)
            ExitApp()
        }

        test_results := []

        rows := input_data[2]

        totalTests := rows.Length

        this.hmi.initLoadingScreen(totalTests) ; Initialize the loading screen

        my_ips := SysGetIPAddresses()

        for i, row in rows {
            result := this.testEngine.executeTest(row, my_ips) ; Execute tests on each row of data
            test_results.Push(result)
            this.hmi.updateLoadingScreen(i,totalTests) ; Update the loading screen after each test
        }
        this.hmi.closeLoadingScreen()

        results_tab := [input_data[1], test_results] ; Combine headers with results

        if this.hmi.showResults(results_tab) {
            this.register.registerTests(input_data, A_ScriptDir . "\outputs\results_" . FormatTime(A_Now, 'yyyyMMdd_HHmmss') . ".csv")
            LogMessage("results saved at: " A_ScriptDir . "\outputs\results_" . FormatTime(A_Now, 'yyyyMMdd_HHmmss') . ".csv")
        }
        
    }
}