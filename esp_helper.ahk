#SingleInstance Off 
; #NoTrayIcon
SetDefaultMouseSpeed 0

#Include %A_ScriptDir%\Lib\restore.ahk
#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\nav.ahk
#Include %A_ScriptDir%\Lib\commands.ahk


STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"
ESP_FILE_PATH := "C:\Users\TruUser\Desktop\작업\작업저장"


if A_Args.Length < 4 {
   ExitApp -1 
}


esp_pid := A_Args[1]
esp_id := A_Args[2]
file_name := A_Args[3]
basic_setting := A_Args[4]

ESP_PID_FORMATTED := "ahk_pid" esp_pid

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
        if WinGetPID("ahk_id " esp_id) == esp_pid {
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


ds_startup_commands_pid(esp_pid, esp_id){
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
    remove_stl_file(STL_FILE) 
}


asc_startup_commands_pid(esp_pid, esp_id){
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
    remove_stl_file(STL_FILE) 
}

load_basic_setting(basic_setting){
    open_file()
    open_id := WinWaitActiveTitleWithPID(esp_pid, "Open", "&Open")
    ControlSetText(basic_setting, "Edit1", "ahk_id" open_id)
    ControlSetChecked(0, "Button5", "ahk_id" open_id)
    ControlSend("{Enter}", "Button2", "ahk_id" open_id)
}
check_window_exist(){
    if not WinExist("ahk_pid" esp_pid) {
        ExitApp
    }
}
; MsgBox(STL_FILE "`n" ESP_FILE "`n" basic_setting "`n" esp_pid " " esp_id)
init_file() {
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
            ds_startup_commands_pid(esp_pid, esp_id)
        case "ASC":
            asc_startup_commands_pid(esp_pid, esp_id)
        default:
            ExitApp
    }
}

init_file()

SetTimer(check_window_exist, 100)

#HotIf WinActive("ahk_pid" esp_pid)
^i::{
    MsgBox(esp_pid)
}

^+i::{
    ExitApp
}

; ===== View Controls=====

a::{
    try{
        deg0("ahk_id" esp_id)
    }
}

s::{
    try{
        deg90("ahk_id" esp_id)
    }
}

d::{
    try{
        deg180("ahk_id" esp_id)
    }
}

f::{
    try{
        deg270("ahk_id" esp_id)
    }
}

c::{
    try{
        face("ahk_id" esp_id)
    }
}

v::{
    try{
        rear("ahk_id" esp_id)
    }
}

!WheelDown::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        
        increment_10_degrees("ahk_id" esp_id)
    }
}

+!WheelDown::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        increment_90_degrees("ahk_id" esp_id)
    }
}

!WheelUp::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        decrement_10_degrees("ahk_id" esp_id)
    }
}

+!WheelUp::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        decrement_90_degrees("ahk_id" esp_id)
    }
}

f14::{
    solid_view("ahk_id" esp_id)
}

; Tilde(~) key
`::{
    wireframe_view("ahk_id" esp_id)
}
