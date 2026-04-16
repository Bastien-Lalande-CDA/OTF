#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Création de la fenêtre principale ---
this.window := Gui("+Resize", "Gestionnaire de Flux Réseau")

; --- Section Saisie (Inputs) ---
this.window.Add("GroupBox", "r6 w620", "Ajouter une nouvelle entrée")
this.window.Add("Text", "xp+10 yp+25 w80", "Source Name:")
EditSrcName := this.window.Add("Edit", "vSrcName x+5 w120")
this.window.Add("Text", "x+20 w60", "Source IP:")
EditSrcIP   := this.window.Add("Edit", "vSrcIP x+5 w120")
EditSrcIP.Value := SysGetIPAddresses()[1]

this.window.Add("Text", "xm+10 yp+30 w80", "Dest. Name:")
EditDstName := this.window.Add("Edit", "vDstName x+5 w120")
this.window.Add("Text", "x+20 w60", "Dest. IP:")
EditDstIP   := this.window.Add("Edit", "vDstIP x+5 w120")

this.window.Add("Text", "xm+10 yp+30 w40", "Port:")
EditPort    := this.window.Add("Edit", "vPort x+5 w50")
this.window.Add("Text", "x+15 w60", "Protocol:")
DDLProto    := this.window.Add("DropDownList", "vProtocol x+5 w70", ["TCP", "UDP", "ICMP"])
this.window.Add("Text", "x+15 w50", "Service:")
EditService := this.window.Add("Edit", "vService x+5 w100")

BtnAdd := this.window.Add("Button", "Default xm+10 yp+40 w100 h30", "Ajouter")
BtnAdd.OnEvent("Click", AddEntry)

this.window.Show()

; --- Fonctions ---

IsValidIP(IP) {
    pattern := "^(\d{1,3}\.){3}\d{1,3}$"
    if (!RegExMatch(IP, pattern))
        return false
    loop Parse IP, "." {
        if (A_LoopField > 255)
            return false
    }
    return true
}

IsNumber(value) {
    return (value != "")
}

AddEntry(*) {
    ; Récupération des valeurs
    SName  := EditSrcName.Value
    SIP    := EditSrcIP.Value
    DName  := EditDstName.Value
    DIP    := EditDstIP.Value
    Port   := EditPort.Value
    Proto  := DDLProto.Text
    Serv   := EditService.Value
    Time   := FormatTime(, "dd/MM/yyyy")
    Stat   := "" ; Statut par défaut

    if (SIP = "" || DIP = "" || Port = "") {
        MsgBox("Veuillez remplir tous les champs obligatoires.")
        return
    }

    if (!IsValidIP(SIP) || !IsValidIP(DIP)) {
        MsgBox("Veuillez entrer des adresses IP valides.")
        return
    }

    if (!IsNumber(Port)) {
        MsgBox("Le port doit être un nombre.")
        return
    }

    
    ; Vider les champs après ajout
    EditSrcName.Value := ""
    EditSrcIP.Value   := ""
    EditDstName.Value := ""
    EditDstIP.Value   := ""
    EditPort.Value    := ""
    EditService.Value := ""
}