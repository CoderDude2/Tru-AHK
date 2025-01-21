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
    basic_setting_path := IniRead(prefs_file_path, "locations", "basic_setting_path")
} catch {
    IniWrite("C:\Users\" A_UserName "\Desktop\Basic Setting", prefs_file_path, "locations", "basic_setting_path")
    basic_setting_path := "C:\Users\" A_UserName "\Desktop\Basic Setting"
}

try {
    stl_path := IniRead(prefs_file_path, "locations", "stl_path")
} catch {
    IniWrite("C:\Users\" A_UserName "\Desktop\작업\스캔파일", prefs_file_path, "locations", "stl_path")
    stl_path := "C:\Users\" A_UserName "\Desktop\작업\스캔파일"
}

try {
    is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")
} catch {
    IniWrite(true, prefs_file_path, "project_manager_control", "is_attached")
    is_attached := true
}

try {
    auto_recycle_STL := IniRead(prefs_file_path, "auto_recycle_STL", "value")
} catch {
    IniWrite(true, prefs_file_path, "auto_recycle_STL", "value")
    auto_recycle_STL := true
}


try {
    language := IniRead(prefs_file_path, "language", "value")
} catch {
    switch A_Language{
		case 0409:
			IniWrite("en", prefs_file_path, "language", "value")
            language := "en"
		case 0012:
			IniWrite("ko", prefs_file_path, "language", "value")
            language := "ko"
		case 0412:
			IniWrite("ko", prefs_file_path, "language", "value")
            language := "ko"
	}
    
}

root := Gui("AlwaysOnTop")
root.Title := "Tru-AHK Dashboard"

Tab := root.AddTab3(, ["Settings", "Locations", "Controls", "Help"])

Tab.UseTab("Help")
hotkey_list_btn := root.Add("Button", ,"Hotkey List")
hotkey_list_btn.OnEvent("Click", open_help)

changelog_btn := root.Add("Button", ,"Open Changelog")
changelog_btn.OnEvent("Click", open_changelog)

Tab.UseTab("Settings")
root.Add("Text","Section","Language (Reloads script)")
language_dropdown := root.Add("DropDownList","vuser_language yp+15",["English", "Korean"])
switch language{
    case "en":
        language_dropdown.Choose("English")
    case "ko":
        language_dropdown.Choose("Korean")
    default:
        language_dropdown.Choose("English")
} 
language_dropdown.OnEvent("Change", setLanguage)

w_checkbox := root.Add("CheckBox","h20 ys","W as Delete Key")
w_checkbox.value := w_as_delete
w_checkbox.OnEvent("Click", setWMode)

auto_recycle_STL_checkbox := root.Add("CheckBox","h20","Auto-recycle STL Files")
auto_recycle_STL_checkbox.value := auto_recycle_STL
auto_recycle_STL_checkbox.OnEvent("Click", setAutoRecycleSTL)

root.Add("Text","xs yp+15","F12 Mode")
f12_dropdown := root.Add("DropDownList","vf12_options xp+0 yp+15",["Disabled","Active Instance", "All Instances"])
f12_dropdown.Choose(f12_mode)
f12_dropdown.OnEvent("Change", setF12Mode)

root.Add("Text","yp+30 Section xs","E Key Functionality")
e_key_functionality_dropdown := root.Add("DropDownList","ve_key_options xp+0 yp+15",["Line","Line and Border"])
e_key_functionality_dropdown.Choose(e_key_functionality)
e_key_functionality_dropdown.OnEvent("Change", setEKeyFunctionality)

Tab.UseTab("Locations")
root.AddText("Section", "Basic Setting Path")
basic_setting_path_edit := root.AddEdit("r1 Section w275", "")
basic_setting_path_edit.value := basic_setting_path
set_basic_setting_path_btn := root.AddButton("ys xp+275 w20 h20","...")
set_basic_setting_path_btn.OnEvent("Click", setBasicSettingPathCallback)

root.AddText("xs", "STL Path")
stl_path_edit := root.AddEdit("r1 w275", "")
stl_path_edit.value := stl_path
set_stl_path_btn := root.AddButton("xp+275 w20 h20","...")
set_stl_path_btn.OnEvent("Click", setSTLPathCallback)

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
    Reload
}

setEKeyFunctionality(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(e_key_functionality_dropdown.Text, prefs_file_path, "e_key_functionality", "value")
}

setAutoRecycleSTL(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(auto_recycle_STL_checkbox.Value, prefs_file_path, "auto_recycle_STL", "value")
}

setWMode(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
}

setBasicSettingPathCallback(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    folder_path := FileSelect("D", "C:\Users\" A_UserName "\Desktop")
    if folder_path != ""{
        IniWrite(folder_path, prefs_file_path, "locations", "basic_setting_path")
        basic_setting_path_edit.value := folder_path
    }
}

setSTLPathCallback(*){
    if not DirExist(prefs_directory){
        create_default_prefs_file()
    }

    folder_path := FileSelect("D", "C:\Users\" A_UserName "\Desktop")
    if folder_path != ""{
        IniWrite(folder_path, prefs_file_path, "locations", "stl_path")
        stl_path_edit.value := folder_path
    }
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