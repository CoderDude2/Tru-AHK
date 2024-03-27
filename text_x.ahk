#Requires Autohotkey v2.0
#SingleInstance

#Include %A_ScriptDir%\Lib\commands.ahk

root := Gui()

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New", onCreateItem)
MyMenu.Add("Copy", onCopy)
MyMenu.Add("Delete", delete_item)

root.AddText(,"Text X")
text_x_lb := root.AddListBox("r10 vtext_x Sort Multi",[])
root.AddText(,"Process Last")
process_last_lb := root.AddListBox("r10 vprocess_last Sort Multi",[])
root.AddText(,"Non-Library")
non_library_lb := root.AddListBox("r10 vnon_library Sort Multi",[])

root.AddText("ys","Text X ASC")
text_x_asc_lb := root.AddListBox("r10 vtext_x_asc Sort Multi",[])
root.AddText(,"Process Last ASC")
process_last_asc_lb := root.AddListBox("r10 vprocess_last_asc Sort Multi",[])
root.AddText(,"Non-Library ASC")
non_library_asc_lb := root.AddListBox("r10 vnon_library_asc Sort Multi",[])
root.AddText(,"KP ASC")
kp_asc_lb := root.AddListBox("r10 vkp_asc Sort Multi",[])

TEXT_X := "ListBox1"
PROCESS_LAST := "ListBox2"
NON_LIBRARY := "ListBox3"

TEXT_X_ASC := "ListBox4"
PROCESS_LAST_ASC := "ListBox5"
NON_LIBRARY_ASC := "ListBox6"
KP_ASC := "ListBox7"

root.show()

onCopy(*){
    A_Clipboard := ""
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("text_x.ahk")), "text_x.ahk") ; Get the focused listbox HWND.
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd) ; Get the focused listbox.
    listbox_text := selected_listbox.Text
    if(listbox_text != ""){
        For Item in listbox_text{
            A_Clipboard .= Item . "`r`n"
        }
    }
}

onCreateItem(*){
    case_id := InputBox("Enter Case ID", "Get Case ID", "w100 h100").value
    create_item(case_id, ControlGetClassNN(ControlGetFocus("text_x.ahk")))
}

create_item(value, control){
    listbox_hwnd := ControlGetHwnd(control, "text_x.ahk")
    Items := ControlGetItems(control, "text_x.ahk")
    for item in Items{
        if(item == value){
            return
        }
    }
    GuiCtrlFromHwnd(listbox_hwnd).Add([value])
}

delete_item(*){
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("text_x.ahk")), "text_x.ahk")
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd)
    index := selected_listbox.Value
    if(index != ""){
        index := index.Length
        Loop {
            if(index == 0){
                break
            }
            selected_listbox.Delete(selected_listbox.Value[index])
            index--
        }
    }
}

save(){
    current_date := FormatTime("A_Now", "yyyyMMdd")
    if(FileExist("log")){
        FileDelete("log") ; Overwrite previous file.
    }
    
    FileAppend(current_date "`n", "log")
    FileAppend("text-x`n", "log")
    For Item in ControlGetItems(text_x_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("process-last`n", "log")
    For Item in ControlGetItems(process_last_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("non-library`n", "log")
    For Item in ControlGetItems(non_library_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("text-x-asc`n", "log")
    For Item in ControlGetItems(text_x_asc_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("process-last-asc`n", "log")
    For Item in ControlGetItems(process_last_asc_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("non-library-asc`n", "log")
    For Item in ControlGetItems(non_library_asc_lb){
        FileAppend(Item "`n", "log")
    }

    FileAppend("kp-asc`n", "log")
    For Item in ControlGetItems(kp_asc_lb){
        FileAppend(Item "`n", "log")
    }
}

load(){

}

#HotIf WinActive("text_x.ahk", "Text X")
Delete::{
    delete_item()
}

Escape::{
    PostMessage 0x0185, 0, -1, TEXT_X
    PostMessage 0x0185, 0, -1, PROCESS_LAST
    PostMessage 0x0185, 0, -1, NON_LIBRARY
    PostMessage 0x0185, 0, -1, TEXT_X_ASC
    PostMessage 0x0185, 0, -1, PROCESS_LAST_ASC
    PostMessage 0x0185, 0, -1, NON_LIBRARY_ASC
    PostMessage 0x0185, 0, -1, KP_ASC
}

^a::{
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("text_x.ahk")), "text_x.ahk") ; Get the focused listbox HWND.
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd) ; Get the focused listbox.
    PostMessage 0x0185, 1, -1, selected_listbox ; Selects all items in listbox.
}

^c::{
    A_Clipboard := ""
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("text_x.ahk")), "text_x.ahk") ; Get the focused listbox HWND.
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd) ; Get the focused listbox.
    listbox_text := selected_listbox.Text
    if(listbox_text != ""){
        For Item in listbox_text{
            A_Clipboard .= Item . "`r`n"
        }
    }
}

^s::{
    save()
}

~RButton::{
   CoordMode("Mouse", "Client")
   MouseGetPos(&pos_x, &pos_y, &id)
    if(WinGetTitle(id) == "text_x.ahk"){
        MyMenu.show(pos_x, pos_y)
    }
}

#HotIf WinActive("ahk_exe esprit.exe")
+x::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }
    if(get_case_type(esprit_title) == "ASC"){
        create_item(case_id, TEXT_X_ASC)
    } else {
        create_item(case_id, TEXT_X)
    }
}

+z::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }
    if(InStr(get_connection_type(esprit_title), "KP")){
        create_item(case_id, KP_ASC)
    } else if(get_case_type(esprit_title) == "ASC"){
        create_item(case_id, PROCESS_LAST_ASC)
    } else {
        create_item(case_id, PROCESS_LAST)
    }
    
}

+d::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }
    if(get_case_type(esprit_title) == "ASC"){
        create_item(case_id, NON_LIBRARY_ASC)
    } else {
        create_item(case_id, NON_LIBRARY)
    }
}