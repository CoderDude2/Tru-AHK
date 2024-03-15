#Requires Autohotkey v2.0

root := Gui()
right_click_gui := Gui()
right_click_gui.AddListBox("r2 vright_click_menu", ["New", "Delete"])
lb := root.AddListBox("r10 vtext_x",["0000","1111","2222"])
root.show()

Delete::{
    lb.Delete(lb.Value)
}

RButton::{
    right_click_gui.show()
}

; lb.OnEvent("Change", test)

; test(*){
;     MsgBox(lb.Text)
; }