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

        if(check_for_update(A_ScriptDir, remote_path)){
            root.Add("GroupBox","r2 xm ym Section w175 h400","Update")
            root.Add("Text","xs+5 ys+15","An Update is available")
            update_button := root.Add("Button",,"Update Now")
            update_button.OnEvent("Click", onUpdatePressed)
        }

        root.Add("Text",,"F12 Mode")
        f12_dropdown := root.Add("DropDownList","vf12_options",["Disabled","Active Instance", "All Instances"])
        f12_dropdown.Choose(f12_mode)
        f12_dropdown.OnEvent("Change", setF12Mode)

        w_checkbox := root.Add("CheckBox","h20","W as Delete Key")
        w_checkbox.value := w_as_delete
        w_checkbox.OnEvent("Click", setWMode)

        setF12Mode(*){
            IniWrite(f12_dropdown.Text, prefs_file_path, "f12_mode", "value")
        }

        setWMode(*){
            IniWrite(w_checkbox.value, prefs_file_path, "w_as_delete", "value")
        }

        onUpdatePressed(*){
            remote_path := IniRead("config.ini", "info", "remote_path")
            update(remote_path)
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