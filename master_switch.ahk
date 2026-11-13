#Requires Autohotkey v2.0

#SingleInstance Force
A_HotkeyInterval := 9900000  ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 9900000
KeyHistory 0
ListLines False
ProcessSetPriority "A"
SetKeyDelay 0
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetControlDelay -1

SetWorkingDir A_ScriptDir

#Include %A_ScriptDir%\Lib\Const_Treeview.ahk
#Include %A_ScriptDir%\Lib\Const_Process.ahk
#Include %A_ScriptDir%\Lib\Const_Memory.ahk

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\nav.ahk
; #Include %A_ScriptDir%\Lib\util.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\restore.ahk

if(FileExist("old_master_switch.exe")){
    FileDelete("old_master_switch.exe")
}

if(IniRead("config.ini", "info", "show_changelog") == "True"){
    Run A_ScriptDir "\resources\changelog.pdf"
    IniWrite("False", "config.ini", "info", "show_changelog")
}

; ===== Variables =====
showDebug := false
isDrawing := false

lastMousePosX := unset
lastMousePosY := unset

step_5_tab := 1
step_5_margin := 1
step_5_crossball := 1

f9_queue := [] 

espritInstances := Map() 

STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

SuspendScriptMsg := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
TerminateMsg := DllCall("RegisterWindowMessageA", "Str", "Terminate")
ESPInitCompleteMsg := DllCall("RegisterWindowMessageA", "Str", "ESPInitCompleteMsg")
RefreshDocumentMsg := DllCall("RegisterWindowMessageW", "Str", "REFRESH_DOCUMENT")
ConfirmESPMsg := DllCall("RegisterWindowMessageW", "Str", "CONFIRM")
NewConfirmMsg := DllCall("RegisterWindowMessageW", "Str", "CONFIRM_MESSAGE")
EscapeKeyPressedMsg := DllCall("RegisterWindowMessageW", "Str", "ESCAPE_KEY_PRESSED")
LoadSTLMsg := DllCall("RegisterWindowMessageW", "Str", "LOAD_STL")
BeginProcessingMsg := DllCall("RegisterWindowMessageW", "Str", "BEGIN_PROCESSING")

SetSpaceAsConfirmMsg := DllCall("RegisterWindowMessageW", "Str", "SET_SPACE_CONFIRM")
UnsetSpaceAsConfirmMsg := DllCall("RegisterWindowMessageW", "Str", "UNSET_SPACE_CONFIRM")

RunStep4Msg := DllCall("RegisterWindowMessageW", "Str", "RunStep4Msg")

