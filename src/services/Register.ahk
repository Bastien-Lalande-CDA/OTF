#Requires AutoHotkey v2.0

class Register extends Object {
    registerTests(results, ouptut_path := A_ScriptDir . "\outputs\results.csv") { ; results = [headears,[data]]
        csvContent := ""
        for index, header in results[1]
            csvContent .= header (index < results[1].Length ? ";" : "`n")

        for index, row in results[2] {
            for colIndex, value in row
                csvContent .= value (colIndex < row.Length ? ";" : "`n")
        }
        FileAppend(csvContent, ouptut_path)
    }
}