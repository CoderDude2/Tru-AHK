#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "updater.ahk"


open_dashboard(*){
    prefs_file_path := IniRead("config.ini", "info", "user_preferences")
    if(!FileExist(prefs_file_path)){
        IniWrite("All Instances", prefs_file_path, "f12_mode", "value")
        IniWrite(true, prefs_file_path, "w_as_delete", "value")
    }
    
    static dashboard_open := False
    f12_mode := IniRead(prefs_file_path, "f12_mode", "value")
    w_as_delete := IniRead(prefs_file_path, "w_as_delete", "value")
    remote_path := IniRead("config.ini", "info", "remote_path")

    if(!dashboard_open){
        dashboard_open := True
        root := Gui()
        root.Title := "Tru-AHK Dashboard"
        root.show("w200 h300")

        root.Add("GroupBox","r2.4 Section w175 h400","Help")
        hotkey_list_btn := root.Add("Button","xp+5 yp+15","Hotkey List")
        hotkey_list_btn.OnEvent("Click", open_help)

        changelog_btn := root.Add("Button","xp yp+25","Open Changelog")
        changelog_btn.OnEvent("Click", open_changelog)

        root.Add("Text","xm y+25","F12 Mode")
        f12_dropdown := root.Add("DropDownList","vf12_options",["Disabled","Active Instance", "All Instances"])
        f12_dropdown.Choose(f12_mode)
        f12_dropdown.OnEvent("Change", setF12Mode)

        w_checkbox := root.Add("CheckBox","h20 y+20","W as Delete Key")
        w_checkbox.value := w_as_delete
        w_checkbox.OnEvent("Click", setWMode)

        setF12Mode(*){
            IniWrite(f12_dropdown.Text, prefs_file_path, "f12_mode", "value")
        }

        setWMode(*){
            IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
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