class EspritInfo{
    Step3Tab := 1
    Step3Tab1Deg := 0
    Step3Tab2Deg := 0
    Step3Tab3Deg := 0
}

class F9QueueObject{
    esp_pid := 0
    esp_id := 0
    case_id := 0
}

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

show_custom_dialog(msg, title, owner := unset){
    WINDOW_INFO_PATH := A_AppData "\tru-ahk\windows.ini"

    if not FileExist(WINDOW_INFO_PATH){
        FileAppend("", WINDOW_INFO_PATH)
    }

    ui_pos_x := IniRead(WINDOW_INFO_PATH, title "_" msg, "x", A_ScreenWidth/2 - 142)
    ui_pos_y := IniRead(WINDOW_INFO_PATH, title "_" msg, "y", A_ScreenHeight/2 - 51)
    
    response := ""
    custom_dialog_gui := Gui()
	if IsSet(owner){
		custom_dialog_gui.Opt("+Owner" owner)
	}
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
    SetWinDelay 0
    Sleep 500
    try {
        WinActivate("ahk_id" custom_dialog_gui.Hwnd)
        WinActivate("ahk_id" custom_dialog_gui.Hwnd)
        WinActivate("ahk_id" custom_dialog_gui.Hwnd)
        WinActivate("ahk_id" custom_dialog_gui.Hwnd)
        WinActivate("ahk_id" custom_dialog_gui.Hwnd)
    }
    WinWaitClose("ahk_id" custom_dialog_gui.Hwnd)
    custom_dialog_gui.Destroy()

    SetWinDelay 100
    return response

    save_coordinates(){
        custom_dialog_gui.GetPos(&posx, &posy)
        IniWrite(posx, WINDOW_INFO_PATH, title "_" msg, "x")
        IniWrite(posy, WINDOW_INFO_PATH, title "_" msg, "y")
    }
}

save_completed_files(file_map){
    if FileExist(A_AppData "\tru-ahk\completed_files"){
        FileDelete(A_AppData "\tru-ahk\completed_files")
    }
    
    for k,v in file_map{
        FileAppend(k "==" v "`n", A_AppData "\tru-ahk\completed_files")
    }
}

loads_completed_files(){
    result := Map()
    if FileExist(A_AppData "\tru-ahk\completed_files"){
        contents := FileRead(A_AppData "\tru-ahk\completed_files")
        Loop Read A_AppData "\tru-ahk\completed_files"{
            if A_LoopReadLine != ""{
                line := StrSplit(A_LoopReadLine, "==")

                switch line[2]{
                    case "0":
                        result.Set(line[1], False)
                    case "1": 
                        result.Set(line[1], True)
                }
            }
        }
    }
    return result
}

class Mutex {
    /**
     * Creates a new Mutex, or opens an existing one. The mutex is destroyed once all handles to
     * it are closed.
     * @param name Optional. The name can start with "Local\" to be session-local, or "Global\" to be 
     * available system-wide.
     * @param initialOwner Optional. If this value is TRUE and the caller created the mutex, the 
     * calling thread obtains initial ownership of the mutex object.
     * @param securityAttributes Optional. A pointer to a SECURITY_ATTRIBUTES structure.
     */
    __New(name?, initialOwner := 0, securityAttributes := 0) {
        if !(this.ptr := DllCall("CreateMutex", "ptr", securityAttributes, "int", !!initialOwner, "ptr", IsSet(name) ? StrPtr(name) : 0))
            throw Error("Unable to create or open the mutex", -1)
    }
    /**
     * Tries to lock (or signal) the mutex within the timeout period.
     * @param timeout The timeout period in milliseconds (default is infinite wait)
     * @returns {Integer} 0 = successful, 0x80 = abandoned, 0x120 = timeout, 0xFFFFFFFF = failed
     */
    Lock(timeout:=0xFFFFFFFF) => DllCall("WaitForSingleObject", "ptr", this, "int", timeout, "int")
    ; Releases the mutex (resets it back to the unsignaled state)
    Release() => DllCall("ReleaseMutex", "ptr", this)
    __Delete() => DllCall("CloseHandle", "ptr", this)
}

ObjRegisterActive(obj, CLSID, Flags:=0) {
    static cookieJar := Map()
    if (!CLSID) {
        if (cookie := cookieJar.Remove(obj)) != ""
            DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
        return
    }
    if cookieJar.Has(obj)
        throw Error("Object is already registered", -1)
    _clsid := Buffer(16, 0)
    if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", _clsid)) < 0
        throw Error("Invalid CLSID", -1, CLSID)
    hr := DllCall("oleaut32\RegisterActiveObject", "ptr", ObjPtr(obj), "ptr", _clsid, "uint", Flags, "uint*", &cookie:=0, "uint")
    if hr < 0
        throw Error(format("Error 0x{:x}", hr), -1)
    cookieJar[obj] := cookie
}