file_map := {data:loads_completed_files()}
ObjRegisterActive(file_map, "{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

spaceAsConfirmMap := Map()
prev_angle := Map()
base_index := Map()
step_5_map := Map()

OnMessage(SetSpaceAsConfirmMsg, OnSetSpaceAsConfirmMsg)
OnMessage(UnsetSpaceAsConfirmMsg, OnUnsetSpaceAsConfirmMsg)

OnSetSpaceAsConfirmMsg(wParam, lParam, msg, hwnd){
    esp_info := get_active_esprit_info()
    if esp_info.esp_id == wParam {
        consolelog(esp_info.esp_id " is set")
        spaceAsConfirmMap[esp_info.esp_id] := true
    }
}

OnUnsetSpaceAsConfirmMsg(wParam, lParam, msg, hwnd){
    esp_info := get_active_esprit_info()
    if esp_info.esp_id == wParam {
        consolelog(esp_info.esp_id " is unset")
        spaceAsConfirmMap[esp_info.esp_id] := false
    }
}

#SuspendExempt
;G1
f13::{
    Reload
}

SetTimer(debug, 20)

; update_file_map(){
    ; Loop Files, STL_FILE_PATH "\*", "F"{
        ; if not file_map.Has(A_LoopFileName){
            ; file_map[A_LoopFileName] := false
        ; } 
    ; }        
; }

update_file_map(){
    Loop Files, STL_FILE_PATH "\*", "F"{
        if not file_map.data.Has(A_LoopFileName){
            file_map.data[A_LoopFileName] := false
        }
    }

    for k,v in file_map.data{
        if not FileExist(STL_FILE_PATH "\" k){
            file_map.data.Delete(k)
        }
    }
}

SetTimer(update_file_map, 1000)

SetTimer(WindowWatcher, 150)

global watched := Map()
global nextID := 1

WatchForClose(title, callback){
    global watched, nextID
    id := nextID++
    watched[id] := {title: title, callback: callback}
}

WindowWatcher(){
    global watched
    for id, info in Watched.Clone(){
        if !WinExist(info.title){
            info.callback()
            watched.Delete(id)
        }
    }
}

SetTimer(process_f9_file_queue, 100)
process_f9_file_queue(){
    if f9_queue.Length > 0 {
        f9_object := f9_queue.Pop()
        Sleep(100)
        generate_nc("ahk_id" f9_object.esp_id)
        nc_id := WinWait("ESPRIT NC Editor", f9_object.case_id ".prg")
        WinClose("ahk_id" nc_id)
        send_WM_COPYDATA("SIMULATE_BACK", "ahk_id" f9_object.esp_id)
        WatchForClose("ahk_id" nc_id, (*) => save_file("ahk_id" f9_object.esp_id))
    }
}

get_active_esprit_info(){
    activeTitle := WinGetTitle("ESPRIT - ")
    ; if get_case_id(activeTitle) == ""{
    ;     return
    ; }

    if (not espritInstances.Has(activeTitle "_" WinGetPID(activeTitle))){
        esp_id := WinGetID(activeTitle)
        esp_pid := WinGetPID(activeTitle)
         
        esp_info := EspritInfo()
        esp_info.esp_pid := esp_pid
        esp_info.esp_id := esp_id
        esp_info.title := activeTitle

        espritInstances[activeTitle "_" WinGetPID(activeTitle)] := esp_info
    }

    return espritInstances[activeTitle "_" WinGetPID(activeTitle)] 
}
OnMessage(ESPInitCompleteMsg, OnESPInitCompleteMsg)

OnESPInitCompleteMsg(wParam, lParam, msg, hwnd){
    esp_info := get_active_esprit_info()
    
    if not esp_info.Step2Complete {
        esp_info.Step2Complete := true
    }

    go_to_next_esprit(esp_info.esp_id)
}

GetMacroButtonCodeMsg := DllCall("RegisterWindowMessageW", "Str", "GET_MACRO_BUTTON_COMMAND")
EspExecuteCommandMsg := DllCall("RegisterWindowMessageW", "Str", "ESP_EXECUTE_COMMAND")
MacroButtonCodeResponseMsg := DllCall("RegisterWindowMessageW", "Str", "MACRO_BUTTON_COMMAND_RESPONSE")

ExecuteMacroButtonCommand(command, esp_id){
    ; esp_info := get_active_esprit_info()
    PostMessage(EspExecuteCommandMsg, esp_id, command, , 0xFFFF)
}

; OnMessage(MacroButtonCodeResponseMsg, OnMacroButtonCodeResponseMsg)

; OnMacroButtonCodeResponseMsg(wParam, lParam, msg, hwnd){
;     ; esp_info := get_active_esprit_info()
;     PostMessage 0x111, lParam, , , "ahk_id" wParam
; }

ExtrudeMsg := DllCall("RegisterWindowMessageW", "Str", "EXTRUDE")
DrawLineMsg := DllCall("RegisterWindowMessageW", "Str", "DRAW_LINE")

OnMessage(ExtrudeMsg, OnExtrudeMsg)

OnExtrudeMsg(wParam, lParam, msg, hwnd){
    ; MsgBox("extrude")
    esp_info := get_active_esprit_info()
    if wParam == esp_info.esp_id {
        double_sided_border("ahk_id" esp_info.esp_id, true)
    }
}

on_exit_callback(*){
    activeTitle := WinGetTitle("ESPRIT - ")
    if get_case_id(activeTitle) == ""{
        return
    }

    if (espritInstances.Has(activeTitle "_" WinGetPID(activeTitle))){
        espritInstances.Delete(activeTitle "_" WinGetPID(activeTitle))
    }

    save_completed_files(file_map.data)
    PostMessage(TerminateMsg, , , ,0xFFFF)
}
OnExit(on_exit_callback)


debug(){
    if(showDebug){
        try{
            MouseGetPos(&posX, &posY, &window, &active_control)
            ToolTip("(" posX "," posY ")`n" WinGetTitle(window) "`n" active_control, posX, posY+20)
        }
    } else {
        ToolTip()
    }
}

^f3::{
    global showDebug
    showDebug := !showDebug
}

;Ctrl+G1
^f13::{
    PostMessage(SuspendScriptMsg, , , ,0xFFFF)
    Suspend
}

new_file_ready := Map() 

; G5 Key
#MaxThreadsPerHotkey 10 
f17::{
    Run("C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe", , , &esprit_pid)
    if (WinGetList("ahk_exe esprit.exe").Length > 1){
        warning_id := WinWaitTitleWithPID(esprit_pid, "ahk_class #32770", "WARNING: ESPRIT")
        WinMove(-600, 275, , , "ahk_id" warning_id, "WARNING: ESPRIT")
        ControlClick("Button2", "ahk_id" warning_id)
    }
}

#SuspendExempt False

#HotIf WinActive("ahk_exe DaouMessenger 4.0.exe")

:c1o:>>SC::Single case
:c1o:>>SP::Same patient
:c1o:>>CC::Canceled
:c1o:>>DO::Design okay
:c1o:>>WC::Wrong connection
:c1o:>>LP::List pasted
:c1o:>>NR::Needs recentering
:c1o:>>CSDU::CS is done uploading
:c1o:>>HELP::Does anyone need help?

#HotIf WinActive("ahk_exe esprit.exe")

#MaxThreadsPerHotkey 1

mtx := Mutex("Local\FileMutex")

f16::{
    global step_5_tab
    step_5_tab := 1

    esp_info := get_active_esprit_info()

    global new_file_ready
    if not new_file_ready.Has(esp_info.esp_id){
        new_file_ready[esp_info.esp_id] := false
    }

    selected_file := get_next_file()

    If selected_file == ""{
        RunWait('py -3 "C:\Users\TruUser\Desktop\Scripts\file_manager.py"')
        Sleep(500)
        selected_file := get_next_file()
    }

    if not (get_case_type(selected_file) == "AOT" or get_case_type(selected_file) == "TLOC"){
        go_to_next_esprit(esp_info.esp_id)
        PostMessage(LoadSTLMsg, esp_info.esp_id, , , 0xFFFF)
        new_file_ready[esp_info.esp_id] := false
        return
    }

    mark_file_as_completed(selected_file)

    Run("esp.ahk " esp_info.esp_pid " manual " '"' selected_file '"')
    new_file_ready[esp_info.esp_id] := false
}

+f16::{
    global new_file_ready
    selected_file := FileSelect(, STL_FILE_PATH)
    id := WinGetID("ESPRIT - ")
    if not new_file_ready.Has(id){
        new_file_ready[id] := false
    }

    If not(get_case_type(selected_file) == "AOT" or get_case_type(selected_file) == "TLOC"){
        send_WM_COPYDATA_dev("LOAD_STL_MANUAL:" selected_file, "ESPRIT - ")
        new_file_ready[id] := false
        return
    }

    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " manual " '"' selected_file '"')
    mark_file_as_completed(selected_file)
    new_file_ready[id] := false
}

