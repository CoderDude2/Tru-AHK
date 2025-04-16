#SingleInstance Off 
#NoTrayIcon
SetDefaultMouseSpeed 0

#Include %A_ScriptDir%\Lib\restore.ahk
#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\nav.ahk


STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"
ESP_FILE_PATH := "C:\Users\TruUser\Desktop\작업\작업저장"


if A_Args.Length < 4 {
   ExitApp -1 
}


esp_pid := A_Args[1]
esp_id := A_Args[2]
file_name := A_Args[3]
basic_setting := A_Args[4]


; MsgBox(esp_pid "`n" esp_id "`n" file_name "`n" basic_setting)


if WinGetProcessName("ahk_pid" esp_pid) != "esprit.exe" {
   ExitApp -1 
}


if WinGetProcessName("ahk_id" esp_id) != "esprit.exe" {
   ExitApp -1 
}


if not FileExist(basic_setting) {
    ExitApp -1 
}


STL_FILE := STL_FILE_PATH "\" file_name ".stl"
ESP_FILE := ESP_FILE_PATH "\" file_name ".esp"


show_custom_dialog(msg, title){
    WINDOW_INFO_PATH := A_AppData "\tru-ahk\windows.ini"

    if not FileExist(WINDOW_INFO_PATH){
        FileAppend("", WINDOW_INFO_PATH)
    }

    ui_pos_x := IniRead(WINDOW_INFO_PATH, title "_" msg, "x", A_ScreenWidth/2 - 142)
    ui_pos_y := IniRead(WINDOW_INFO_PATH, title "_" msg, "y", A_ScreenHeight/2 - 51)
    
    response := ""
    custom_dialog_gui := Gui("+AlwaysOnTop")
    custom_dialog_gui.BackColor := "0xFFFFFF"
    custom_dialog_gui.Title := title
    custom_dialog_gui.AddText("x11 y23 w243 h15", msg)

    custom_dialog_gui.AddButton("x27 y68 w75 h23 +Default","Yes").OnEvent("Click", (*) => (
        response := "Yes"
        save_coordinates()
        custom_dialog_gui.Hide()
    ))

    custom_dialog_gui.AddButton("x110 y68 w75 h23","No").OnEvent("Click", (*) => (
        response := "No"
        save_coordinates()
        custom_dialog_gui.Hide()
    ))

    custom_dialog_gui.AddButton("x194 y68 w75 h23","Cancel").OnEvent("Click", (*) => (
        response := "Cancel"
        save_coordinates()
        custom_dialog_gui.Hide()
        
    ))

    custom_dialog_gui.OnEvent("Close", (*) => (
        save_coordinates()
        response := ""
    ))
    
    custom_dialog_gui.Show("w284 h101 x" ui_pos_x " y" ui_pos_y)
    WinWaitClose("ahk_id " custom_dialog_gui.Hwnd)
    return response

    save_coordinates(){
        custom_dialog_gui.GetPos(&posx, &posy)
        IniWrite(posx, WINDOW_INFO_PATH, title "_" msg, "x")
        IniWrite(posy, WINDOW_INFO_PATH, title "_" msg, "y")
    }
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


open_file(){
	PostMessage 0x111, 57601 , , , "ahk_id" esp_id
}


open_esp_file(esp_file, esp_pid, esp_id) {
    WinActivate("ahk_id " esp_id)
    CoordMode("Mouse", "Client")
    click_and_return(25, 105)
    WinWaitActive("CAM Automation")
    Send("{Enter}")
    select_file_dialog_id := WinWaitActiveTitleWithPID(esp_pid, "Select file to open")
    Sleep(200)
    ControlSetText(esp_file, "Edit1", "ahk_id " select_file_dialog_id)
    Send("{Enter}")
}


remove_stl_file() {
    if FileExist(STL_FILE){
        FileRecycle(STL_FILE)        
    }
}


WinExistTitleWithPID(pid, title, text := unset) {
    ids := WinGetList(title, text?)
    for this_id in ids {
        if WinGetPID("ahk_id" this_id) == pid {
            return True
        }
    }
    return False
}


WinActivateTitleWithPID(pid, title, text := unset){
    ids := WinGetList(title, text?)
    for this_id in ids {
        if WinGetPID("ahk_id " this_id) == pid {
            WinActivate("ahk_id " this_id)
            return
        }
    }
}


WinWaitTitleWithPID(pid, title, text := unset, timeout := unset) {
    milliseconds := 0
    while True {
        if IsSet(timeout) {
            if milliseconds >= timeout {
                return
            }
        }

        if WinExistTitleWithPID(pid, title, text?) {
            return WinGetID(title, text?)
        }
        milliseconds += 10
        Sleep(10)
    }
}


WinWaitActiveTitleWithPID(pid, title, text := unset){
    while true {
        esp_id := WinWaitActive(title, text?)
        if WinGetPID("ahk_id " esp_id) == pid {
            return esp_id 
        }
    }
    return -1
}


WinWaitCloseTitleWithPID(pid, title, text := unset)  {
    while WinExistTitleWithPID(pid, title, text?) {
        Sleep(1)
    }
}


ds_startup_commands(esp_pid, esp_id){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check", "OK"){
			Send("{Enter}")
		}
	}
    WinActivate("ahk_id " esp_id)
	deg0()
    save_and_create_checkpoint("connection_check", esp_id)
    yn := show_custom_dialog("Is the connection correct?", "Tru-AHK")
    if yn != "Yes"{
        return
    }
	WinActivateTitleWithPID(esp_pid, "STL Rotate")
	CoordMode("Mouse", "Client")
	Click("65 115")
	base_workplane_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
    save_and_create_checkpoint("front_turning", esp_id)
	WinWaitClose("ahk_id " base_workplane_id)
    WinWaitActiveTitleWithPID(esp_pid, "Check Rough ML & Create Border Solid")
    save_and_create_checkpoint("rough_check", esp_id)
    remove_stl_file() 
}


