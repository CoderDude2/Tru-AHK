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
EspStep4ReadyMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_FILE_STEP_4_READY")
GetMacroButtonCodeMsg := DllCall("RegisterWindowMessageW", "Str", "GET_MACRO_BUTTON_COMMAND")
EspExecuteCommandMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_EXECUTE_COMMAND")

EspFileLoadedMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_FILE_LOADED")
EspFileCenteredMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_FILE_CENTERED")
EspFileOrientedMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_FILE_ORIENTED")

suspend_event_num := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
terminate_event_num := DllCall("RegisterWindowMessageA", "Str", "Terminate")

DocumentOpen := false
EspFileReady := false
EspStep4Ready := false

EspFileLoaded := false
EspFileCentered := false
EspFileOriented := false

OnMessage(suspend_event_num, SuspendScript)
OnMessage(terminate_event_num, TerminateScript)
OnMessage(ESPAfterDocumentOpenMsg, OnEspAfterDocumentOpen)
OnMessage(EspFileReadyMsg, OnEspFileReady)
OnMessage(EspStep4ReadyMsg, OnEspStep4Ready)

OnMessage(EspFileLoadedMsg, OnEspFileLoaded)
OnMessage(EspFileCenteredMsg, OnEspFileCentered)
OnMessage(EspFileOrientedMsg, OnEspFileOriented)

OnEspFileLoaded(wParam, lParam, msg, hwnd){
    global EspFileLoaded
    if wParam == esp_id{
        EspFileLoaded := true
    }
}

OnEspFileCentered(wParam, lParam, msg, hwnd){
    global EspFileCentered
    if wParam == esp_id{
        EspFileCentered := true
    }
}
OnEspFileOriented(wParam, lParam, msg, hwnd){
    global EspFileOriented
    if wParam == esp_id{
        EspFileOriented := true
    }
}

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

