#Requires Autohotkey v2.0
#SingleInstance Force
#Warn LocalSameAsGlobal, Off

#Include %A_ScriptDir%\Lib\util.ahk

root := Gui("+Resize +MinSize296x375")
log_path := A_ScriptDir "\resources\log"

root.OnEvent("Close", onCloseText)
onCloseText(*){
    save()
    ExitApp
}

tab := root.AddTab3("w200",["Text X", "Process Last", "Non-Library"])

root.OnEvent("Size", onResize)

; Right Click Menu
MyMenu := Menu()
MyMenu.Add("New           Ctrl+N", onCreateItem)
MyMenu.Add("Copy          Ctrl+C", onCopy)
MyMenu.Add("Cut             Ctrl+X", onCut)
MyMenu.Add("Delete         Del", onDelete)

non_library_count := 0
non_library_asc_count := 0
non_library_aot_count := 0

tab.UseTab("Text X")
root.AddText("Section","Text X")
text_x_lb := root.AddListBox("r10 vtext_x Sort Multi",[])
root.AddText(,"Text X ASC")
text_x_asc_lb := root.AddListBox("r10 vtext_x_asc Sort Multi",[])

tab.UseTab("Process Last")
root.AddText("Section","Process Last")
process_last_lb := root.AddListBox("r10 vprocess_last Sort Multi",[])
root.AddText(,"Process Last ASC")
process_last_asc_lb := root.AddListBox("r10 vprocess_last_asc Sort Multi",[])

tab.UseTab("Non-Library")
non_library_text := root.AddText("Section","Non-Library: " non_library_count)
non_library_lb := root.AddListBox("r10 vnon_library Sort Multi",[])

non_library_asc_text := root.AddText("","Non-Library ASC: " non_library_asc_count)
non_library_asc_lb := root.AddListBox("r10 vnon_library_asc Sort Multi",[])

non_library_aot_text := root.AddText("ys","Non-Library AOT/TL: " non_library_aot_count)
non_library_aot_lb := root.AddListBox("r10 vnon_library_aot Sort Multi",[])


TEXT_X := "ListBox1"
TEXT_X_ASC := "ListBox2"

PROCESS_LAST := "ListBox3"
PROCESS_LAST_ASC := "ListBox4"

NON_LIBRARY := "ListBox5"
NON_LIBRARY_ASC := "ListBox6"
NON_LIBRARY_AOT := "ListBox7"

load()
root.show()


get_active_monitor(&left, &top, &right, &bottom){
    CoordMode "Mouse", "Screen"
    MouseGetPos(&posX, &posY)

    monitor_count := MonitorGetCount()
    Loop monitor_count{
        
        MonitorGet(A_Index, &monitor_left, &monitor_top, &monitor_right, &monitor_bottom)
        if posX >= monitor_left && posX <= monitor_right && posY >= monitor_top && posY <= monitor_bottom {
            left := monitor_left
            right := monitor_right
            top := monitor_top
            bottom := monitor_bottom
            return A_Index
        }
    }
    return 0
}

