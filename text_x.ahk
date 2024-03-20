#Requires Autohotkey v2.0
#SingleInstance

#Include %A_ScriptDir%\Lib\commands.ahk

root := Gui()

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New", onCreateItem)
MyMenu.Add("Delete", delete_item)


lb := root.AddListBox("r10 vtext_x Sort Multi",[])
lb_2 := root.AddListBox("r10 vtext_x_asc Sort Multi",[])

root.show()

+x::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }
    create_item(case_id, "ListBox1")
}

l::{
    MsgBox(ControlGetClassNN(ControlGetFocus("text_x.ahk")))
}

#HotIf WinActive("text_x.ahk")
Delete::{
    delete_item()
}

~RButton::{
   CoordMode("Mouse", "Client")
   MouseGetPos(&pos_x, &pos_y, &id)
    if(WinGetTitle(id) == "text_x.ahk"){
        MyMenu.show(pos_x, pos_y)
    }
}

onCreateItem(*){
    case_id := InputBox("Enter Case ID", "Get Case ID", "w100 h100").value
    create_item(case_id, "ListBox1")
}

create_item(value, control){
    Items := ControlGetItems(control, "text_x.ahk")
    for item in Items{
        if(item == value){
            return
        }
    }
    lb.Add([value])
}

delete_item(*){
    index := lb.Value
    if(index != ""){
        index := index.Length
        Loop {
            if(index == 0){
                break
            }
            lb.Delete(lb.Value[index])
            index--
        }
    }
}