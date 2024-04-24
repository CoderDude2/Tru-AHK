#Requires Autohotkey v2.0

properties := LoadProperties(A_ScriptDir "\prefs.ini")

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

    UpdateValue(value){
        this.property_value := value
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

AddProperty(property_name, property_text, property_type, property_value, options?){
    global properties
    new_property := Property(property_name, property_text, property_type, property_value, options?)
    properties.Push(new_property)
}

GetPropertyIndexByName(property_name){
    global properties
    Loop properties.Length{
        if(properties[A_Index].property_name == property_name){
            return A_Index
        }
    }
}

GuiFromProperty(&gui_object, property){
    switch property.property_type{
        case "boolean":
            c_box := gui_object.Add("CheckBox", "v" property.property_name " h20",property.property_text)
            c_box.Value := property.property_value
            c_box.OnEvent("Click", UpdateProperty)
        case "multi":
            gui_object.Add("Text",,property.property_text)
            drop_down := gui_object.Add("DropDownList", "v" property.property_name, property.options)

            if(property.property_value != "" and arrayContains(property.property_value, property.options)){
                drop_down.Choose(property.property_value)
            }

            drop_down.OnEvent("Change", UpdateProperty)
        Default:
            gui_object.Add("Text",,property.property_text)  
    }
}

UpdateProperty(params*){
    gui_object := params[1]
    if(gui_object.Type == "CheckBox"){
        property_index := GetPropertyIndexByName(gui_object.Name)
        properties[property_index].UpdateValue(gui_object.Value)
    } else if(gui_object.Type == "DDL"){
        property_index := GetPropertyIndexByName(gui_object.Name)
        properties[property_index].UpdateValue(gui_object.Text)
    }
}

GeneratePropertyGui(&gui_object){
    global properties
    Loop properties.Length{
        GuiFromProperty(&gui_object, properties[A_Index])
    }
}

SaveProperties(pref_path){
    global properties
    Loop properties.Length{
        section_name := properties[A_Index].property_name
        property_text := properties[A_Index].property_text
        property_type := properties[A_Index].property_type
        property_value := properties[A_Index].property_value
        property_options := properties[A_Index].options

        if(property_type == "multi"){
            options := ""

            Loop property_options.Length{
                if(A_Index < property_options.Length){
                    options .= property_options[A_Index] ","
                } else {
                    options .= property_options[A_Index]
                }
                
            }

            property_options := options
        }

        if(property_type == "boolean"){
            if(property_value == true){
                property_value := "true"
            } else if(property_value == false){
                property_value := "false"
            }
        }

        IniWrite(property_text, pref_path, section_name, "text")  
        IniWrite(property_type, pref_path, section_name, "type")   
        IniWrite(property_value, pref_path, section_name, "value")
        IniWrite(property_options, pref_path, section_name, "options")         
    }
}

LoadProperties(pref_path){
    sections := IniRead(pref_path)
    property_array := []
    Loop Parse sections, "`n"{
        property_name := A_LoopField
        property_text := IniRead(pref_path, A_LoopField, "text")
        property_type := IniRead(pref_path, A_LoopField, "type")
        property_value := IniRead(pref_path, A_LoopField, "value")
        property_options := IniRead(pref_path, A_LoopField, "options")

        if(property_type == "multi"){
            property_options := StrSplit(property_options, ",")
        }

        if(property_type == "boolean"){
            if(property_value == "true"){
                property_value := true
            } else if(property_value == "false"){
                property_value := false
            }
        }

        property_array.Push(Property(property_name, property_text, property_type, property_value, property_options))
    }

    return property_array
}