OnEspStep4Ready(wParam, lParam, msg, hwnd){
    global EspStep4Ready
    if wParam == esp_id{
        EspStep4Ready := true
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
    ; esp_info := get_active_esprit_info()
    PostMessage(EspExecuteCommandMsg, esp_id, command, , 0xFFFF)
}

file_map := ComObjActive("{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

check_window_exist(){
    global esp_pid
    if not ProcessExist(esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

#HotIf WinActive("ahk_pid" esp_pid)

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
                    old_ds_startup_commands(esp_pid, esp_id)
                case "ASC":
                    old_asc_startup_commands(esp_pid, esp_id)
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
    case "new":
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
                    lower_margins := ds_startup_commands(esp_pid, esp_id)
                    go_to_next_esprit(esp_id)
                    While Not EspStep4Ready{
                        Sleep(1)
                    }
                    ; WinWaitActive("ahk_pid" esp_pid)
                    ; yn := show_custom_dialog("Lower margin values?", "Tru-AHK", esp_id)
                    bottom_z_limit := -5
                    ExecuteMacroButtonCommand(4)
                    cam_automation_id := WinWaitTitleWithPID(esp_pid, "CAM Automation", "[4] Rebuild Freeform")
                    send_WM_COPYDATA("CREATE_CROSSBALLS", "ahk_id" esp_id)
                    send_WM_COPYDATA("CREATE_MARGINS", "ahk_id" esp_id)
                    ; if yn == "Yes"{
                    ;     send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
                    ;     send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
                    ;     send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
                    ;     send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
                    ; }
                    send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_id)
                    send_WM_COPYDATA("BUILD_ESP", "ahk_id" esp_id)
                    ControlSend("{Enter}", "Button1", "CAM Automation", "[4] Rebuild Freeform With Part & Check Elements.")
                    WinWaitClose("ahk_id" cam_automation_id)
                    if lower_margins == "Yes"{
                        send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
                        send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
                        send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
                        send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
                    }
                case "ASC":
                    lower_margins := asc_startup_commands(esp_pid, esp_id)
                    go_to_next_esprit(esp_id)
                    While Not EspStep4Ready{
                        Sleep(1)
                    }
                    ; WinWaitActive("ahk_pid" esp_pid)
                    ; yn := show_custom_dialog("Are the roughs correct?", "Tru-AHK", esp_id)
                    bottom_z_limit := -5
                    ExecuteMacroButtonCommand(4)
                    cam_automation_id := WinWaitTitleWithPID(esp_pid, "CAM Automation", "[4] Rebuild Freeform")
                    
                    send_WM_COPYDATA("CREATE_CROSSBALLS", "ahk_id" esp_id)
                    send_WM_COPYDATA("CREATE_MARGINS", "ahk_id" esp_id)
                    send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_id)
                    send_WM_COPYDATA("BUILD_ESP", "ahk_id" esp_id)
                    ControlSend("{Enter}", "Button1", "CAM Automation", "[4] Rebuild Freeform With Part & Check Elements.")
                    WinWaitClose("ahk_id" cam_automation_id)
                    if lower_margins == "Yes"{
                        send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
                    }
                case "TLOC": 
                    tl_aot_startup_commands(esp_pid, esp_id)
                case "AOT":
                    tl_aot_startup_commands(esp_pid, esp_id)
                default: 
                    return
            }
            ; PostMessage(ESPInitCompleteMsg, , , ,0xFFFF)
            ExitApp
        }
    case "new_manual":
        selected_file := FileSelect(, STL_FILE_PATH)
        found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
        if(selected_file != "" and found_pos){
            SplitPath(selected_file, &name)
            if mtx.Lock() == 0 {
                file_map.data[name] := true
                mtx.Release()
            }
            send_WM_COPYDATA("OPENANDINITSTL " name, "ESPRIT - ")

            While Not EspFileReady{
                Sleep(1)
            }

            yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
            if yn != "Yes"{
                ExitApp
            }
            ExecuteMacroButtonCommand(2)

            send_WM_COPYDATA("DISABLE_LAYER:BACK TURNING", "ESPRIT - ")
            send_WM_COPYDATA("DISABLE_LAYER:CUT-OFF", "ESPRIT - ")
            send_WM_COPYDATA("ENABLE_LAYER:FRONT TURNING", "ESPRIT - ")

            base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
            WinWaitClose("ahk_id" base_work_id)
            PostMessage(ESPInitCompleteMsg, , , ,0xFFFF)
            
            ; Send("{Enter}")
            ; switch get_case_type(name) {
            ;     case "DS":
            ;         lower_margins := ds_startup_commands(esp_pid, esp_id)
            ;         consolelog(lower_margins)
            ;         go_to_next_esprit(esp_id)
            ;         While Not EspStep4Ready{
            ;             Sleep(1)
            ;         }
            ;         ; WinWaitActive("ahk_pid" esp_pid)
                    
            ;         bottom_z_limit := -5
            ;         ExecuteMacroButtonCommand(4)
            ;         cam_automation_id := WinWaitTitleWithPID(esp_pid, "CAM Automation", "[4] Rebuild Freeform")
            ;         send_WM_COPYDATA("CREATE_CROSSBALLS", "ahk_id" esp_id)
            ;         send_WM_COPYDATA("CREATE_MARGINS", "ahk_id" esp_id)
            ;         ; yn := show_custom_dialog("Lower margin values?", "Tru-AHK", esp_id)
            ;         send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_id)
            ;         send_WM_COPYDATA("BUILD_ESP", "ahk_id" esp_id)
            ;         ControlSend("{Enter}", "Button1", "CAM Automation", "[4] Rebuild Freeform With Part & Check Elements.")
            ;         WinWaitClose("ahk_id" cam_automation_id)
            ;         if lower_margins == "Yes"{
            ;             send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
            ;             send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
            ;             send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
            ;             send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
            ;         }
            ;     case "ASC":
            ;         lower_margins := asc_startup_commands(esp_pid, esp_id)
            ;         go_to_next_esprit(esp_id)
            ;         While Not EspStep4Ready{
            ;             Sleep(1)
            ;         }
            ;         ; WinWaitActive("ahk_pid" esp_pid)
            ;         ; yn := show_custom_dialog("Are the roughs correct?", "Tru-AHK", esp_id)
            ;         bottom_z_limit := -5
            ;         ExecuteMacroButtonCommand(4)
            ;         cam_automation_id := WinWaitTitleWithPID(esp_pid, "CAM Automation", "[4] Rebuild Freeform")
                    
            ;         send_WM_COPYDATA("CREATE_CROSSBALLS", "ahk_id" esp_id)
            ;         send_WM_COPYDATA("CREATE_MARGINS", "ahk_id" esp_id)
            ;         send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_id)
            ;         send_WM_COPYDATA("BUILD_ESP", "ahk_id" esp_id)
                    
            ;         ControlSend("{Enter}", "Button1", "CAM Automation", "[4] Rebuild Freeform With Part & Check Elements.")
            ;         WinWaitClose("ahk_id" cam_automation_id)
            ;         if lower_margins == "Yes"{
            ;             send_WM_COPYDATA("LOWER_MARGINS", "ahk_id" esp_id)
            ;         }
            ;     case "TLOC": 
            ;         tl_aot_startup_commands(esp_pid, esp_id)
            ;     case "AOT":
            ;         tl_aot_startup_commands(esp_pid, esp_id)
            ;     default: 
            ;         return
            ; }
            ; ; PostMessage(ESPInitCompleteMsg, , , ,0xFFFF)
            ; ExitApp
        }
    case "new_auto":
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
            ; send_WM_COPYDATA("OPENANDINITSTL " name, "ESPRIT - ")
            send_WM_COPYDATA("LOAD_STL " name, "ESPRIT - ")
            
            While Not EspFileLoaded{
                Sleep(1)
            }

            send_WM_COPYDATA("CENTER_STL " name, "ESPRIT - ")

            While Not EspFileCentered{
                Sleep(1)
            }

            send_WM_COPYDATA("ORIENT_STL " name, "ESPRIT - ")

            While Not EspFileOriented{
                Sleep(1)
            }

            deg0("ahk_id" esp_id)
            yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
            if yn != "Yes"{
                ExitApp
            }
            
            consolelog("[Tru-AHK] Rotate to desired angle and press either 3 or 4")
            numOfSides := 3
            Loop {
                ih := InputHook("L1", "34{Numpad3}{Numpad4}{Enter}{NumpadEnter}{Space}{LShift}")
                ih.Start()
                ih.Wait()
                keyName := GetKeyName(ih.EndKey)
                if keyName == "3" or keyName == "Numpad3" or keyName == "Enter" or keyName == "NumpadEnter" or keyName == "Space"{
                    numOfSides := 3
                    break
                } else if keyName == "4" or keyName == "Numpad4" or keyName == "LShift"{
                    numOfSides := 4
                    break
                }
                consolelog("[Tru-AHK] Invalid input")
            }
            selected_view := get_current_angle("ahk_id" esp_id) - 7

            deg0("ahk_id" esp_id)
            send_WM_COPYDATA("CREATE_FRONT_TURNING " name, "ESPRIT - ")
            ExecuteMacroButtonCommand(2)

            send_WM_COPYDATA("DISABLE_LAYER:BACK TURNING", "ESPRIT - ")
            send_WM_COPYDATA("DISABLE_LAYER:CUT-OFF", "ESPRIT - ")
            send_WM_COPYDATA("ENABLE_LAYER:FRONT TURNING", "ESPRIT - ")

            base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
            Loop selected_view{
                ControlSend("{Down}", , "ahk_id" base_work_id)
            } 
            ControlSend("{Tab}{Tab}", , "ahk_id" base_work_id)
            if numOfSides == 3 {
                ControlSend("{Up}", , "ahk_id" base_work_id)
            }
            ControlSend("{Tab}{Tab}{Enter}", , "ahk_id" base_work_id)
            WinWaitClose("ahk_id" base_work_id)

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
                    old_ds_startup_commands(esp_pid, esp_id)
                case "ASC":
                    old_asc_startup_commands(esp_pid, esp_id)
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