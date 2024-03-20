#Requires Autohotkey v2.0
#SingleInstance

#Include %A_ScriptDir%\Lib\commands.ahk

root := Gui()

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New", create_item)
MyMenu.Add("Delete", delete_item)

lb := root.AddListBox("r10 vtext_x Sort Multi",[])

root.show()

+x::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }

    ; Check if the id has already been added.
    if(lb.Text != ""){
        for Inbex, Field in lb.Text{
            MsgBox(Field)
        }
    }
    
    lb.Add([case_id])
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

create_item(*){
    case_id := InputBox("Enter Case ID", "Get Case ID", "w100 h100").value
    lb.Add([case_id])
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

