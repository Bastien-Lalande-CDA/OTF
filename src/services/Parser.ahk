#Requires AutoHotkey v2.0

class Parser extends Object {
    /**
     * @description Parses a CSV file and returns its content as an array of rows, with headers.
     *              Validates that the CSV headers match the expected format.
     * @param {String} filePath - Path to the CSV file to parse.
     * @param {Number} [nb_entete=1] - Number of header rows (default: 1).
     * @param {String} [delimiter=";"] - Delimiter used in the CSV file (default: ";").
     * @returns {Array|Boolean} - Returns an array containing [headers, dataArray] if successful, or `false` if the file does not exist or headers do not match.
     * @example <caption>Parse a CSV file with default settings.</caption>
     * parsedData := Parser().parseCSV("data.csv")
     * if (parsedData) {
     *     headers := parsedData[1]
     *     data := parsedData[2]
     * }
     */
    parseCSV(filePath, delimiter := ";") {

        if !FileExist(filePath) {
            LogMessage("ERROR in Parser.parseCSV(): File not found at path: " . filePath)
            MsgBox("Parsing Error can't find :" filePath)
            return false
        }

        fileContent := FileRead(filePath, "UTF-8")
        dataArray := []
        headers := []

        Loop Parse, fileContent, "`n", "`r" {
            if (A_LoopField = "")
                continue

            columns := StrSplit(A_LoopField, delimiter)

            if (A_Index <= 1) {
                headers := columns
                continue
            }

            ; Build row object by matching headers
            rowObject := []
            for index, headerName in headers {
                val := columns.Has(index) ? columns[index] : ""
                val := Trim(val)
                rowObject.Push(val)
            }

            dataArray.Push(rowObject)
        }

        expexted_headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]

        ; Trim and validate each header
        for index, header in headers {
            if (header != expexted_headers[index]) {
                LogMessage("ERROR in Parser.parseCSV(): Header mismatch at index " . index . ". Expected: " . expexted_headers[index] . ", Found: " . header)
                return false
            }
        }
        return [headers, dataArray]
    }
}