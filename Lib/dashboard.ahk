#Requires Autohotkey v2.0
#SingleInstance Force

#Include "constants.ahk"
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

if(!FileExist(PREFS_FILE_PATH)){
    create_default_prefs_file()
}

try {
    f12_mode := IniRead(PREFS_FILE_PATH, "f12_mode", "value")
} catch {
    IniWrite("All Instances", PREFS_FILE_PATH, "f12_mode", "value")
    f12_mode := "All Instances"
}

try {
    e_key_functionality := IniRead(PREFS_FILE_PATH, "e_key_functionality", "value")
} catch {
    IniWrite("Line and Border", PREFS_FILE_PATH, "e_key_functionality", "value")
    e_key_functionality := "Line and Border"
}

try {
    w_as_delete := IniRead(PREFS_FILE_PATH, "w_as_delete", "value")
} catch {
    IniWrite(true, PREFS_FILE_PATH, "w_as_delete", "value")
    w_as_delete := true
}

try {
    macro_bar_control := IniRead(PREFS_FILE_PATH, "macro_bar_control", "control")
} catch {
    IniWrite("", PREFS_FILE_PATH, "macro_bar_control", "control")
    macro_bar_control := ""
}

try {
    project_manager_control := IniRead(PREFS_FILE_PATH, "project_manager_control", "control")
} catch {
    IniWrite("", PREFS_FILE_PATH, "project_manager_control", "control")
    project_manager_control := ""
}

try {
    basic_setting_path := IniRead(PREFS_FILE_PATH, "locations", "basic_setting_path")
} catch {
    IniWrite("C:\Users\" A_UserName "\Desktop\Basic Setting", PREFS_FILE_PATH, "locations", "basic_setting_path")
    basic_setting_path := "C:\Users\" A_UserName "\Desktop\Basic Setting"
}

try {
    stl_path := IniRead(PREFS_FILE_PATH, "locations", "stl_path")
} catch {
    IniWrite("C:\Users\" A_UserName "\Desktop\작업\스캔파일", PREFS_FILE_PATH, "locations", "stl_path")
    stl_path := "C:\Users\" A_UserName "\Desktop\작업\스캔파일"
}

try {
    is_attached := IniRead(PREFS_FILE_PATH, "project_manager_control", "is_attached")
} catch {
    IniWrite(true, PREFS_FILE_PATH, "project_manager_control", "is_attached")
    is_attached := true
}

try {
    auto_recycle_STL := IniRead(PREFS_FILE_PATH, "auto_recycle_STL", "value")
} catch {
    IniWrite(true, PREFS_FILE_PATH, "auto_recycle_STL", "value")
    auto_recycle_STL := true
}


try {
    language := IniRead(PREFS_FILE_PATH, "language", "value")
} catch {
    switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "language", "value")
            language := "en"
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            language := "ko"
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            language := "ko"
	}
    
}

try {
    system_language := IniRead(PREFS_FILE_PATH, "system_language", "value")
} catch {
    switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "system_language", "value")
            language := "en"
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "system_language", "value")
            language := "ko"
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "system_language", "value")
            language := "ko"
	}
    
}

root := Gui("AlwaysOnTop")
root.Title := "Tru-AHK Dashboard"

Tab := root.AddTab3(, ["Settings", "Locations", "Controls", "Help"])

Tab.UseTab("Help")
hotkey_list_btn := root.Add("Button", "w100","Hotkey List")
hotkey_list_btn.OnEvent("Click", open_help)

changelog_btn := root.Add("Button", "w100","Open Changelog")
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

root.Add("Text","xs yp+30","System Language (Reloads script)")
system_language_dropdown := root.Add("DropDownList","vsystem_language yp+15",["English", "Korean"])
switch system_language{
    case "en":
        system_language_dropdown.Choose("English")
    case "ko":
        system_language_dropdown.Choose("Korean")
    default:
        system_language_dropdown.Choose("English")
} 
system_language_dropdown.OnEvent("Change", setSystemLanguage)

w_checkbox := root.Add("CheckBox","h20 ys","W as Delete Key")
w_checkbox.value := w_as_delete
w_checkbox.OnEvent("Click", setWMode)

auto_recycle_STL_checkbox := root.Add("CheckBox","h20","Auto-recycle STL Files")
auto_recycle_STL_checkbox.value := auto_recycle_STL
auto_recycle_STL_checkbox.OnEvent("Click", setAutoRecycleSTL)

