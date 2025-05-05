#Requires Autohotkey v2.0
#SingleInstance Force
#Warn LocalSameAsGlobal, Off

#Include %A_ScriptDir%\Lib\util.ahk

root := Gui()
log_path := A_ScriptDir "\resources\log"

root.OnEvent("Close", onCloseText)
onCloseText(*){
    save()
    ExitApp
}

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New           Ctrl+N", onCreateItem)
MyMenu.Add("Copy          Ctrl+C", onCopy)
MyMenu.Add("Cut             Ctrl+X", onCut)
MyMenu.Add("Delete         Del", onDelete)

root.AddText(,"Text X")
text_x_lb := root.AddListBox("r10 vtext_x Sort Multi",[])
root.AddText(,"Process Last")
process_last_lb := root.AddListBox("r10 vprocess_last Sort Multi",[])

root.AddText("ys","Text X ASC")
text_x_asc_lb := root.AddListBox("r10 vtext_x_asc Sort Multi",[])
root.AddText(,"Process Last ASC")
process_last_asc_lb := root.AddListBox("r10 vprocess_last_asc Sort Multi",[])

TEXT_X := "ListBox1"
PROCESS_LAST := "ListBox2"

TEXT_X_ASC := "ListBox3"
PROCESS_LAST_ASC := "ListBox4"

load()
root.show()

showFadingMessage(msg) {
    fadingGui := Gui()
    fadingGui.Opt("+AlwaysOnTop -Caption +ToolWindow")
    fadingGui.BackColor := "000000"
    fadingGui.SetFont("s24")
    CoordText := fadingGui.Add("Text", "cLime", msg)
    WinSetTransColor(" 255", fadingGui)
    CoordText.Value := msg
    fadingGui.Show("x20 y20 NoActivate")
    Sleep(500)
    val := 255
    while val != 0{
        WinSetTransColor(" " val, fadingGui)
        val -= 5
        Sleep(20)
    }
    fadingGui.Destroy()
}

onCopy(*){
    copy_items()
}

onCut(*){
    cut_items()
}

onDelete(*){
    delete_items()
}

onCreateItem(*){
    case_id := InputBox("Enter Case ID", "Get Case ID", "w100 h100").value
    create_item(case_id, ControlGetClassNN(ControlGetFocus("ahk_id" root.Hwnd)))
}

create_item(value, control){
    listbox_hwnd := ControlGetHwnd(control, "ahk_id " root.Hwnd)
    Items := ControlGetItems(control, "ahk_id " root.Hwnd)
    for item in Items{
        if(item == value){
            return
        }
    }
    GuiCtrlFromHwnd(listbox_hwnd).Add([value])
    save()
}

delete_item(value, control) {
    listbox_hwnd := ControlGetHwnd(control, "ahk_id " root.Hwnd)
    Items := ControlGetItems(control, "ahk_id " root.Hwnd)
    index := unset
    for item in Items{
        if value == item{
            index := A_Index
            break
        }
    }
    ControlDeleteItem(index, listbox_hwnd)
}

delete_items(){
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("ahk_id " root.Hwnd)), "ahk_id " root.Hwnd)
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
    save()
}

save(){
    current_date := FormatTime("A_Now", "yyyyMMdd")
    if(FileExist(log_path)){
        FileDelete(log_path) ; Overwrite previous file.
    }

    FileAppend(current_date "`n", log_path)
    FileAppend("text-x`n", log_path)
    For Item in ControlGetItems(text_x_lb){
        FileAppend(Item "`n", log_path)
    }

    FileAppend("process-last`n", log_path)
    For Item in ControlGetItems(process_last_lb){
        FileAppend(Item "`n", log_path)
    }

    FileAppend("text-x-asc`n", log_path)
    For Item in ControlGetItems(text_x_asc_lb){
        FileAppend(Item "`n", log_path)
    }

    FileAppend("process-last-asc`n", log_path)
    For Item in ControlGetItems(process_last_asc_lb){
        FileAppend(Item "`n", log_path)
    }
}

load(){
    reset_file := False
    current_list := ""
    if(FileExist(log_path)){
        Loop read, log_path{
            if(A_Index == 1){
                current_time := FormatTime(, "yyyyMMdd")
                
                ; If the current date is greater than the saved date,
                ; then set the file to be reset.
                if(current_time > A_LoopReadLine){
                    reset_file := true
                    break
                }
            }

            switch A_LoopReadLine{
                case "text-x":
                    current_list := "text-x"
                case "process-last":
                    current_list := "process-last"
                case "text-x-asc":
                    current_list := "text-x-asc"
                case "process-last-asc":
                    current_list := "process-last-asc"
            }

            if isInteger(A_LoopReadLine){
                switch current_list{
                    case "text-x":
                        text_x_lb.Add([A_LoopReadLine])
                    case "process-last":
                        process_last_lb.Add([A_LoopReadLine])
                    case "text-x-asc":
                        text_x_asc_lb.Add([A_LoopReadLine])
                    case "process-last-asc":
                        process_last_asc_lb.Add([A_LoopReadLine])
                }
            }
        }
    }

    if(reset_file = True){
        current_date := FormatTime("A_Now", "yyyyMMdd")
        if(FileExist(log_path)){
            FileDelete(log_path) ; Overwrite previous file.
        }
        
        FileAppend(current_date "`n",log_path)
        return
    }
}

copy_items(){
    A_Clipboard := ""
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("ahk_id " root.Hwnd)), "ahk_id " root.Hwnd) ; Get the focused listbox HWND.
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd) ; Get the focused listbox.
    listbox_text := selected_listbox.Text
    if(listbox_text != ""){
        For Item in listbox_text{
            A_Clipboard .= Item . "`r`n"
        }
    }
}

cut_items(){
    copy_items()
    delete_items()
}

#HotIf WinActive("ahk_id " root.Hwnd, "Text X")
Delete::{
    delete_items()
}

Escape::{
    PostMessage 0x0185, 0, -1, TEXT_X
    PostMessage 0x0185, 0, -1, PROCESS_LAST
    PostMessage 0x0185, 0, -1, TEXT_X_ASC
    PostMessage 0x0185, 0, -1, PROCESS_LAST_ASC
}

^n::{
    onCreateItem()
}

^a::{
    listbox_hwnd := ControlGetHwnd(ControlGetClassNN(ControlGetFocus("ahk_id " root.Hwnd)), "ahk_id " root.Hwnd) ; Get the focused listbox HWND.
    selected_listbox := GuiCtrlFromHwnd(listbox_hwnd) ; Get the focused listbox.
    PostMessage 0x0185, 1, -1, selected_listbox ; Selects all items in listbox.
}

^c::{
    copy_items()
}

^x::{
    cut_items()
}

^s::{
    save()
}

~RButton::{
   CoordMode("Mouse", "Client")
   MouseGetPos(&pos_x, &pos_y, &id)
    if(WinGetTitle(id) == "text_x.exe"){
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
    save()
}

+z::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)
    if(case_id = ""){
        return
    }

    if(get_case_type(esprit_title) == "ASC"){
        create_item(case_id, PROCESS_LAST_ASC)
    } else {
        create_item(case_id, PROCESS_LAST)
    }
    save()
}