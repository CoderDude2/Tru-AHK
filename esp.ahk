#Requires AutoHotkey v2.0
#SingleInstance Off

SetDefaultMouseSpeed(0)

#Include Lib\views.ahk
#Include Lib\util.ahk
#Include Lib\nav.ahk


STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

mtx := Mutex("Local\FileMutex")

esp_pid := A_Args[1]
startup_command := A_Args[2]

suspend_event_num := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
terminate_event_num := DllCall("RegisterWindowMessageA", "Str", "Terminate")
OnMessage(suspend_event_num, SuspendScript)
OnMessage(terminate_event_num, TerminateScript)

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

file_map := ComObjActive("{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

check_window_exist(){
    if not ProcessExist(esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

open_file(){
	PostMessage 0x111, 57601 , , , "ahk_id" esp_id
}

get_case_type(title){
    if InStr(title, "AOT", true) {
        return "AOT"
    } else if InStr(title, "TLOC", true) {
        return "TLOC"
    } else if InStr(title, "T-L", true) {
        return "TLOC"
    } else if InStr(title, "ASC", true) {
        return "ASC"
    } else if InStr(title, "TA", true) {
        return "DS"
    } else {
        return -1
    }
}

remove_stl_file(STL_FILE_PATH) {
    if FileExist(STL_FILE_PATH){
        FileRecycle(STL_FILE_PATH)        
    }
}

ds_startup_commands(){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        try{
            win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
            if win_1 {
                ControlSend("{Enter}", , "ahk_id" win_1)
            }
        }
        
        try{
            win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
            if win_2 {
                ControlSend("{Enter}", , "ahk_id" win_2)
            }
        }

        try{
            win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
            if win_3 {
                ControlSend("{Enter}", , "ahk_id" win_3)
            }
        }
	}
    stl_rotate_id := WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
	deg0("ahk_id" esp_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        ; remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
    yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
    if yn != "Yes"{
        ExitApp
    }
    WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("65 115")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
	WinWaitClose("ahk_id" base_work_id)
    ExitApp
}

asc_startup_commands(){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
        if win_1 {
            ControlSend("{Enter}", , "ahk_id" win_1)
        }

        win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
        if win_2 {
            ControlSend("{Enter}", , "ahk_id" win_2)
        }

        win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
        if win_3 {
            ControlSend("{Enter}", , "ahk_id" win_3)
        }
	}
	stl_rotate_id := WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
	WinActivate("ahk_id" esp_id)
	deg0("ahk_id" esp_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        ; remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
	yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
    if yn != "Yes"{
        ExitApp
    }
	WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("60 147")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
	WinWaitClose("ahk_id" base_work_id)
    ExitApp
}

tl_aot_startup_commands(){
    while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        try{
            win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
            if win_1 {
                ControlSend("{Enter}", , "ahk_id" win_1)
            }
        }
        
        try{
            win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
            if win_2 {
                ControlSend("{Enter}", , "ahk_id" win_2)
            }
        }

        try{
            win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
            if win_3 {
                ControlSend("{Enter}", , "ahk_id" win_3)
            }
        }
	}
    WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
    deg0("ahk_id" esp_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        ; remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
    ExitApp
}

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
            open_file()
            WinWaitTitleWithPID(esp_pid, "Open", "&Open")
            open_id := WinActivateTitleWithPID(esp_pid, "Open", "&Open")
            ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_id" open_id)
            ControlSetChecked(0,"Button5","ahk_id" open_id)
            ControlSend("{Enter}", "Button2","ahk_id" open_id)
            are_you_sure_id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "&Yes", 1)
            if are_you_sure_id {
                WinWaitClose("ahk_id" are_you_sure_id)
            }
            yn := show_custom_dialog("Is the basic setting loaded?", "Tru-AHK", esp_id)
            if yn != "Yes"{
                if mtx.Lock() == 0 {
                    file_map.data[name] := false
                    mtx.Release()
                }
                ExitApp 
            }
            WinActivate("ahk_id" esp_id)
            macro_button1("ahk_id" esp_id)
            WinWaitActiveTitleWithPID(esp_pid, "CAM Automation")
            Send("{Enter}")
            WinWaitActiveTitleWithPID(esp_pid, "Select file to open")
            Sleep(200)
            ControlSetText(selected_file, "Edit1", "Select file to open")
            Send("{Enter}")
            switch get_case_type(selected_file) {
                case "DS":
                    ds_startup_commands()
                case "ASC":
                    asc_startup_commands()
                case "TLOC": 
                    tl_aot_startup_commands()
                case "AOT":
                    tl_aot_startup_commands()
                default: 
                    return
            }
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
            open_file()
            WinWaitTitleWithPID(esp_pid, "Open", "&Open")
            open_id := WinActivateTitleWithPID(esp_pid, "Open", "&Open")
            ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_id" open_id)
            ControlSetChecked(0,"Button5","ahk_id" open_id)
            ControlSend("{Enter}", "Button2","ahk_id" open_id)
            are_you_sure_id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "&Yes", 1)
            if are_you_sure_id {
                WinWaitClose("ahk_id" are_you_sure_id)
            }
            yn := show_custom_dialog("Is the basic setting loaded?", "Tru-AHK", esp_id)
            if yn != "Yes"{
                if mtx.Lock() == 0 {
                    file_map.data[name] := false
                    mtx.Release()
                }
                ExitApp 
            }
            WinActivate("ahk_id" esp_id)
            macro_button1("ahk_id" esp_id)
            WinWaitActiveTitleWithPID(esp_pid, "CAM Automation")
            Send("{Enter}")
            WinWaitActiveTitleWithPID(esp_pid, "Select file to open")
            Sleep(200)
            ControlSetText(selected_file, "Edit1", "Select file to open")
            Send("{Enter}")
            switch get_case_type(selected_file) {
                case "DS":
                    ds_startup_commands()
                case "ASC":
                    asc_startup_commands()
                case "TLOC": 
                    tl_aot_startup_commands()
                case "AOT":
                    tl_aot_startup_commands()
                default: 
                    return
            }
            ExitApp
        }
}