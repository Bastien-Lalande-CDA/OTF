#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class ScreenResults extends WindowOTF {
    ShowResults(data) {
        this.OnEvent("Close", (*) => ExitApp())

        headers := data[1]

        rows := data[2]

        SortArray(rows, CompareStatus, 8)

        CompareStatus(a, b, col) {
            order := Map("Success", 1, "Sent/Open", 2, "Failed", 3, "NOT TESTED (IP MISMATCH)", 4)
            return order[a[col]] - order[b[col]]
        }

        SortArray(arr, cmp, col) {
            len := arr.Length
            Loop len - 1 {
                i := A_Index
                Loop len - i {
                    j := A_Index
                    if (cmp(arr[j], arr[j+1], col) > 0) {
                        temp := arr[j]
                        arr[j] := arr[j+1]
                        arr[j+1] := temp
                    }
                }
            }
        }
    

        nb_of_success := 0
        nb_of_fail := 0
        for row in rows {
            if (row[8] = "Success") {
                nb_of_success++
            }
            if (row[8] = "Failed") {
                nb_of_fail++
            }
        }

        main_txt := "Date: " 
        . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  " 
        . nb_of_success . "/"  . rows.Length . " tests réussis [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]" . "  |  " 
        . nb_of_fail . "/"  . rows.Length . " échecs [" . Format("{:.2f}", (nb_of_fail / rows.Length) * 100) . "%]"
        this.Add("Text",, main_txt)

        lv := this.Add("ListView", "r20 w800 Grid NoSortHdr NoSort", headers)

        lv.Opt("-Redraw")
        for rowData in rows {
            lv.Add(, rowData*)
        }
        lv.Opt("+Redraw")

        lv.ModifyCol()

        CloseBtn := this.Add("Button", "xm w800 Default", "Enregistrer les résultats")
        CloseBtn.OnEvent("Click", (*) => this.Hide())

        this.Show()

        WinWaitClose(this.Hwnd)
        this.Destroy()
        return true
    }
}