^f16::{
    ; DetectHiddenWindows True
    global new_file_ready
    for id in WinGetList("ESPRIT - "){
        if not new_file_ready.Has(id){
            if WinGetTitle("ahk_id" id) == "ESPRIT - [ESPRIT1]"{
                new_file_ready[id] := true
            } else {
                new_file_ready[id] := false
            }
        }

        if not new_file_ready[id]{
            continue
        }

        Sleep(250)
        selected_file := get_next_file()
        If selected_file == "" {
            pid := WinGetPID("ahk_id " id)
            
            ; Force kill the process using the command prompt (hidden window)
            RunWait(A_ComSpec " /c taskkill /F /PID " pid,, "Hide")
            continue
        }

        if not (get_case_type(selected_file) == "AOT" or get_case_type(selected_file) == "TLOC"){
            PostMessage(LoadSTLMsg, id, , , 0xFFFF)
            new_file_ready[id] := false
            continue 
        }

        mark_file_as_completed(selected_file)

        Run("esp.ahk " id " manual " '"' selected_file '"')
        new_file_ready[id] := false
    }
    ; DetectHiddenWindows false 
    ; for id in WinGetList("ESPRIT - "){
    ;     selected_file := get_next_file()

    ;     If selected_file == "" {
    ;         RunWait('py -3 "C:\Users\TruUser\Desktop\Scripts\file_manager.py"')
    ;         Sleep(500)
    ;         selected_file := get_next_file()
    ;     }

    ;     if not (get_case_type(selected_file) == "AOT" or get_case_type(selected_file) == "TLOC"){
    ;         PostMessage(LoadSTLMsg, id, , , 0xFFFF)
    ;         continue 
    ;     }

    ;     mark_file_as_completed(selected_file)

    ;     Run("esp.ahk " id " manual " '"' selected_file '"')
    ; }
}

~^o::{
    selected_file := ""
    For k,v in file_map.data {
        if v = False and FileExist(STL_FILE_PATH "\" k){
            selected_file := k
            break
        }
    }
    found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
    if found_pos {
        SplitPath(selected_file, &name)
        if mtx.Lock() == 0 {
            file_map.data[name] := true
            mtx.Release()
        }
    }
    win_id := WinWaitActive("Select a file to load")
    ControlSetText(name, "Edit1", "ahk_id" win_id)
    ControlSend("{Enter}", "Button1", "ahk_id" win_id)
    WatchForClose("ahk_id" win_id, (*) => go_to_next_esprit(get_active_esprit_info().esp_id))
}

h::{
    ; MsgBox(WinGetID("ESPRIT - "))
    ; MsgBox(send_WM_COPYDATA("Hello World!!!", "ESPRIT - "))
    
    send_WM_COPYDATA_dev("TLOC_AOT", "ESPRIT - ")
}

o::{
    open_file()
    win_id := WinWaitActive("Open")
    ControlSendText("C:\Users\TruUser\Documents\cylinder1.step", "Edit1", "ahk_id" win_id)
    ControlSend("{Enter}", "Button2", "ahk_id" win_id)
}

l::{
    ; bottom_z_limit := -5
    ; send_WM_COPYDATA("CREATE_CROSSBALLS", "ESPRIT - ")
    ; send_WM_COPYDATA("CREATE_MARGINS", "ESPRIT - ")
    ; send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 1 " " bottom_z_limit, "ESPRIT - ")
    ; send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 2 " " bottom_z_limit, "ESPRIT - ")
    ; send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 3 " " bottom_z_limit, "ESPRIT - ")
    ; send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 4 " " bottom_z_limit, "ESPRIT - ")
    send_WM_COPYDATA_dev("CREATE_CUT_OUTLINE", "ESPRIT - ")
}

