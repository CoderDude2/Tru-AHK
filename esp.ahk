#Requires AutoHotkey v2.0
#SingleInstance Off

esp_pid := A_Args[1]

check_window_exist(){
    if not WinExist("ahk_pid" esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

#HotIf WinActive("ahk_pid" esp_pid)
^y::{
    MsgBox(esp_pid)
}