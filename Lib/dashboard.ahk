#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"

root := Gui()
root.Opt("+Resize")
root.Title := "Tru-AHK Dashboard"
root.show("w500 h500")

root.OnEvent("Size", Gui_Size)

tab_control := root.Add("Tab3", "w480 h480",["Home","Settings","Help"])

tab_control.UseTab("Settings")
w_check_box := root.Add("CheckBox","h20","Use W key as Delete?")
if(IniRead("C:\Users\TruUser\AppData\Roaming\tru-ahk\prefs.ini", "preferences", "w_as_delete") == "true"){
    w_check_box.Value := true
}
w_check_box.OnEvent("Click", onCheckboxClick)

onCheckboxClick(*){
    if(w_check_box.Value){
        IniWrite("true", "C:\Users\TruUser\AppData\Roaming\tru-ahk\prefs.ini", "preferences", "w_as_delete")
    } else {
        IniWrite("false", "C:\Users\TruUser\AppData\Roaming\tru-ahk\prefs.ini", "preferences", "w_as_delete")
    }
}

tab_control.UseTab("Help")
help_button := root.Add("Button", "Default w120", "Open Help")
help_button.OnEvent("Click", open_help)

changelog_button := root.Add("Button", "Default w120", "Open Changelog")
changelog_button.OnEvent("Click", open_changelog)

Gui_Size(thisGui, MinMax, Width, Height){
    if MinMax = -1
        return
    
    tab_control.Move(,,Width-20, Height-20)
}