k::{
    ; send_WM_COPYDATA_dev("TEST_STEP", "ESPRIT - ")
    send_WM_COPYDATA_dev("ROUGHS", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("SPLIT_WINDOWS", "ESPRIT - ")
    ; command_prompt := WinExistTitleWithPID(get_active_esprit_info().esp_pid, "Reference Element")
}

+k::{
    send_WM_COPYDATA_dev("CREATE_CROSSBALL_LAYERS_DEV3", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("TEST_STEP", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("CREATE_CUT_OUTLINE", "ESPRIT - ")
    ; cut_with_border(true)
}

^+k::{
    send_WM_COPYDATA_dev("CREATE_CROSSBALL_LAYERS_DEV4", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("TEST_STEP", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("CREATE_CUT_OUTLINE", "ESPRIT - ")
    ; cut_with_border(true)
}

!k::{
    esp_info := get_active_esprit_info()
    PostMessage(BeginProcessingMsg, esp_info.esp_id, , , 0xFFFF)
}

; I want to save the open file when building the NC code.
f15::
f8::{
    esp_info := get_active_esprit_info()
    ; CoordMode("Mouse", "Screen")
    ; Click(231, 968)
    ; Sleep(20)
    ; Click(100, 946)
    ; Sleep(40)
    ; deg0("ahk_id" esp_info.esp_id)
    ; toggle_simulation("ahk_id" esp_info.esp_id)
    ; go_to_next_esprit(esp_info.esp_id)
    send_WM_COPYDATA("SIMULATE_BACK", "ahk_id" esp_info.esp_id)
}

^f15::{
    global new_file_ready
    esp_info := get_active_esprit_info()
    stop_simulation("ahk_id" esp_info.esp_id)
    ExecuteMacroButtonCommand(6, esp_info.esp_id)
    Sleep(200)
    send_WM_COPYDATA("DISABLE_LAYER:TEXT", esp_info.title)
    send_WM_COPYDATA("ENABLE_LAYER:BACK TURNING", esp_info.title)
    send_WM_COPYDATA("ENABLE_LAYER:CUT-OFF", esp_info.title)
    deg0("ahk_id" esp_info.esp_id)
    new_file_ready[esp_info.esp_id] := true
}

; G3 Key
+f15::
f9::{
    esp_info := get_active_esprit_info()

    case_id := get_case_id(WinGetTitle("ahk_id" esp_info.esp_id))
    ; Send("{Ctrl down}{Shift down}s{Shift up}{Ctrl up}")

    newF9QueueObject := F9QueueObject()
    newF9QueueObject.esp_pid := esp_info.esp_pid
    newF9QueueObject.esp_id := esp_info.esp_id
    newF9QueueObject.case_id := case_id
    
    new_file_ready[esp_info.esp_id] := false
    go_to_next_esprit(esp_info.esp_id)
    f9_queue.InsertAt(1, newF9QueueObject)
}

^+r::{
    esprit_title := WinGetTitle("A")
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)

    tag := restore_gui()
    if tag != ""{
        restore_checkpoint(tag, SubPat[0])
        load_esp_file(SubPat[0])
    }
}

f18::{
    esprit_title := WinGetTitle("ESPRIT - ")
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
    
    if FoundPos{
        inp := InputBox("Enter a tag for the checkpoint", "New Checkpoint")
        if inp.Value != "" {
            create_checkpoint(inp.Value, SubPat[0])
        }
    }
}

f12::{
    pid := WinGetPID("A")
    ProcessClose(pid)
}


; ===== Remappings =====
LWin::Delete

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := (get_current_angle("ESPRIT - ") - 7) * 10
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := (get_current_angle("ESPRIT - ") - 7) * 10
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := (get_current_angle("ESPRIT - ") - 7) * 10
   Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:2-1::{
    esprit_title := WinGetTitle("ESPRIT")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "2-1. FRONT TURNING-SHORT"
    } else {
        Send "2-1. FRONT TURNING"
    }
}

:*:5-1::{
    esprit_title := WinGetTitle("ESPRIT")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "5-1. FRONT TURNING"
    }
}

; ===== View Controls=====

^!a::{
    deg0()
}
a::{
    send_WM_COPYDATA("SELECT_VIEW:1", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

s::{
    send_WM_COPYDATA("SELECT_VIEW:2", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

d::{
    send_WM_COPYDATA("SELECT_VIEW:3", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

f::{
    send_WM_COPYDATA("SELECT_VIEW:4", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

c::{
    try{
        face()
    }
}

v::{
    try{
        rear()
    }
}

^+c::{
    send_WM_COPYDATA_dev("CREATE_CROSS_SECTION", "ESPRIT - ")
}

!WheelDown::{
    try {
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        if WinExist("Extrude Boss/Cut"){
            _id := WinGetID("Extrude Boss/Cut")
            current_extrude_length := ControlGetText("Edit1", "ahk_id" _id)
            if current_extrude_length - 1 != 0 {
                extrude_by(current_extrude_length - 1)
            }
        } else {
            increment_10_degrees()
            ; send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
        }
    }
}

+!WheelDown::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        increment_90_degrees()
        send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
    }
}

!WheelUp::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        if WinExist("Extrude Boss/Cut"){
            _id := WinGetID("Extrude Boss/Cut")
            current_extrude_length := ControlGetText("Edit1", "ahk_id" _id)
            extrude_by(current_extrude_length + 1)
        } else {
            decrement_10_degrees()
            ; send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
        }
    }
}

+!WheelUp::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        decrement_90_degrees()  
        send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
    }
}

; ===== Controls =====
Space::{
    esp_info := get_active_esprit_info()
    if spaceAsConfirmMap.Has(esp_info.esp_id) and spaceAsConfirmMap[esp_info.esp_id] == true {
        send_WM_COPYDATA("CONFIRM", "ahk_id" esp_info.esp_id)
    } else if path_tool {
        Click()
    } else {
        Send("{Enter}")
    }

    PostMessage(NewConfirmMsg, esp_info.esp_id, , , 0xFFFF)
}

f14::{
    solid_view()
}

; Tilde(~) key
`::{
    wireframe_view()
}

t::{
    transformation_window()
}

^t::{
    translate_selection_click()
}

^r::{
    rotate_selection(90)
}

+!r::{
    rotate_selection(-1)
}

+c::{
    circle_tool()
}

+a::{
    unsuppress_operation()
}

+s::{
    suppress_operation()
}

+r::{
    rebuild_operation()
}

!x::
XButton1::{
    trim_tool()
}

+XButton2::{
    PostMessage 0x111, 3141 , , , get_active_esprit_info().title 
}

+XButton1::{
    ; PostMessage 0x111, 3014 , , , get_active_esprit_info().title 
    send_WM_COPYDATA_dev("PLACE_POINTS", "ESPRIT - ")
}

^!LButton::{
    send_WM_COPYDATA("91011", "ahk_id" get_active_esprit_info().esp_id)
}

!LButton::{
    highlight_tool()
    Sleep(100)
    Send("{LButton}{RButton}{LButton}")
    Sleep(100)
    highlight_tool()
}

+LButton::{
    ControlChooseString("Geometry", "ComboBox4", "ESPRIT - ")
    Sleep(50)
    Send("{Shift down}{LButton}{Shift Up}")
    Sleep(50)
    ControlChooseString("All", "ComboBox4", "ESPRIT - ")
}

^d::{
    highlight_tool()
}

^e::{
    extrude_tool()
}

+Space::{
    toggle_simulation()
}

g::{ 
    if not WinActive("Extrude Boss/Cut"){
        double_sided_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

b::{
    if not WinExist("Extrude Boss/Cut"){
        cut_with_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

^b::{
    PostMessage(0x111, 3130, , , "ESPRIT")
	_id := WinWait("Extrude Boss/Cut",,0.1)
	try{
		ControlChooseIndex(2,"ComboBox1","ahk_id" _id)
		ControlSetText(11, "Edit1", "ahk_id" _id)
		ControlSetText(18, "Edit4", "ahk_id" _id)
		ControlChooseIndex(2,"ComboBox2","ahk_id" _id)
		ControlChooseIndex(2,"ComboBox3","ahk_id" _id)
		ControlSetChecked(0,"Button8","ahk_id" _id)
		ControlSetChecked(1,"Button3","ahk_id" _id)
        solid_view()
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

r & Numpad1::{
    distance_val := 1
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad2::{
    distance_val := 2
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r::
r & Numpad3::{
    distance_val := 3
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad4::{
    distance_val := 4
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad5::{
    distance_val := 5
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad6::{
    distance_val := 6
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad7::{
    distance_val := 7
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad8::{
    distance_val := 8
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}
r & Numpad9::{
    distance_val := 9
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

e::{
    WinActivate("ESPRIT - ")
    esp_info := get_active_esprit_info()
    Click(Count := 1)
    Sleep(20)
    PostMessage(DrawLineMsg, esp_info.esp_id, 20, , 0xFFFF)
    ; draw_straight_border()
}

; ===== Auto-Complete Margins =====
~Escape::{
    esp_info := get_active_esprit_info()
    PostMessage(EscapeKeyPressedMsg, esp_info.esp_id, , , 0xFFFF)
    global passes
    global isDrawing
    global lastMousePosX
    global lastMousePosY

    isDrawing := false
    ControlChooseString("All", "ComboBox4", "ESPRIT - ")

    passes := 5

    if not WinActive("ahk_class #32770","No Intersections P->L"){
        draw_path("cancel")
    }

    stop_simulation()
	PostMessage 0x111, 3055 , , , esp_info.title 
}

!XButton2::
!CapsLock::{
    global isDrawing
    global prev_angle
    isDrawing := true

    esp_info := get_active_esprit_info()
    prev_angle[esp_info.esp_id] := get_current_angle("ahk_id" esp_info.esp_id)

    line_tool(, true)
    send_WM_COPYDATA_dev("START_SEGMENT", "ESPRIT - ")
}

CapsLock::{
    global isDrawing
    isDrawing := true
    line_tool()
    send_WM_COPYDATA_dev("START_SEGMENT", "ESPRIT - ")
}

path_tool := false
+CapsLock::
XButton2::{
    global path_tool
    path_tool := true
    PostMessage 0x111, 3057, , , "ESPRIT"
}

RButton::{
    global path_tool
    global isDrawing
    if path_tool {
        send_WM_COPYDATA_dev("COMPLETE_PATH", "ESPRIT - ")
        PostMessage 0x111, 3055 , , , "ESPRIT - " 
        path_tool := false
    } else if isDrawing{
        send_WM_COPYDATA_dev("COMPLETE_SEGMENT", "ESPRIT - ")
        PostMessage 0x111, 3055 , , , "ESPRIT - " 
        isDrawing := false
    } else {
        Send("{RButton}")
    }
}

; ===== Auto-Fill TLOC cases =====
+t::{
    WinWaitActive("ahk_exe esprit.exe")
    esprit_title := WinGetTitle("A")

    if(get_case_type(esprit_title) = "TLOC"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)

    } else if(get_case_type(esprit_title) = "AOT"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        translate_selection(20, 0, 0)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)
    }
}

; ===== More Keys =====
y::{
    global step_5_crossball
    ; CoordMode("Mouse", "Screen")
    ; MouseMove(46, 38, 0) ; Press Tab 1
    ; Click(170, 325) ; Click the Entry Box
    ; Send("^a-5")
    ; Click(175, 275) ; Click Regenerate
    bottomZLimit := -5
    send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" step_5_crossball " " bottomZLimit, "ESPRIT - ")
}

AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    
    Click("70 170") ; 1st Margin
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(50)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)
    
    Click("180 170") ; 2nd Margin
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(50)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)
    
    
    Click("70 215") ; 3rd Margin
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(50)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)

    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    enable_layer("28 '경계소재-5'")
    Sleep(20)
    enable_layer("29 '경계소재-5'")
    Sleep(20)
    enable_layer("30 '경계소재-5'")
    Sleep(20)
    enable_layer("31 '경계소재-5'")
    Sleep(20)
    enable_layer("14 '경계소재-4'")
    Sleep(20)
    enable_layer("15 '경계소재-5'")
    Sleep(20)
    unsuppress_operation()
}

+AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(100)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)

    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(100)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)

    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(100)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)

    
    Click("180 215") ; 4th Margin
    Click("180, 290") ; Click the Text box and enter 0.025
    try{
        WinClose("Command", "PIN")
        WinWaitClose("Command", "PIN")
    }
    Send("^a")
    Sleep(100)
    Send("0.025")
    Sleep(50)
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(100)

    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    enable_layer("28 '경계소재-5'")
    Sleep(20)
    enable_layer("29 '경계소재-5'")
    Sleep(20)
    enable_layer("30 '경계소재-5'")
    Sleep(20)
    enable_layer("31 '경계소재-5'")
    Sleep(20)
    enable_layer("14 '경계소재-4'")
    Sleep(20)
    enable_layer("15 '경계소재-5'")
    Sleep(20)
    unsuppress_operation()
}

q::{
    swap_path()
    generate_path()
}

w::{
    swap_path()
}

!Numpad7::{
    global step_5_margin
    global step_5_crossball
    global step_5_map
    esp_info := get_active_esprit_info()
    if not step_5_map.Has(esp_info.title esp_info.esp_id){
        step_5_map[esp_info.title esp_info.esp_id] := 1
    }
    step_5_tab := step_5_map[esp_info.title esp_info.esp_id]
    ; step_5_window_0_deg()
    ; Sleep(20)
    send_WM_COPYDATA_dev("HIDE_SPLIT_VIEW", "ESPRIT - ")
    if step_5_tab == 1 {
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:1", "ESPRIT - ")
        step_5_crossball := 1
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:1", "ESPRIT - ")
        step_5_margin := 1
        ; send_WM_COPYDATA("DISABLE_LAYER:기본값", "ESPRIT - ")
    }
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

!Numpad9::{
    global step_5_margin
    global step_5_crossball
    global step_5_map
    esp_info := get_active_esprit_info()
    if not step_5_map.Has(esp_info.title esp_info.esp_id){
        step_5_map[esp_info.title esp_info.esp_id] := 1
    }
    step_5_tab := step_5_map[esp_info.title esp_info.esp_id]
    ; step_5_window_120_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:2", "ESPRIT - ")
        step_5_crossball := 2
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:2", "ESPRIT - ")
        step_5_margin := 2
        ; send_WM_COPYDATA("DISABLE_LAYER:기본값", "ESPRIT - ")
    }
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

!Numpad1::{
    global step_5_margin
    global step_5_crossball
    global step_5_map
    esp_info := get_active_esprit_info()
    if not step_5_map.Has(esp_info.title esp_info.esp_id){
        step_5_map[esp_info.title esp_info.esp_id] := 1
    }
    step_5_tab := step_5_map[esp_info.title esp_info.esp_id]
    ; step_5_window_240_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:3", "ESPRIT - ")
        step_5_crossball := 3
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:3", "ESPRIT - ")
        step_5_margin := 3
        ; send_WM_COPYDATA("DISABLE_LAYER:기본값", "ESPRIT - ")
    }
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

!Numpad3::{
    global step_5_margin
    global step_5_crossball
    global step_5_map
    esp_info := get_active_esprit_info()
    if not step_5_map.Has(esp_info.title esp_info.esp_id){
        step_5_map[esp_info.title esp_info.esp_id] := 1
    }
    step_5_tab := step_5_map[esp_info.title esp_info.esp_id]
    ; step_5_window_270_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:4", "ESPRIT - ")
        step_5_crossball := 4
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:4", "ESPRIT - ")
        step_5_margin := 4
        ; send_WM_COPYDATA("DISABLE_LAYER:기본값", "ESPRIT - ")
    }
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

!Numpad0::{
    step_5_window_90_plus_deg()
}


z::{
    global step_5_map
    esp_info := get_active_esprit_info()
    step_5_map[esp_info.title esp_info.esp_id] := 1
}

x::{
    global step_5_map
    esp_info := get_active_esprit_info()
    step_5_map[esp_info.title esp_info.esp_id] := 2
}

^Numpad1::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }

    ExecuteMacroButtonCommand(1, get_active_esprit_info().esp_id)
}

legacy_step_2 := false

^Numpad2::{
    global base_index
    global legacy_step_2
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    ControlChooseString("All", "ComboBox4", "ESPRIT - ")

    esp_info := get_active_esprit_info()

    if get_case_type(esp_info.title) == "AOT" or get_case_type(esp_info.title) == "TLOC"{
        ExecuteMacroButtonCommand(2, get_active_esprit_info().esp_id)
        return
    }

    if legacy_step_2 {
        send_WM_COPYDATA_dev("ACTIVATE_BASE_DEGREE", esp_info.title)
        selected_view := get_current_angle("ahk_id" esp_info.esp_id) - 7

        ExecuteMacroButtonCommand(2, get_active_esprit_info().esp_id)

        send_WM_COPYDATA("DISABLE_LAYER:BACK TURNING", "ESPRIT - ")
        send_WM_COPYDATA("DISABLE_LAYER:CUT-OFF", "ESPRIT - ")
        send_WM_COPYDATA("ENABLE_LAYER:FRONT TURNING", "ESPRIT - ")


        base_work_id := WinWaitActiveTitleWithPID(esp_info.esp_pid, "Base Work Plane(Degree)")

        Loop selected_view{
            ControlSend("{Down}", , "ahk_id" base_work_id)
            Sleep(20)
        } 
        Sleep(200)
        ControlSend("{Tab}{Tab}{Up}", , "ahk_id" base_work_id)
        ControlSend("{Tab}{Tab}{Enter}", , "ahk_id" base_work_id)
        WatchForClose("ahk_id" base_work_id, (*) => go_to_next_esprit(esp_info.esp_id))
    } else {
        send_WM_COPYDATA_dev("CREATE_CROSSBALL_LAYERS_DEV3", "ESPRIT - ")
        Sleep(50)
        send_WM_COPYDATA("SELECT_CROSSBALL:1", "ESPRIT - ")
    }
}

^NumpadDown::{
    global base_index
    global legacy_step_2
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    ControlChooseString("All", "ComboBox4", "ESPRIT - ")

    esp_info := get_active_esprit_info()

    if legacy_step_2 or (get_case_type(esp_info.title) == "AOT" or get_case_type(esp_info.title) == "TLOC") {
        send_WM_COPYDATA_dev("ACTIVATE_BASE_DEGREE", esp_info.title)
        selected_view := get_current_angle("ahk_id" esp_info.esp_id) - 7

        ExecuteMacroButtonCommand(2, get_active_esprit_info().esp_id)

        send_WM_COPYDATA("DISABLE_LAYER:BACK TURNING", "ESPRIT - ")
        send_WM_COPYDATA("DISABLE_LAYER:CUT-OFF", "ESPRIT - ")
        send_WM_COPYDATA("ENABLE_LAYER:FRONT TURNING", "ESPRIT - ")

        base_work_id := WinWaitActiveTitleWithPID(esp_info.esp_pid, "Base Work Plane(Degree)")

        Loop selected_view{
            ControlSend("{Down}", , "ahk_id" base_work_id)
        }
        Sleep(200)
        ControlSend("{Tab}{Enter}", , "ahk_id" base_work_id)
        WatchForClose("ahk_id" base_work_id, (*) => go_to_next_esprit(esp_info.esp_id))
    } else {
        send_WM_COPYDATA_dev("CREATE_CROSSBALL_LAYERS_DEV4", "ESPRIT - ")
        Sleep(50)
        send_WM_COPYDATA("SELECT_CROSSBALL:1", "ESPRIT - ")
    }
}

^Numpad3::{
    ; if not WinActive("ESPRIT - "){
    ;     WinActivate("ESPRIT - ")
    ; }
    ExecuteMacroButtonCommand(3, get_active_esprit_info().esp_id)
    ; send_WM_COPYDATA_dev("SPLIT_WINDOWS", "ESPRIT - ")
}

^NumpadPgdn::{
    for id in WinGetList("ESPRIT - "){
        send_WM_COPYDATA_dev("SPLIT_WINDOWS", "ahk_id" id)
        Sleep(200)
    }
}

^Numpad4::{
    esp_info := get_active_esprit_info()
    case_type := get_case_type(WinGetTitle("ahk_id" esp_info.esp_id))
    
    if case_type != "TLOC" and case_type != "AOT" {
        ; Send("{Ctrl down}b{Ctrl up}")
        ; Sleep(200)
        PostMessage(BeginProcessingMsg, esp_info.esp_id, , , 0xFFFF)
        Sleep(200)
        go_to_next_esprit(esp_info.esp_id)

    } else {
        ExecuteMacroButtonCommand(4,get_active_esprit_info().esp_id)
        cam_automation_id := WinWaitTitleWithPID(esp_info.esp_pid, "CAM Automation", "[4] Rebuild Freeform")

        bottom_z_limit := -5
        send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_info.esp_id)
        WinWaitClose("ahk_id" cam_automation_id)
        
        go_to_next_esprit(esp_info.esp_id)
    }    
}
^Numpad5::{
    ; if not WinActive("ESPRIT - "){
    ;     WinActivate("ESPRIT - ")
    ; }
    ; macro_button5()
    ExecuteMacroButtonCommand(5, get_active_esprit_info().esp_id)
    step_5_tab := 2
}

text_views := Map()
^Numpad6::{
    send_WM_COPYDATA_dev("HIDE_SPLIT_VIEW", "ESPRIT - ")
    ControlChooseString("All", "ComboBox4", "ESPRIT - ")
    global text_views
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    esp_info := get_active_esprit_info()

    ExecuteMacroButtonCommand(6, get_active_esprit_info().esp_id)
    If text_views.Has(esp_info.title){
        update_angle(text_views[esp_info.title], "ahk_id" esp_info.esp_id)
    }
    send_WM_COPYDATA_dev("CLEAR", esp_info.title)
}

^!Numpad1::{
    CoordMode("Mouse", "Screen")
    click_and_return(32, 1020)
}

^!Numpad3::{
    CoordMode("Mouse", "Screen")
    click_and_return(80, 1020)
    send_WM_COPYDATA("HIGHLIGHT_CROSSBALLS", "ESPRIT - ")
}

; Deg 1
!1::{
    step_3_deg1()
}

; Deg 2 
!2::{
    step_3_deg2()
}

; Deg 3 
!3::{
    step_3_deg3()
}

; +90 Deg
!q::{
    step_3_degplus90()
}

; Toggle Yellow Checkbox
!w::{
    step_3_yellowcheckbox()
}

; Tab 1
!a::{
    ; if not WinActive("ESPRIT - "){
    ;     WinActivate("ESPRIT - ")
    ; }
    ; esp_info := get_active_esprit_info()
    ; switch esp_info.Step3Tab{
    ;     case 1:
    ;         esp_info.Step3Tab1Deg := get_current_angle("ESPRIT - ") 
    ;     case 2:
    ;         esp_info.Step3Tab2Deg := get_current_angle("ESPRIT - ") 
    ;     case 3:
    ;         esp_info.Step3Tab3Deg := get_current_angle("ESPRIT - ") 
    ; }
    ; esp_info.Step3Tab := 1
    ; update_angle(esp_info.Step3Tab1Deg, "ESPRIT - ")
    step_3_tab1()
}

j::{
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

; Tab 2
!s::{
    send_WM_COPYDATA_dev("HIDE_SPLIT_VIEW", "ESPRIT - ")
    send_WM_COPYDATA("FACE_LIMITATION", "ESPRIT - ")
    send_WM_COPYDATA("SELECT_VIEW:1", "ESPRIT - ")
    ; send_WM_COPYDATA_dev("ACTIVATE_BASE_DEGREE", "ESPRIT - ")
    send_WM_COPYDATA_dev("ACTIVATE_BASE_DEGREE_PLUS_90", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")
}

face_map := Map() 

; Tab 3
!d::{
    global face_map

    info := get_active_esprit_info()

    if not face_map.Has(info.title info.esp_id){
        face_map.Set(info.title info.esp_id, false)
    }
    ; step_3_tab3()
    send_WM_COPYDATA("LAYER13_LIMITATION", "ESPRIT - ")
    send_WM_COPYDATA_dev("ZOOM_OUT", "ESPRIT - ")

    if not face_map.Get(info.title info.esp_id){
        send_WM_COPYDATA_dev("ACTIVATE_BASE_DEGREE", "ESPRIT - ")
    }

    face_map[info.title info.esp_id] := not face_map[info.title info.esp_id]
}

!g::{
    If ControlGetText("ComboBox4", "ESPRIT - ") == "All"{
        ControlChooseString("Geometry", "ComboBox4", "ESPRIT - ")
    } else {
        ControlChooseString("All", "ComboBox4", "ESPRIT - ")
    }
}

!Right::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(205, 250)
    send_WM_COPYDATA("TRANSLATE_X:0.1", "ESPRIT - ")
}

!Left::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(155, 250)
    send_WM_COPYDATA("TRANSLATE_X:-0.1", "ESPRIT - ")
}

!Up::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(155, 210)
    send_WM_COPYDATA("TRANSLATE_Y:0.1", "ESPRIT - ")
}

!Down::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(205, 210)
    send_WM_COPYDATA("TRANSLATE_Y:-0.1", "ESPRIT - ")
}

+Left::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(155, 290)
    send_WM_COPYDATA("ROTATE_Z:1", "ESPRIT - ")
}

+Right::{
    ; CoordMode("Mouse", "Screen")
    ; click_and_return(205, 290)
    send_WM_COPYDATA("ROTATE_Z:-1", "ESPRIT - ")
}

+!c::{
    send_WM_COPYDATA_dev("CREATE_CURVE", "ESPRIT - ")
}

!c::
^!MButton::{
    esp_info := get_active_esprit_info()
    ; send_WM_COPYDATA_dev("CREATE_CURVE", "ESPRIT - ")
    ; Sleep(1000)
    GetFCCount(){
        result := 0 
        send_WM_COPYDATA_dev("GET_LARGEST_CHAIN_COUNT", esp_info.title)
        FeatureChainCountMsg := DllCall("RegisterWindowMessageW", "Str", "FEATURE_CHAIN_COUNT")
        OnFeatureChainCountMsg(wParam, lParam, msg, hwnd){
            if esp_info.esp_id == wParam {
                result := lParam
            }
        }

        OnMessage(FeatureChainCountMsg, OnFeatureChainCountMsg)

        while result == 0{
            Sleep(100)
        }

        return result
    }

    fc_count := GetFCCount() 
    consolelog(fc_count)
    if fc_count == 0 {
        MsgBox("failed")
        return
    }
    loft_surface()
    Sleep(50)
    WinActivate("ahk_id" esp_info.esp_id)

    Send("Q{Enter}")
    Sleep(50)
    Send(fc_count - 1)
    Sleep(50)
    Send("{Enter}")
    Sleep(50)
    Send("Q{Enter}")
    Sleep(50)
    Send(fc_count)
    Sleep(50)
    Send("{Enter}")
    Sleep(100)
	PostMessage 0x111, 3055 , , , esp_info.title 
}

^+MButton::{
    ; send_WM_COPYDATA_dev("SCALE_CURVE", "ESPRIT - ")
    loft_surface()
}

^+NumpadEnter::
^+Enter::{
    global text_views
    esp_info := get_active_esprit_info()
    rotate_id := WinExistTitleWithPID(esp_info.esp_pid, "Rotate STL")
    if rotate_id{
        WinHide("ahk_id" rotate_id)
    }
    ExecuteMacroButtonCommand(6, get_active_esprit_info().esp_id)
    WinWaitActive("Engraving Program Number Text")
    CoordMode("Mouse", "Screen")
    click_and_return(106, 126)
    WinWaitActive("esprit", "OK")
    WinClose("esprit", "OK")
    send_WM_COPYDATA_dev("SET_BASE_DEGREE:DEG" get_angle_deg("ahk_id" esp_info.esp_id), esp_info.title)
    text_views[esp_info.title] := get_current_angle("ahk_id" esp_info.esp_id)
}

^!NumpadEnter::
^!Enter::{
    esp_info := get_active_esprit_info()
    rotate_id := WinExistTitleWithPID(esp_info.esp_pid, "Rotate STL")
    if rotate_id{
        WinHide("ahk_id" rotate_id)
    }
    ExecuteMacroButtonCommand(6, get_active_esprit_info().esp_id)
    WinWaitActive("Engraving Program Number Text")
    CoordMode("Mouse", "Screen")
    click_and_return(103, 336)
    ; send_WM_COPYDATA_dev("CREATE_CROSSBALL_LAYERS_DEV", "ESPRIT - ")
    ; go_to_next_esprit(esp_info.esp_id)
    ; Sleep(200)
    ; send_WM_COPYDATA("SIMULATE_BACK", "ahk_id" esp_info.esp_id)   
}

!e::{
    show_milling_tool()
}

^Left::{
    translate_selection(-0.5, 0, 0)
}

; Auto-Start
+q::{
    WinWaitActive("ahk_exe esprit.exe")
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) == "ASC"){
        macro_button1()
        if(WinWait("esprit", "&Yes")){
            WinActivate("esprit")
            Send("{Enter}{Enter}{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("60 147")
            }
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == false){
        macro_button1()
        if(WinWait("CAM Automation")){
            WinActivate("CAM Automation")
            Send("{Enter}")
        }

        if(WinWait("esprit")){
            WinActivate("esprit")
            Send("{Enter}")
        }

        if(WinWait("Direction Check")){
            WinActivate("Direction Check")
            Send("{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("65 115")
            }
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == true){
        macro_button1()
        if(WinWait("CAM Automation")){
            WinActivate("CAM Automation")
            Send("{Enter}")
        }

        if(WinWait("esprit")){
            WinActivate("esprit")
            Send("{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("65 115")
            }
        }
    }
}

^+Down::{
    esp_info := get_active_esprit_info()
    case_type := get_case_type(esp_info.title)
    if case_type == "AOT" or case_type == "TLOC"{
        send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
    } else {
        send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
    }
}

^+Up::{
    esp_info := get_active_esprit_info()
    case_type := get_case_type(esp_info.title)
    if case_type == "AOT" or case_type == "TLOC"{
        send_WM_COPYDATA("RAISE_MARGINS", "ESPRIT - ")
    } else {
        send_WM_COPYDATA("RAISE_MARGINS", "ESPRIT - ")
    }
}

^Up::{
    if(WinExist("Check Rough ML & Create Border Solid")){
        WinActivate("Check Rough ML & Create Border Solid")
        BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        ; Get the current number of passes
        A_Clipboard := ""
        Click("30 70")
        Sleep(20)
        Click("154 240")
        Send("^a^c")
        ClipWait(2)

        if(IsInteger(A_Clipboard)){
            passes := A_Clipboard + 1

            Click("30 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")

            Sleep(20)
            Click("108 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")
            Sleep(20)

            Click("53 157")
            BlockInput("MouseMoveOff")
        }
    }
}

^Down::{
    if(WinExist("Check Rough ML & Create Border Solid")){
        WinActivate("Check Rough ML & Create Border Solid")
        BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        ; Get the current number of passes
        A_Clipboard := ""
        Click("30 70")
        Sleep(20)
        Click("154 240")
        Send("^a^c")
        ClipWait(2)

        if(IsInteger(A_Clipboard)){
            passes := A_Clipboard - 1

            Click("30 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")

            Sleep(20)
            Click("108 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")
            Sleep(20)

            Click("53 157")
            BlockInput("MouseMoveOff")
        }
    }
}

+w::{
    set_bounding_points()
}

+3::{
    res := SendMessage(TVM_GETITEMW, , , "SysTreeView321", "Project Manager")
    MsgBox(res)
}