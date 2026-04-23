#Requires AutoHotkey v2.0

#Include WindowOTF.ahk

class ScreenResults extends WindowOTF {
    /**
     * @description Displays test results in a window with statistics and a sortable ListView.
     * @param {Array} data - Array containing [headers, rows] to display.
     * @returns {Boolean} - `true` if the window was closed properly.
     * @example <caption>Show test results.</caption>
     * ScreenResults().ShowResults([["Header1", "Header2"], ["Value1", "Success"], ["Value2", "Failed"]])
     */
    ShowResults(data) {
        LogMessage("ScreenResults.ShowResults() started. Params: data length=" . data.Length)

        CloseWindow(*) {
            LogMessage("ScreenResults window closed by user.")
            ExitApp()
        }
        this.OnEvent("Close", CloseWindow )

        headers := data[1]
        rows := data[2]
        LogMessage("Headers and rows extracted from data.")

        SortArray(rows, CompareStatus, 8)
        LogMessage("Rows sorted by status.")

        /**
         * @description Compares two rows based on their status for sorting.
         * @param {Array} a - First row to compare.
         * @param {Array} b - Second row to compare.
         * @param {Number} col - Column index to compare (status column).
         * @returns {Number} - Comparison result (-1, 0, or 1).
         */
        CompareStatus(a, b, col) {
            order := Map("Success", 1, "Sent/Open", 2, "Failed", 3, "NOT TESTED (IP MISMATCH)", 4)
            return order[a[col]] - order[b[col]]
        }

        /**
         * @description Sorts an array using a custom comparison function.
         * @param {Array} arr - Array to sort.
         * @param {Function} cmp - Comparison function.
         * @param {Number} col - Column index to use for comparison.
         * @returns {void}
         */
        SortArray(arr, cmp, col) {
            LogMessage("SortArray() started. Sorting array of length: " . arr.Length)
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
            LogMessage("SortArray() completed.")
        }

        nb_of_success := 0
        nb_of_fail := 0
        LogMessage("Calculating success and failure statistics.")
        for row in rows {
            if (row[8] = "Success") {
                nb_of_success++
            }
            if (row[8] = "Failed") {
                nb_of_fail++
            }
        }
        LogMessage("Statistics calculated: " . nb_of_success . " successes, " . nb_of_fail . " failures.")

        main_txt := "Date: "
        . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  "
        . nb_of_success . "/"  . rows.Length . " tests réussis [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]" . "  |  "
        . nb_of_fail . "/"  . rows.Length . " échecs [" . Format("{:.2f}", (nb_of_fail / rows.Length) * 100) . "%]"
        LogMessage("Summary text generated.")

        this.Add("Text",, main_txt)
        LogMessage("Summary text added to window.")

        lv := this.Add("ListView", "r20 w800 Grid NoSortHdr NoSort", headers)
        LogMessage("ListView created with headers.")

        lv.Opt("-Redraw")
        for rowData in rows {
            lv.Add(, rowData*)
        }
        lv.Opt("+Redraw")
        lv.ModifyCol()
        LogMessage("Rows added to ListView and columns modified.")

        CloseBtn := this.Add("Button", "xm w800 Default", "Enregistrer les résultats")
        SaveBtn(*) {
            LogMessage("Save button clicked. Hiding window.")
            this.Hide()
        }
        CloseBtn.OnEvent("Click", SaveBtn )
        LogMessage("Save button added and event bound.")

        this.Show()
        LogMessage("ScreenResults window displayed.")

        WinWaitClose(this.Hwnd)
        this.Destroy()
        LogMessage("ScreenResults.ShowResults() completed. Window destroyed.")
        return true
    }
}