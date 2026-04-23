#Requires AutoHotkey v2.0

class Register extends Object {
    /**
     * @description Registers test results to a CSV file. Writes headers and data rows to the specified output path.
     * @param {Array} results - Array containing [headers, data] to be written to the CSV file.
     * @param {String} [ouptut_path=A_ScriptDir "\outputs\results.csv"] - Path to the output CSV file.
     * @returns {void}
     * @example <caption>Register test results to a CSV file.</caption>
     * Register().registerTests([["header1", "header2"], [["value1", "value2"], ["value3", "value4"]]])
     */
    registerTests(results, ouptut_path := A_ScriptDir . "\outputs\results.csv") {

        csvContent := ""

        ; Build header row
        for index, header in results[1] {
            csvContent .= header (index < results[1].Length ? ";" : "`n")
        }

        ; Build data rows
        for index, row in results[2] {
            for colIndex, value in row {
                csvContent .= value (colIndex < row.Length ? ";" : "`n")
            }
        }

        FileAppend(csvContent, ouptut_path)
    }
}