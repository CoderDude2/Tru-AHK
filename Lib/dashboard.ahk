#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"

class property{
    __New(property_name, property_text, property_type, property_value){
        this.property_name := property_name
        this.property_text := property_text

        this.property_type := property_type
        this.property_value := property_value
    }
}



properties := Array()
properties.Push(property("f12-mode", "F12 Mode","multi", ["Disabled", "Active Window", "All Windows"]))
properties.Push(property("w-as-delete", "Use W as delete key?", "boolean", false))

root := Gui()
root.Opt("+Resize")
root.Title := "Tru-AHK Dashboard"
root.show("w500 h500")

root.OnEvent("Size", Gui_Size)

GuiFromProperty(property){
    switch property.property_type{
        case "boolean":
            c_box := root.Add("CheckBox","h20",property.property_text)
            c_box.Value := property.property_value
        case "multi":
            root.Add("Text",,property.property_text)
            root.Add("ComboBox", ,property.property_value)
        Default:
            root.Add("Text",,property.property_text)  
    }
}

tab_control := root.Add("Tab3", "w480 h480",["Home","Settings","Help"])

tab_control.UseTab("Settings")
GuiFromProperty(properties[1])
GuiFromProperty(properties[2])

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