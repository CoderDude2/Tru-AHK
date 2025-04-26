#Requires AutoHotkey v2.0
#SingleInstance Force

#Include Lib\util.ahk

MsgNum := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
^f13::{
    PostMessage(MsgNum, , , ,0xFFFF)
}

f17::{
    Run("C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe", , , &esp_pid)
    Run("esp.ahk " esp_pid)
}