showFadingMessage(msg) {
    get_active_monitor(&left, &top, &right, &bottom)
    fadingGui := Gui()
    fadingGui.Opt("+AlwaysOnTop -Caption +ToolWindow")
    fadingGui.BackColor := "000000"
    fadingGui.SetFont("s24")
    CoordText := fadingGui.Add("Text", "cLime", msg)
    WinSetTransColor(" 255", fadingGui)
    CoordText.Value := msg
    fadingGui.Show("x" left+20 " " "y" top+20 " " "NoActivate")
    Sleep(100)
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

onResize(this_gui, minmax, width, height) {
    if minmax == -1{
        return
    }

    tab.Move(,,width-20, height-20)
}

listbox_contains(value, control){
    listbox_hwnd := ControlGetHwnd(control, "ahk_id " root.Hwnd)
    Items := ControlGetItems(control, "ahk_id " root.Hwnd)
    for item in Items{
        if(item == value){
            return True
        }
    }
    return False
}

create_item(value, control){
    global non_library_count
    global non_library_asc_count
    global non_library_aot_count
    listbox_hwnd := ControlGetHwnd(control, "ahk_id " root.Hwnd)
    Items := ControlGetItems(control, "ahk_id " root.Hwnd)
    for item in Items{
        if(item == value){
            return
        }
    }
    GuiCtrlFromHwnd(listbox_hwnd).Add([value])
    switch ControlGetClassNN(listbox_hwnd) {
        case NON_LIBRARY:
            non_library_count += 1
            non_library_text.Text := "Non-Library: " non_library_count
        case NON_LIBRARY_ASC:
            non_library_asc_count += 1
            non_library_asc_text.Text := "Non-Library ASC: " non_library_asc_count
        case NON_LIBRARY_AOT:
            non_library_aot_count += 1
            non_library_aot_text.Text := "Non-Library AOT/TL: " non_library_aot_count
    }
    save()
}

delete_item(value, control) {
    global non_library_count
    global non_library_asc_count
    global non_library_aot_count
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
    switch ControlGetClassNN(listbox_hwnd) {
        case NON_LIBRARY:
            non_library_count -= 1
            non_library_text.Text := "Non-Library: " non_library_count
        case NON_LIBRARY_ASC:
            non_library_asc_count -= 1
            non_library_asc_text.Text := "Non-Library ASC: " non_library_asc_count
        case NON_LIBRARY_AOT:
            non_library_aot_count -= 1
            non_library_aot_text.Text := "Non-Library AOT/TL: " non_library_aot_count
    }
}

delete_items(){
    global non_library_count
    global non_library_asc_count
    global non_library_aot_count
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
            switch ControlGetClassNN(selected_listbox) {
                case NON_LIBRARY:
                    non_library_count -= 1
                    non_library_text.Text := "Non-Library: " non_library_count
                case NON_LIBRARY_ASC:
                    non_library_asc_count -= 1
                    non_library_asc_text.Text := "Non-Library ASC: " non_library_asc_count
                case NON_LIBRARY_AOT:
                    non_library_aot_count -= 1
                    non_library_aot_text.Text := "Non-Library AOT/TL: " non_library_aot_count
            }
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

    FileAppend("non-library`n", log_path)
    For Item in ControlGetItems(non_library_lb){
        FileAppend(Item "`n", log_path)
    }

    FileAppend("non-library-asc`n", log_path)
    For Item in ControlGetItems(non_library_asc_lb){
        FileAppend(Item "`n", log_path)
    }

    FileAppend("non-library-aot`n", log_path)
    For Item in ControlGetItems(non_library_aot_lb){
        FileAppend(Item "`n", log_path)
    }
}

load(){
    global non_library_count
    global non_library_asc_count
    global non_library_aot_count
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
                case "non-library":
                    current_list := "non-library"
                case "non-library-asc":
                    current_list := "non-library-asc"
                case "non-library-aot":
                    current_list := "non-library-aot"
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
                    case "non-library":
                        non_library_lb.Add([A_LoopReadLine])
                        non_library_count += 1
                        non_library_text.Text := "Non-Library: " non_library_count
                    case "non-library-asc":
                        non_library_asc_lb.Add([A_LoopReadLine])
                        non_library_asc_count += 1
                        non_library_asc_text.Text := "Non-Library ASC: " non_library_asc_count
                    case "non-library-aot":
                        non_library_aot_lb.Add([A_LoopReadLine])
                        non_library_aot_count += 1
                        non_library_aot_text.Text := "Non-Library AOT/TL: " non_library_aot_count
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
BackSpace::
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
    if(id == root.Hwnd){
        MyMenu.show(pos_x, pos_y)
    }
}

#HotIf WinActive("ahk_exe esprit.exe")
DetectHiddenWindows(True)
+x::{
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)

    if(not case_id){
        return
    }

    case_type := get_case_type(esprit_title)

    if(not case_type) {
        return
    }

    if(case_type == "ASC"){
        if not listbox_contains(case_id, TEXT_X_ASC){
            create_item(case_id, TEXT_X_ASC)
            showFadingMessage(case_id " added to Text-X")
        } else {
            delete_item(case_id, TEXT_X_ASC)
            showFadingMessage(case_id " removed from Text-X")
        }
    } else {
        if not listbox_contains(case_id, TEXT_X){
            create_item(case_id, TEXT_X)
            showFadingMessage(case_id " added to Text-X")
        } else {
            delete_item(case_id, TEXT_X)
            showFadingMessage(case_id " removed from Text-X")
        }
    }
    save()
    
}

+z::{
    esprit_title := WinGetTitle("A")
    case_id := get_case_id(esprit_title)

    if(not case_id){
        return
    }

    case_type := get_case_type(esprit_title)

    if(not case_type) {
        return
    }

    if(case_type == "ASC"){
        if not listbox_contains(case_id, PROCESS_LAST_ASC){
            create_item(case_id, PROCESS_LAST_ASC)
            showFadingMessage(case_id " added to Process-Last")
        } else {
            delete_item(case_id, PROCESS_LAST_ASC)
            showFadingMessage(case_id " removed from Process-Last")
        }
    } else {
        if not listbox_contains(case_id, PROCESS_LAST){
            create_item(case_id, PROCESS_LAST)
            showFadingMessage(case_id " added to Process-Last")
        } else {
            delete_item(case_id, PROCESS_LAST)
            showFadingMessage(case_id " removed from Process-Last")
        }
    }
    save()
}

+n::{
    global non_library_count
    global non_library_asc_count
    global non_library_aot_count
    esprit_title := WinGetTitle("A")
    case_id:=get_case_id(esprit_title)

    if(not case_id){
        return
    }

    case_type := get_case_type(esprit_title)

    if(not case_type){
        return
    }

    if(case_type == "ASC"){
        if not listbox_contains(case_id, NON_LIBRARY_ASC){
            create_item(case_id, NON_LIBRARY_ASC)
            showFadingMessage(case_id " added to Non-Library")
        } else {
            delete_item(case_id, NON_LIBRARY_ASC)
            showFadingMessage(case_id " removed from Non-Library")
        }
    } else if (case_type == "AOT" or case_type == "TLOC"){
        if not listbox_contains(case_id, NON_LIBRARY_AOT){
            create_item(case_id, NON_LIBRARY_AOT)
            showFadingMessage(case_id " added to Non-Library")
        } else {
            delete_item(case_id, NON_LIBRARY_AOT)
            showFadingMessage(case_id " removed from Non-Library")
        }
    } else {
        if not listbox_contains(case_id, NON_LIBRARY){
            create_item(case_id, NON_LIBRARY)
            showFadingMessage(case_id " added to Non-Library")
        } else {
            delete_item(case_id, NON_LIBRARY)
            showFadingMessage(case_id " removed from Non-Library")
        }
    }
    save()
}