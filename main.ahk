#Requires AutoHotkey v2.0
#SingleInstance Force

WinWaitActiveTitleWithPID(pid, title, text := unset){
    while true {
        esp_id := WinWaitActive(title, text?)
        if WinGetPID("ahk_id " esp_id) == pid {
            return esp_id 
        }
    }
    return -1
}

f17::{
    Run("C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe", , , &esp_pid)
    WinWaitActiveTitleWithPID(esp_pid, "ESPRIT - ")
    Run("esp.ahk " esp_pid)
}