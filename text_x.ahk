#Requires Autohotkey v2.0

root := Gui()

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New", create_item)
MyMenu.Add("Delete", delete_item)

lb := root.AddListBox("r10 vtext_x",["0000","1111","2222"])

root.show()

Delete::{
    lb.Delete(lb.Value)
}

~RButton::{
   CoordMode("Mouse", "Client")
   MouseGetPos(&pos_x, &pos_y)
   MyMenu.show(pos_x, pos_y)
}

create_item(*){
    case_id := InputBox("Enter Case ID", "Get Case ID").value
    lb.Add(case_id)
}

delete_item(*){
    lb.Delete(lb.Value)
}