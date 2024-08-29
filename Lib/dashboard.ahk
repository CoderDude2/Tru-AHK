#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "updater.ahk"


open_dashboard(*){
    prefs_file_path := IniRead("config.ini", "info", "user_preferences")
    
    static dashboard_open := False
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

    if(!dashboard_open){
        dashboard_open := True
        root := Gui()
        root.Title := "Tru-AHK Dashboard"
        root.show("w300 h325")

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
        set_macro_control_btn.OnEvent("Click", setMacroBarControl)


        root.AddText("Section xs y+15","Project Manager Control")
        project_manager_edit := root.AddEdit("r1 Section vProjectManagerEdit w225")
        project_manager_edit.value := project_manager_control

        set_project_manager_control_btn := root.AddButton("ys xp+225 w50 h20","Set")
        set_project_manager_control_btn.OnEvent("Click", setProjectManagerControl)

        is_attached_checkbox := root.AddCheckbox("xs","Is Attached")
        is_attached_checkbox.value := is_attached
        is_attached_checkbox.OnEvent("Click", setProjectManagerControlIsAttached)

        setF12Mode(*){
            IniWrite(f12_dropdown.Text, prefs_file_path, "f12_mode", "value")
        }

        setWMode(*){
            IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
        }

        setMacroBarControl(*){
            IniWrite(macro_edit.Text, prefs_file_path, "macro_bar_control", "control")
        }

        setProjectManagerControl(*){
            IniWrite(project_manager_edit.Text, prefs_file_path, "project_manager_control", "control")
        }

        setProjectManagerControlIsAttached(*){
            IniWrite(is_attached_checkbox.value, prefs_file_path, "project_manager_control", "is_attached")
        }

        root.OnEvent("Close", OnClose)
        onClose(*){
            dashboard_open := False
        }

        Gui_Size(thisGui, MinMax, Width, Height){
            if MinMax = -1
                return
        }
    }
}