asc_startup_commands(esp_pid, esp_id){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check", "OK"){
			Send("{Enter}")
		}
	}
    WinActivate("ahk_id " esp_id)
	deg0()
	yn := show_custom_dialog("Is the connection correct?", "Tru-AHK")
    if yn != "Yes"{
        return
    }
	WinActivateTitleWithPID(esp_pid, "STL Rotate")
	CoordMode("Mouse", "Client")
	Click("60 147")

    base_workplane_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
	WinWaitClose("ahk_id " base_workplane_id)
    WinWaitActiveTitleWithPID(esp_pid, "Check Rough ML & Create Border Solid")
    remove_stl_file() 
}

load_basic_setting(basic_setting){
    open_file()
    open_id := WinWaitActiveTitleWithPID(esp_pid, "Open", "&Open")
    ControlSetText(basic_setting, "Edit1", "ahk_id" open_id)
    ControlSetChecked(0, "Button5", "ahk_id" open_id)
    ControlSend("{Enter}", "Button2", "ahk_id" open_id)
}

; MsgBox(STL_FILE "`n" ESP_FILE "`n" basic_setting "`n" esp_pid " " esp_id)
load_basic_setting(basic_setting)
are_you_sure := WinWaitTitleWithPID(esp_pid, "esprit", "&Yes", 500)
if are_you_sure {
    WinWaitClose("ahk_id" are_you_sure, "&Yes")
}

yn := MsgBox("Is the basic setting loaded?", , "YesNoCancel")
if yn != "Yes"{
    return
}

macro_button1("ahk_id" esp_id)
cam_automation := WinWaitActiveTitleWithPID(esp_pid, "CAM Automation", "&Yes")
ControlSend("{Enter}", "Button1", "ahk_id" cam_automation)

select_file_to_open := WinWaitActiveTitleWithPID(esp_pid, "Select file to open", "&Open")
ControlSetText(STL_FILE, "Edit1", "ahk_id" select_file_to_open) 
ControlSend("{Enter}", "Button1", "ahk_id" select_file_to_open)

switch get_case_type(file_name) {
    case "DS":
        ds_startup_commands(esp_pid, esp_id)
    case "ASC":
        asc_startup_commands(esp_pid, esp_id)
    default:
        ExitApp
}

check_window_exist(){
    if not WinExist("ahk_pid" esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

#HotIf WinActive("ahk_pid" esp_pid)
^i::{
    MsgBox(esp_pid)
}

^+i::{
    ExitApp
}
