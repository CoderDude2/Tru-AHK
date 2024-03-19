#Requires Autohotkey v2.0
#SingleInstance

root := Gui()

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New", create_item)
MyMenu.Add("Delete", delete_item)

lb := root.AddListBox("r10 vtext_x Sort Multi",["0000","1111","2222"])

root.show()

Delete::{
    lb.Delete(lb.Value)
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
    index := lb.Value.Length
    Loop {
        if(index == 0){
            break
        }
        lb.Delete(lb.Value[index])
        index--
    }
}