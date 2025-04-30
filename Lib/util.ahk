get_active_monitor(){
    CoordMode "Mouse", "Screen"
    MouseGetPos(&posX, &posY)

    monitor_count := MonitorGetCount()
    Loop monitor_count{
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if posX >= left && posX <= right && posY >= top && posY <= bottom {
            return A_Index
        }
    }
}

WinExistTitleWithPID(pid, title, text := unset) {
    ids := WinGetList(title, text?)
    for this_id in ids {
        if WinGetPID("ahk_id" this_id) == pid {
            return this_id
        }
    }
    return 0
}


WinActivateTitleWithPID(pid, title, text := unset){
    ids := WinGetList(title, text?)
    for this_id in ids {
        if WinGetPID("ahk_id " this_id) == pid {
            WinActivate("ahk_id " this_id)
            return this_id
        }
    }
    return 0
}


WinWaitTitleWithPID(pid, title, text := unset, timeout := unset) {  
    milliseconds := 0
    while True {
        if IsSet(timeout) {
            if milliseconds >= (timeout * 1000){
                return 0
            }
        }

        if WinExistTitleWithPID(pid, title, text?) {
            return WinGetID(title, text?)
        }
        milliseconds += 10
        Sleep(10)
    }
    return 0
}


WinActiveTitleWithPID(pid, title, text := unset){
    win := WinActive("A")
    if win {
        active_pid := WinGetPID(win)
        active_id := WinGetID(win)
        active_title := WinGetTitle(win)

        if active_pid == pid && active_title == title {
            return active_id
        }
    }

    return 0
}


WinWaitActiveTitleWithPID(pid, title, text := unset, timeout := unset){
    milliseconds := 0
    if IsSet(timeout) {
        timeout *= 1000
    }

    while true {
        if IsSet(timeout) {
            if milliseconds >= timeout {
                return 0
            }
        }
        
        try {
            win_id := WinGetID("A")
            win_pid := WinGetPID("ahk_id" win_id)
            win_title := WinGetTitle("ahk_id" win_id)

            if win_pid == pid && win_title == title {
                return win_id
            }
        }
        
        Sleep(10)
        milliseconds += 10
    }
    return 0
}


WinWaitCloseTitleWithPID(pid, title, text := unset)  {
    while WinExistTitleWithPID(pid, title, text?) {
        Sleep(1)
    }
}

consolelog(msg){
    msg := msg "`r`n"
    previous_clipboard := A_Clipboard
    A_Clipboard := msg
    ControlFocus("Edit1", "ESPRIT - ")
    Sleep(20)
    Send("^{End}")
    PostMessage(0x111, 57637, , "Edit1", "ESPRIT - ")
    Sleep(200)
    A_Clipboard := previous_clipboard
}

show_custom_dialog(msg, title){
    WINDOW_INFO_PATH := A_AppData "\tru-ahk\windows.ini"

    if not FileExist(WINDOW_INFO_PATH){
        FileAppend("", WINDOW_INFO_PATH)
    }

    ui_pos_x := IniRead(WINDOW_INFO_PATH, title "_" msg, "x", A_ScreenWidth/2 - 142)
    ui_pos_y := IniRead(WINDOW_INFO_PATH, title "_" msg, "y", A_ScreenHeight/2 - 51)
    
    response := ""
    custom_dialog_gui := Gui("+AlwaysOnTop")
    custom_dialog_gui.BackColor := "0xFFFFFF"
    custom_dialog_gui.Title := title
    custom_dialog_gui.AddText("x11 y23 w243 h15", msg)

    custom_dialog_gui.AddButton("x27 y68 w75 h23 +Default","Yes").OnEvent("Click", (*) => (
        response := "Yes"
        save_coordinates()
        custom_dialog_gui.Hide()
    ))

    custom_dialog_gui.AddButton("x110 y68 w75 h23","No").OnEvent("Click", (*) => (
        response := "No"
        save_coordinates()
        custom_dialog_gui.Hide()
    ))

    custom_dialog_gui.AddButton("x194 y68 w75 h23","Cancel").OnEvent("Click", (*) => (
        response := "Cancel"
        save_coordinates()
        custom_dialog_gui.Hide()
        
    ))

    custom_dialog_gui.OnEvent("Close", (*) => (
        save_coordinates()
        response := ""
    ))
    
    custom_dialog_gui.Show("w284 h101 x" ui_pos_x " y" ui_pos_y)
    WinWaitClose("ahk_id" custom_dialog_gui.Hwnd)
    return response

    save_coordinates(){
        custom_dialog_gui.GetPos(&posx, &posy)
        IniWrite(posx, WINDOW_INFO_PATH, title "_" msg, "x")
        IniWrite(posy, WINDOW_INFO_PATH, title "_" msg, "y")
    }
}