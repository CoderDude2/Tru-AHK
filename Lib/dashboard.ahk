#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"

class Property{
    __New(property_name, property_text, property_type, property_value, options?){
        this.property_name := property_name
        this.property_text := property_text

        this.property_type := property_type
        this.property_value := property_value

        if(IsSet(options)){
            this.options := options
        }
    }
}

arrayContains(value, array){
    Loop array.Length{
        if(array[A_Index] == value){
            return true
        }
    }

    return false
}

properties := Array()

AddProperty(property_name, property_text, property_type, property_value, options?){
    global properties
    new_property := Property(property_name, property_text, property_type, property_value, options)
    properties.Push(new_property)
}

AddProperty("f12_mode", "F12 Mode", "multi", "", ["One", "Two", "Three"])

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
            drop_down := root.Add("DropDownList", ,property.options)

            if(property.property_value != "" and arrayContains(property.property_value, property.options)){
                drop_down.Choose(property.property_value)
            }
        Default:
            root.Add("Text",,property.property_text)  
    }
}

tab_control := root.Add("Tab3", "w480 h480",["Home","Settings","Help"])

tab_control.UseTab("Settings")
GuiFromProperty(properties[1])

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