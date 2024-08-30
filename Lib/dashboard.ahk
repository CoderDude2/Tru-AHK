#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "updater.ahk"

showInspector := False
setMacroBar := False
setProjectManager := False
SetTimer(inspector, 20)

inspector(){
    try{
        if(showInspector){
            MouseGetPos(&posX, &posY, &window, &active_control)
            ToolTip("(" posX "," posY ")`n" WinGetTitle(window) "`n" active_control, posX, posY+20)
        } else {
            ToolTip()
        }
    } 
}

^f3::{
    global showInspector
    showInspector := !showInspector
}

prefs_file_path := IniRead("config.ini", "info", "user_preferences")

try {
    f12_mode := IniRead(prefs_file_path, "f12_mode", "value")
} catch {
    IniWrite("All Instances", prefs_file_path, "f12_mode", "value")
    f12_mode := "All Instances"
}

try {
    w_as_delete := IniRead(prefs_file_path, "w_as_delete", "value")
} catch {
    IniWrite(true, prefs_file_path, "w_as_delete", "value")
    w_as_delete := true
}

try {
    macro_bar_control := IniRead(prefs_file_path, "macro_bar_control", "control")
} catch {
    IniWrite("", prefs_file_path, "macro_bar_control", "control")
    macro_bar_control := ""
}

try {
    project_manager_control := IniRead(prefs_file_path, "project_manager_control", "control")
} catch {
    IniWrite("", prefs_file_path, "project_manager_control", "control")
    project_manager_control := ""
}

try {
    is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")
} catch {
    IniWrite(true, prefs_file_path, "project_manager_control", "is_attached")
    is_attached := true
}

remote_path := IniRead("config.ini", "info", "remote_path")

root := Gui()
root.Title := "Tru-AHK Dashboard"
; root.show("w300 h325")

root.AddGroupBox("r2.5 Section w275 y+5","Help")
hotkey_list_btn := root.Add("Button","xp+5 yp+15","Hotkey List")
hotkey_list_btn.OnEvent("Click", open_help)

changelog_btn := root.Add("Button"," yp+30","Open Changelog")
changelog_btn.OnEvent("Click", open_changelog)

root.AddGroupBox("r3.4 xs w275", "Settings")
root.Add("Text","xp+5 yp+20","F12 Mode")
f12_dropdown := root.Add("DropDownList","vf12_options xp+0 yp+15",["Disabled","Active Instance", "All Instances"])
f12_dropdown.Choose(f12_mode)
f12_dropdown.OnEvent("Change", setF12Mode)

w_checkbox := root.Add("CheckBox","h20 yp+30","W as Delete Key")
w_checkbox.value := w_as_delete
w_checkbox.OnEvent("Click", setWMode)

root.AddText("Section xs","Macro Bar Control")
macro_edit := root.AddEdit("r1 Section w225")
macro_edit.value := macro_bar_control
set_macro_control_btn := root.AddButton("ys xp+225 w50 h20","Set")
set_macro_control_btn.OnEvent("Click", setMacroBarControlCallback)


root.AddText("Section xs y+15","Project Manager Control")
project_manager_edit := root.AddEdit("r1 Section vProjectManagerEdit w225")
project_manager_edit.value := project_manager_control

set_project_manager_control_btn := root.AddButton("ys xp+225 w50 h20","Set")
set_project_manager_control_btn.OnEvent("Click", setProjectManagerControlCallback)

is_attached_checkbox := root.AddCheckbox("xs","Is Attached")
is_attached_checkbox.value := is_attached
is_attached_checkbox.OnEvent("Click", setProjectManagerControlIsAttached)

setF12Mode(*){
    IniWrite(f12_dropdown.Text, prefs_file_path, "f12_mode", "value")
}

setWMode(*){
    IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
}

setMacroBarControlCallback(*){
    global showInspector
    global setMacroBar
    global setProjectManager

    set_macro_control_btn.Opt("+Disabled")
    showInspector := True
    setProjectManager := False
    setMacroBar := True
    WinActivate("ESPRIT")
}

setProjectManagerControlCallback(*){
    global showInspector
    global setMacroBar
    global setProjectManager

    set_project_manager_control_btn.Opt("+Disabled")
    showInspector := True
    setProjectManager := True
    setMacroBar := False
    WinActivate("ESPRIT")
}

setMacroBarControl(class_nn){
    global showInspector
    global setMacroBar
    global setProjectManager

    showInspector := False
    setProjectManager := False
    setMacroBar := False

    IniWrite(class_nn, prefs_file_path, "macro_bar_control", "control")
    set_macro_control_btn.Opt("-Disabled")
    macro_edit.value := class_nn
}

setProjectManagerControl(class_nn){
    global showInspector
    global setMacroBar
    global setProjectManager

    showInspector := False
    setProjectManager := False
    setMacroBar := False

    IniWrite(class_nn, prefs_file_path, "project_manager_control", "control")
    set_project_manager_control_btn.Opt("-Disabled")
    project_manager_edit.value := class_nn
}

setProjectManagerControlIsAttached(*){
    IniWrite(is_attached_checkbox.value, prefs_file_path, "project_manager_control", "is_attached")
}

root.OnEvent("Close", OnClose)
onClose(*){
    root.Hide()
}

Gui_Size(thisGui, MinMax, Width, Height){
    if MinMax = -1
        return
}

open_dashboard(*){
    root.Show()
}

cancel_all_set(){
    global showInspector
    global setMacroBar
    global setProjectManager

    showInspector := False
    setMacroBar := False
    setProjectManager := False

    set_macro_control_btn.Opt("-Disabled")
    set_project_manager_control_btn.Opt("-Disabled")
}