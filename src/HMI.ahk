#Requires AutoHotkey v2.0

class HMI extends Object {
    __Init() {
        TraySetIcon(A_ScriptDir . "\src\par-feu.png")
        this.window_title := AppName . " - v" . AppVersion
        this.window_height := 300
        this.window_width := 800
    }
    createWindow() {
        this.Window := Gui("-MinimizeBox -MaximizeBox", this.window_title)
        return this.Window
    }
    askDataType() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())
        
        window.Add("Text", "x10 y10 w200 h20", "Sélectionez une option:")
        radio1 := window.Add("Radio", "x10 y40 w200 h20 vDataType1 Checked", "Importer une matrice de flux (CSV)")
        radio2 := window.Add("Radio", "x10 y70 w200 h20 vDataType2", "Editer une matrice de flux")
        btn := this.Window.Add("Button", "Default x130 y100 w80 h30", "OK")

        btn.OnEvent("Click", (*) => window.Hide()) ; submitt button

        window.Show()

        WinWaitClose(window.Hwnd)
        opt := 0
        if (radio1.Value) {
            opt := 1
        } else if (radio2.Value) {
            opt := 2
        }
        window.Destroy()
        return opt
    }
    askPath() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        path := ""

        window.Add("Text",, "Selected File:")
        PathDisplay := window.Add("Edit", "w300 r1 ReadOnly", "Aucun fichier sélectionné...")
        BrowseBtn := window.Add("Button", "x+10 w80", "Browse")
        SubmitBtn := window.Add("Button", "xm w390 Default", "Confirm Selection")

        BrowseBtn.OnEvent("Click", SelectFile)
        SubmitBtn.OnEvent("Click", ProcessFile)

        window.Show()

        SelectFile(*) {
            SelectedFile := FileSelect(3, , "Select a file", "Documents (*.txt; *.csv; *.docx)")
            if (SelectedFile != "") {
                PathDisplay.Value := SelectedFile
            }
        }

        ProcessFile(*) {
            if (PathDisplay.Value = "Aucun fichier sélectionné...") {
                MsgBox("Choisisez un fichier dabord", "Error", "Icon!")
            } else {
                path := PathDisplay.Value
                window.Hide()
            }
        }

        WinWaitClose(window.Hwnd)
        window.Destroy()
        return path
    }
    askMatrixData() {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        input := ""

        window.Add("Text",, "Input Matrix Data:")
        InputDisplay := window.Add("Edit", "w300 r10", "Entrez les données de la matrice ici...")
        SubmitBtn := window.Add("Button", "xm w390 Default", "Submit")

        SubmitBtn.OnEvent("Click", ProcessInput)

        window.Show()

        ProcessInput(*) {
            if (InputDisplay.Value = "Entrez les données de la matrice ici...") {
                MsgBox("Veuillez entrer les données de la matrice avant de soumettre.", "Error", "Icon!")
            } else {
                input := InputDisplay.Value
                window.Hide()
            }
        }

        WinWaitClose(window.Hwnd)
        window.Destroy()
        return input
    }
    showResults(data) {
        window := this.createWindow()
        window.OnEvent("Close", (*) => ExitApp())

        headers := data[1]
        rows := data[2]

        nb_of_success := 0
        for row in rows {
            if (row[9] = "Success") {
                nb_of_success++
            }
        }

        main_txt := "Date: " . FormatTime(A_Now, 'yyyy-MM-dd') . "  |  " . nb_of_success . "/"  . rows.Length . " tests passées avec succès [" . Format("{:.2f}", (nb_of_success / rows.Length) * 100) . "%]"
        window.Add("Text",, main_txt)

        lv := window.Add("ListView", "r20 w800 Grid", headers)

        lv.Opt("-Redraw") ; Performance boost while loading
        for rowData in rows {
            lv.Add(, rowData*) ; The * operator spreads the array into parameters
        }
        lv.Opt("+Redraw")

        lv.ModifyCol()

        CloseBtn := window.Add("Button", "xm w390 Default", "Close")
        CloseBtn.OnEvent("Click", (*) => window.Hide())

        window.Show()


        WinWaitClose(window.Hwnd)
        window.Destroy()
        return true
    }
    initLoadingScreen(totalTests) {
        this.window_loading := this.createWindow()
        this.window_loading.OnEvent("Close", (*) => ExitApp())

        this.window_loading.Add("Text", "vProgressText Center", "Progression :     0 / " . totalTests)
        progress := this.window_loading.Add("Progress", "vProgressBar w300 h20 cGreen Range-0-" . totalTests, 0)

        this.window_loading.Show()

        return this.window_loading
    }
    updateLoadingScreen(currentTest, totalTests) {
        this.window_loading["ProgressBar"].Value := currentTest
        this.window_loading["ProgressText"].Value := "Progression :     " . currentTest . " / " . totalTests
    }
    closeLoadingScreen() {
        if (this.window_loading) {
            this.window_loading.Hide()
            this.window_loading.Destroy()
        }
    }
}