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

        

        expexted_headers := ["source_name","source_ip","destination_name","destination_ip","designation_port","protocol","service_name","status"]

        ; trim each head off headers
        for index, header in headers {
            if (header != expexted_headers[index]){
                return false
            }
        }
        return [headers, dataArray]
    }
}
