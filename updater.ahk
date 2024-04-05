#Requires Autohotkey v2.0
SetWorkingDir A_ScriptDir

; IniWrite "1.3.1", "config.ini", "info", "version"
online_version := IniRead("C:\Users\TruUser\Desktop\AHK_Update\config.ini", "info", "version")
local_version := IniRead("config.ini", "info", "version")

if(online_version != local_version){
    Loop Files, "C:\Users\TruUser\Desktop\AHK_Update\*", "DF"{
        if(f_attr := FileExist(A_ScriptDir "\" A_LoopFileName)){
            if(f_attr == "D"){
                DirCopy A_LoopFileName, A_ScriptDir "\" A_LoopFileName, true
            } else {
                FileMove A_ScriptDir "\" A_LoopFileName, A_ScriptDir "\old " A_LoopFileName
                ; FileCopy A_LoopFileName, A_ScriptDir "\" A_LoopFileName
            }
        }
    }
    ; FileMove "master_switch.exe", "master_switch_old.exe"
    ; FileMove "text_x.exe", "text_x_old.exe"
    ; DirCopy "C:\Users\TruUser\Desktop\AHK_Update\resources", A_ScriptDir "\resources", true
    ; FileCopy "C:\Users\TruUser\Desktop\AHK_Update\master_switch.exe", A_ScriptDir "\master_switch.exe"
    ; FileCopy "C:\Users\TruUser\Desktop\AHK_Update\text_x.exe", A_ScriptDir "\text_x.exe"
    ; FileCopy "C:\Users\TruUser\Desktop\AHK_Update\config.ini", A_ScriptDir "\config.ini", true
    ; Run "master_switch.exe"
    ; Run "text_x.exe"
    ; FileDelete "master_switch_old.exe"
    ; FileDelete "text_x_old.exe"
} else {
    MsgBox "No Updates found"
}