#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "property_manager.ahk"

root := Gui()
root.Opt("+Resize")
root.Title := "Tru-AHK Dashboard"
root.show("w500 h500")

root.OnEvent("Size", Gui_Size)

tab_control := root.Add("Tab3", "w480 h480",["Home","Settings","Help"])

tab_control.UseTab("Settings")
GeneratePropertyGui(&root)

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