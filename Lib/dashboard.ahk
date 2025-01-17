#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "updater.ahk"

prefs_file_path := A_AppData "\tru-ahk\prefs.ini"
prefs_directory := A_AppData "\tru-ahk"

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

if(!FileExist(prefs_file_path)){
    create_default_prefs_file()
}

try {
    f12_mode := IniRead(prefs_file_path, "f12_mode", "value")
} catch {
    IniWrite("All Instances", prefs_file_path, "f12_mode", "value")
    f12_mode := "All Instances"
}

try {
    e_key_functionality := IniRead(prefs_file_path, "e_key_functionality", "value")
} catch {
    IniWrite("Line and Border", prefs_file_path, "e_key_functionality", "value")
    e_key_functionality := "Line and Border"
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

try {
    language := IniRead(prefs_file_path, "language", "value")
} catch {
    IniWrite("en", prefs_file_path, "language", "value")
    language := "en"
}

root := Gui("AlwaysOnTop")
root.Title := "Tru-AHK Dashboard"

Tab := root.AddTab3(, ["Settings", "Controls", "Help"])

Tab.UseTab("Help")
hotkey_list_btn := root.Add("Button", ,"Hotkey List")
hotkey_list_btn.OnEvent("Click", open_help)

changelog_btn := root.Add("Button", ,"Open Changelog")
changelog_btn.OnEvent("Click", open_changelog)

Tab.UseTab("Settings")
root.Add("Text", ,"Language")
language_dropdown := root.Add("DropDownList","vuser_language xp+0 yp+15",["English", "Korean"])
switch language{
    case "en":
        language_dropdown.Choose("English")
    case "ko":
        language_dropdown.Choose("Korean")
    default:
        language_dropdown.Choose("English")
} 
language_dropdown.OnEvent("Change", setLanguage)

root.Add("Text", ,"F12 Mode")
f12_dropdown := root.Add("DropDownList","vf12_options xp+0 yp+15",["Disabled","Active Instance", "All Instances"])
f12_dropdown.Choose(f12_mode)
f12_dropdown.OnEvent("Change", setF12Mode)

root.Add("Text","xp+0 yp+30","E Key Functionality")
e_key_functionality_dropdown := root.Add("DropDownList","ve_key_options xp+0 yp+15",["Line","Line and Border"])
e_key_functionality_dropdown.Choose(e_key_functionality)
e_key_functionality_dropdown.OnEvent("Change", setEKeyFunctionality)

w_checkbox := root.Add("CheckBox","h20 yp+30","W as Delete Key")
w_checkbox.value := w_as_delete
w_checkbox.OnEvent("Click", setWMode)

Tab.UseTab("Controls")
root.AddText(,"Macro Bar Control")
macro_edit := root.AddEdit("r1 Section vMacroBarEdit w225")
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
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(f12_dropdown.Text, prefs_file_path, "f12_mode", "value")
}

setLanguage(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    switch language_dropdown.Text{
        case "English":
            IniWrite("en", prefs_file_path, "language", "value")
        case "Korean":
            IniWrite("ko", prefs_file_path, "language", "value")
        default:
            IniWrite("en", prefs_file_path, "language", "value")
    }
    
}

setEKeyFunctionality(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(e_key_functionality_dropdown.Text, prefs_file_path, "e_key_functionality", "value")
}

setWMode(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
}

setMacroBarControlCallback(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

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
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

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
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

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
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

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
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

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