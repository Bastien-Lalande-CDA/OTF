#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Configuration et Données ---
AppName := "App Name"
Version := "0.0.1"
Headers := ["Source Name", "Source IP", "Dest. Name", "Dest. IP", "Port", "Protocol", "Service", "Last Test", "Status"]
RowsData := [
    ["UC50662","10.21.221.128","apple","17.253.144.10","443","TCP","HTTPS","10/04/2026","NOT TESTED"],
    ["UC50662","10.21.221.128","apple","17.253.144.10","443","TCP","HTTPS","10/04/2026","NOT TESTED"],
    ["UC50662","10.21.221.128","apple","17.253.144.10","443","TCP","HTTPS","10/04/2026","NOT TESTED"]
]

; --- Création de l'interface ---
window := Gui("-MinimizeBox -MaximizeBox", AppName " - v" Version)
window.SetFont("s9", "Segoe UI")

; Ajout de la ListView
LV := window.Add("ListView", "r15 w600 Grid -Multi", Headers)

; Remplissage de la ListView
LV.Opt("-Redraw")
for Row in RowsData
    LV.Add(, Row*)
LV.ModifyCol()
LV.Opt("+Redraw")

; --- Boutons de contrôle ---
window.Add("Button", "w120", "Ajouter une ligne").OnEvent("Click", (*) => AddRow())
window.Add("Button", "x+10 w120", "Supprimer sélection").OnEvent("Click", (*) => DeleteSelected())
window.Add("Button", "xm w600 Default", "Suivant").OnEvent("Click", ProcessData)

window.OnEvent("Close", (*) => ExitApp())
window.Show()

; --- Fonctions ---

AddRow(*) {
    data := this.getNewEntry()
    if (data) {
        LV.Add(, data*)
        LV.ModifyCol()
    }
}

DeleteSelected(*) {
    if RowNum := LV.GetNext(0) ; Récupère la ligne sélectionnée
        LV.Delete(RowNum)
    else
        MsgBox("Veuillez sélectionner une ligne à supprimer.", "Info", "Iconi")
}

ProcessData(*) {
    SavedData := []
    Loop LV.GetCount() {
        RowIndex := A_Index
        RowDetails := []
        Loop Headers.Length {
            RowDetails.Push(LV.GetText(RowIndex, A_Index))
        }
        SavedData.Push(RowDetails)
    }
    MsgBox("Données prêtes : " SavedData.Length " lignes enregistrées.")
}