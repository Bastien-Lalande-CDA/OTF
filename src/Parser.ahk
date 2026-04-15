#Requires AutoHotkey v2.0

class Parser extends Object {
    parseCSV(filePath, nb_entete := 1, delimiter := ";") {
        if !FileExist(filePath)
            MsgBox("Parsing Error can't find :" filePath)
        fileContent := FileRead(filePath, "UTF-8")
        dataArray := []
        headers := []
        Loop Parse, fileContent, "`n", "`r" {
            if (A_LoopField = "")
                continue
            columns := StrSplit(A_LoopField, delimiter)

            if (A_Index <= nb_entete) {
                headers := columns
                continue
            }

            rowObject := []
            for index, headerName in headers {
                val := columns.Has(index) ? columns[index] : ""
                rowObject.Push(val)
            }
            
            dataArray.Push(rowObject)
        }
        return [headers, dataArray]
    }
}
