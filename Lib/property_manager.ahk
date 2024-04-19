#Requires Autohotkey v2.0

properties := Array()

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

AddProperty(property_name, property_text, property_type, property_value, options?){
    global properties
    new_property := Property(property_name, property_text, property_type, property_value, options?)
    properties.Push(new_property)
}

GuiFromProperty(&gui_object, property){
    switch property.property_type{
        case "boolean":
            c_box := gui_object.Add("CheckBox","h20",property.property_text)
            c_box.Value := property.property_value
        case "multi":
            root.Add("Text",,property.property_text)
            drop_down := gui_object.Add("DropDownList", ,property.options)

            if(property.property_value != "" and arrayContains(property.property_value, property.options)){
                drop_down.Choose(property.property_value)
            }
        Default:
            gui_object.Add("Text",,property.property_text)  
    }
}

GeneratePropertyGui(&gui_object){
    global properties
    Loop properties.Length{
        GuiFromProperty(&gui_object, properties[A_Index])
    }
}

SaveProperties(){
    ; Implement property saving
}

LoadProperties(){
    ; Implement property loading
}