root.Add("Text","","F12 Mode")
f12_dropdown := root.Add("DropDownList","vf12_options",["Disabled","Active Instance", "All Instances"])
f12_dropdown.Choose(f12_mode)
f12_dropdown.OnEvent("Change", setF12Mode)

root.Add("Text","","E Key Functionality")
e_key_functionality_dropdown := root.Add("DropDownList","ve_key_options",["Line","Line and Border"])
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
macro_edit := root.AddEdit("r1 Section vMacroBarEdit w250")
macro_edit.value := macro_bar_control
set_macro_control_btn := root.AddButton("ys xp+250 w50 h20","Set")
set_macro_control_btn.OnEvent("Click", setMacroBarControlCallback)

root.AddText("Section xs y+15","Project Manager Control")
project_manager_edit := root.AddEdit("r1 Section vProjectManagerEdit w250")
project_manager_edit.value := project_manager_control
set_project_manager_control_btn := root.AddButton("ys xp+250 w50 h20","Set")
set_project_manager_control_btn.OnEvent("Click", setProjectManagerControlCallback)

is_attached_checkbox := root.AddCheckbox("xs","Is Attached")
is_attached_checkbox.value := is_attached
is_attached_checkbox.OnEvent("Click", setProjectManagerControlIsAttached)

setF12Mode(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    IniWrite(f12_dropdown.Text, PREFS_FILE_PATH, "f12_mode", "value")
}

setLanguage(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    switch language_dropdown.Text{
        case "English":
            IniWrite("en", PREFS_FILE_PATH, "language", "value")
        case "Korean":
            IniWrite("ko", PREFS_FILE_PATH, "language", "value")
        default:
            IniWrite("en", PREFS_FILE_PATH, "language", "value")
    }
    Reload
}

setSystemLanguage(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    switch system_language_dropdown.Text{
        case "English":
            IniWrite("en", PREFS_FILE_PATH, "system_language", "value")
        case "Korean":
            IniWrite("ko", PREFS_FILE_PATH, "system_language", "value")
        default:
            IniWrite("en", PREFS_FILE_PATH, "system_language", "value")
    }
    Reload
}

setEKeyFunctionality(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    IniWrite(e_key_functionality_dropdown.Text, PREFS_FILE_PATH, "e_key_functionality", "value")
}

setAutoRecycleSTL(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    IniWrite(auto_recycle_STL_checkbox.Value, PREFS_FILE_PATH, "auto_recycle_STL", "value")
}

setWMode(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    IniWrite(w_checkbox.value, PREFS_FILE_PATH, "w_as_delete", "value")
}

setBasicSettingPathCallback(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    folder_path := FileSelect("D", "C:\Users\" A_UserName "\Desktop")
    if folder_path != ""{
        IniWrite(folder_path, PREFS_FILE_PATH, "locations", "basic_setting_path")
        basic_setting_path_edit.value := folder_path
    }
}

setSTLPathCallback(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    folder_path := FileSelect("D", "C:\Users\" A_UserName "\Desktop")
    if folder_path != ""{
        IniWrite(folder_path, PREFS_FILE_PATH, "locations", "stl_path")
        stl_path_edit.value := folder_path
    }
}

setMacroBarControlCallback(*){
    if not DirExist(PREFS_DIRECTORY){
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
    if not DirExist(PREFS_DIRECTORY){
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
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    global showInspector
    global setMacroBar
    global setProjectManager

    showInspector := False
    setProjectManager := False
    setMacroBar := False

    IniWrite(class_nn, PREFS_FILE_PATH, "macro_bar_control", "control")
    set_macro_control_btn.Opt("-Disabled")
    macro_edit.value := class_nn
}

setProjectManagerControl(class_nn){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    global showInspector
    global setMacroBar
    global setProjectManager

    showInspector := False
    setProjectManager := False
    setMacroBar := False

    IniWrite(class_nn, PREFS_FILE_PATH, "project_manager_control", "control")
    set_project_manager_control_btn.Opt("-Disabled")
    project_manager_edit.value := class_nn
}

setProjectManagerControlIsAttached(*){
    if not DirExist(PREFS_DIRECTORY){
        create_default_prefs_file()
    }

    IniWrite(is_attached_checkbox.value, PREFS_FILE_PATH, "project_manager_control", "is_attached")
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