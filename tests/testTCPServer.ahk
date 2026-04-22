#Requires AutoHotkey v2.0

#Include ../src/Globals.ahk
#Include ../src/TCPservers.ahk

try {
    myServers := TCPServers()
    ; Créer un serveur sur le port 12345
    srv := myServers.Add("10.21.220.31", 12345)
    srv.Start()
    
    MsgBox("Serveur TCP lancé sur le port 12345.`nAppuyez sur OK pour arrêter.")
    
    myServers.Remove("10.21.220.31")
    ExitApp()
} catch Error as e {
    MsgBox("Erreur au démarrage : " . e.Message)
}