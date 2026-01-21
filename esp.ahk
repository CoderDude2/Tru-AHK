#Requires AutoHotkey v2.0
#SingleInstance Off

SetDefaultMouseSpeed(0)

#Include Lib\views.ahk
#Include Lib\util.ahk
#Include Lib\nav.ahk
#Include Lib\restore.ahk
#Include Lib\commands.ahk

STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

mtx := Mutex("Local\FileMutex")

esp_pid := A_Args[1]
startup_command := A_Args[2]

ESPAfterDocumentOpenMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_AFTER_DOCUMENT_OPEN")
ESPInitCompleteMsg := DllCall("RegisterWindowMessageA", "Str", "ESPInitCompleteMsg")
EspFileReadyMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_FILE_READY")
GetMacroButtonCodeMsg := DllCall("RegisterWindowMessageW", "Str", "GET_MACRO_BUTTON_COMMAND")

suspend_event_num := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
terminate_event_num := DllCall("RegisterWindowMessageA", "Str", "Terminate")

DocumentOpen := false
EspFileReady := false

OnMessage(suspend_event_num, SuspendScript)
OnMessage(terminate_event_num, TerminateScript)
OnMessage(ESPAfterDocumentOpenMsg, OnEspAfterDocumentOpen)
OnMessage(EspFileReadyMsg, OnEspFileReady)

OnEspAfterDocumentOpen(wParam, lParam, msg, hwnd){
    global DocumentOpen
    if wParam == esp_id{
        DocumentOpen := true
    }
}

OnEspFileReady(wParam, lParam, msg, hwnd){
    global EspFileReady
    if wParam == esp_id{
        EspFileReady := true
    }
}

SuspendScript(wParam, lParam, msg, hwnd){
    Suspend(-1)
}

TerminateScript(wParam, lParam, msg, hwnd){
    ExitApp
}

esp_id := unset
while True {
    id_ := WinWaitActive("ESPRIT - ")
    pid := WinGetPID("ahk_id" id_)
    if pid == esp_pid {
        esp_id := id_
        break
    }
}

ExecuteMacroButtonCommand(command){
    PostMessage(GetMacroButtonCodeMsg, esp_id, command, , 0xFFFF)
}

file_map := ComObjActive("{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

check_window_exist(){
    if not ProcessExist(esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

#HotIf WinActive("ahk_pid" esp_pid)
Up::{
    decrement_10_degrees("ahk_id" esp_id)
}

Down::{
    increment_10_degrees("ahk_id" esp_id)
}

; G4
switch startup_command {
    case "auto":
        selected_file := ""
        For k,v in file_map.data {
            if v = False and FileExist(STL_FILE_PATH "\" k){
                selected_file := k
                break
            }
        }
        found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
        if found_pos {
            SplitPath(selected_file, &name)
            if mtx.Lock() == 0 {
                file_map.data[name] := true
                mtx.Release()
            }
            send_WM_COPYDATA("LOADFILE " name, "ESPRIT - ")

            While Not DocumentOpen {
                Sleep(1)
            }

            While Not EspFileReady{
                Sleep(1)
            }

            WinActivate("ahk_id" esp_id)
            ; Macro Button 1
            ExecuteMacroButtonCommand(1)
            WinWaitActiveTitleWithPID(esp_pid, "CAM Automation")
            Send("{Enter}")
            switch get_case_type(name) {
                case "DS":
                    ds_startup_commands(esp_pid, esp_id)
                case "ASC":
                    asc_startup_commands(esp_pid, esp_id)
                case "TLOC": 
                    tl_aot_startup_commands(esp_pid, esp_id)
                case "AOT":
                    tl_aot_startup_commands(esp_pid, esp_id)
                default: 
                    return
            }
            PostMessage(ESPInitCompleteMsg, , , ,0xFFFF)
            ExitApp
        }
    case "manual":
        selected_file := FileSelect(, STL_FILE_PATH)
        found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
        if(selected_file != "" and found_pos){
            SplitPath(selected_file, &name)
            if mtx.Lock() == 0 {
                file_map.data[name] := true
                mtx.Release()
            }
            send_WM_COPYDATA("LOADFILE " name, "ESPRIT - ")

            While Not DocumentOpen {
                Sleep(1)
            }

            While Not EspFileReady{
                Sleep(1)
            }

            WinActivate("ahk_id" esp_id)
            ; Macro Button 1
            ExecuteMacroButtonCommand(1)
            WinWaitActiveTitleWithPID(esp_pid, "CAM Automation")
            Send("{Enter}")
            switch get_case_type(name) {
                case "DS":
                    ds_startup_commands(esp_pid, esp_id)
                case "ASC":
                    asc_startup_commands(esp_pid, esp_id)
                case "TLOC": 
                    tl_aot_startup_commands(esp_pid, esp_id)
                case "AOT":
                    tl_aot_startup_commands(esp_pid, esp_id)
                default: 
                    return
            }
            ExitApp
        }
}