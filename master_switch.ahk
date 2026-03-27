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

SetSpaceAsConfirmMsg := DllCall("RegisterWindowMessageW", "Str", "SET_SPACE_CONFIRM")
UnsetSpaceAsConfirmMsg := DllCall("RegisterWindowMessageW", "Str", "UNSET_SPACE_CONFIRM")

RunStep4Msg := DllCall("RegisterWindowMessageW", "Str", "RunStep4Msg")

file_map := {data:loads_completed_files()}
ObjRegisterActive(file_map, "{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

spaceAsConfirmMap := Map()

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

SetTimer(process_f9_file_queue, 100)
process_f9_file_queue(){
    if f9_queue.Length > 0 {
        f9_object := f9_queue.Pop()
        Sleep(100)
        generate_nc("ahk_id" f9_object.esp_id)
        nc_id := WinWait("ESPRIT NC Editor", f9_object.case_id ".prg")
        WinClose("ahk_id" nc_id)
        WinWaitClose("ahk_id" nc_id)
        save_file("ahk_id" f9_object.esp_id)
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
        double_sided_border(true)
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
:c1o:>>CSDU::Single case

#HotIf WinActive("ahk_exe esprit.exe")

#MaxThreadsPerHotkey 1

^+f16::{
    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " auto")
}

+f16::{
    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " manual")
}

; f16::{
;     esp_pid := WinGetPID("ESPRIT - ") 
;     Run("esp.ahk " esp_pid " new")
; }

f16::{
    case_type := get_case_type(WinGetTitle("ahk_id" get_active_esprit_info().esp_id))
    if case_type == "TLOC" or case_type == "AOT"{
        Run("esp.ahk " esp_pid " auto")
        return
    }

    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " new_auto")
}

h::{
    ; MsgBox(WinGetID("ESPRIT - "))
    MsgBox(send_WM_COPYDATA("Hello World!!!", "ESPRIT - "))
}

l::{
    bottom_z_limit := -5
    send_WM_COPYDATA("CREATE_CROSSBALLS", "ESPRIT - ")
    send_WM_COPYDATA("CREATE_MARGINS", "ESPRIT - ")
    send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 1 " " bottom_z_limit, "ESPRIT - ")
    send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 2 " " bottom_z_limit, "ESPRIT - ")
    send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 3 " " bottom_z_limit, "ESPRIT - ")
    send_WM_COPYDATA("SET_CROSSBALL_BOTTOM_Z_LIMIT:" 4 " " bottom_z_limit, "ESPRIT - ")
}

k::{
    create_layer("1")
    translate_selection(-3, 0, 0)
    KeyWait("Enter", "D")
    smash_selection(0.001, 15)
    Send("{Enter}")
    KeyWait("Enter", "D")
    smash_selection(0.001, 15)
    Send("{Enter}")
    create_layer("2")
    three_point_circle()
    KeyWait("Enter", "D")
    Send("{Escape}{Escape}{Escape}")
    delete_layer("1")
    translate_selection_click()
    KeyWait("Enter", "D")
    delete_layer("2")
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
    go_to_next_esprit(esp_info.esp_id)
    send_WM_COPYDATA("SIMULATE_BACK", "ahk_id" esp_info.esp_id)
}

; G3 Key
+f15::
^b::
f9::{
    esp_info := get_active_esprit_info()

    case_id := get_case_id(WinGetTitle("ahk_id" esp_info.esp_id))

    newF9QueueObject := F9QueueObject()
    newF9QueueObject.esp_pid := esp_info.esp_pid
    newF9QueueObject.esp_id := esp_info.esp_id
    newF9QueueObject.case_id := case_id
    
    ; save_file("ahk_id" esp_info.esp_id)
    go_to_next_esprit(esp_info.esp_id)
    f9_queue.InsertAt(1, newF9QueueObject)
    
    ; MsgBox(f9_queue.Length)
    ; WinActivate("ahk_id" _id)
}

; ^f16::{
;     selected_file := ""
;     For k,v in file_map{
;         if v = False and FileExist(STL_FILE_PATH "\" k){
;             selected_file := k
;             break
;         }
;     }
;     found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
;     if found_pos {
;         SplitPath(selected_file, &name)
;         open_file()
;         WinWaitActive("Open")
;         ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770")
;         ControlSetChecked(0,"Button5","ahk_class #32770")
;         ControlSend("{Enter}", "Button2","ahk_class #32770")
;         WinWait("ahk_class #32770", "&Yes", 1)
;         if WinExist("ahk_class #32770", "&Yes"){
;             WinWaitClose("ahk_class #32770", "&Yes")
;         }
;         yn := show_custom_dialog("Is the basic setting loaded?", "Tru-AHK")
;         if yn != "Yes"{
;             return
;         }
;         file_map[name] := true
;         WinActivate("ESPRIT")
;         macro_button1()
;         WinWaitActive("CAM Automation")
;         Send("{Enter}")
;         WinWaitActive("Select file to open")
;         Sleep(200)
;         ControlSetText(selected_file, "Edit1", "Select file to open")
;         Send("{Enter}")
;     }
; }

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
; Space::Enter
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

a::{
    try{
        deg0()
    }
}

s::{
    try{
        deg90()
    }
}

d::{
    try{
        deg180()
    }
}

f::{
    try{
        deg270()
    }
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
        }
    }
}

+!WheelDown::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        increment_90_degrees()
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
        }
    }
}

+!WheelUp::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        decrement_90_degrees()  
    }
}

; ===== Controls =====
Space::{
    esp_info := get_active_esprit_info()
    ; PostMessage(ConfirmESPMsg, esp_info.esp_id, , , 0xFFFF)
    if spaceAsConfirmMap.Has(esp_info.esp_id) and spaceAsConfirmMap[esp_info.esp_id] == true {
        send_WM_COPYDATA("CONFIRM", "ahk_id" esp_info.esp_id)
    } else {
        Send("{Enter}")
    }
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

r::{
    send_WM_COPYDATA("ROTATE_STL_45", "ESPRIT - ")
}

!r::{
    send_WM_COPYDATA("ROTATE_STL_30", "ESPRIT - ")
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
    three_point_tool()
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

^d::{
    highlight_tool()
}

^e::{
    extrude_tool()
}

+Space::{
    ; esp_info := get_active_esprit_info()
    ; PostMessage(RefreshDocumentMsg, esp_info.esp_id, , , 0xFFFF)
    toggle_simulation()
}

g::{
    ; global isDrawing
    ; global lastMousePosX
    ; global lastMousePosY
    
    ; if isDrawing {
    ;     isDrawing := false
    ;     highlight_tool()
    ;     Send("{Escape}")
    ;     Send("{Shift down}")
    ;     MouseClick('L', lastMousePosX, lastMousePosY, 2, 0)
    ;     Send("{Shift up}")
    ;     highlight_tool()
    ;     solid_view()
    ;     Sleep(100)
    ; }
    
    if not WinActive("Extrude Boss/Cut"){
        double_sided_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

b::{
    ; global isDrawing
    ; global lastMousePosX
    ; global lastMousePosY
    
    ; if isDrawing {
    ;     isDrawing := false
    ;     highlight_tool()
    ;     Send("{Escape}")
    ;     Send("{Shift down}")
    ;     MouseClick('L', lastMousePosX, lastMousePosY, 2, 0)
    ;     Send("{Shift up}")
    ;     highlight_tool()
    ;     solid_view()
    ;     Sleep(100)

    ; }

    if not WinExist("Extrude Boss/Cut"){
        cut_with_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

; r::{
;     distance_val := 5
;     if not WinActive("Extrude Boss/Cut"){
;         extrude_by(distance_val)
;     } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
;         extrude_by(distance_val)
;     } else {
;         toggle_extrude_window_reverse_direction()
;     }
; }

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
    global passes
    global isDrawing
    global lastMousePosX
    global lastMousePosY

    passes := 5

    if not WinActive("ahk_class #32770","No Intersections P->L"){
        draw_path("cancel")
    }

    ; if isDrawing {
    ;     isDrawing := false
    ;     highlight_tool()
    ;     Send("{Shift down}")
    ;     MouseClick('L', lastMousePosX, lastMousePosY, 2, 0)
    ;     Send("{Shift up}")
    ;     highlight_tool()
    ; }

    stop_simulation()
}

CapsLock::{
    global isDrawing
    isDrawing := true
    line_tool()
}

+CapsLock::
XButton2::{
    draw_path("start")
}

~LButton::{
    global isDrawing
    global lastMousePosX
    global lastMousePosY

    if draw_path("get-state") {
        draw_path("click")
    }

    if isDrawing {
        MouseGetPos(&mousePosX, &mousePosY)
        lastMousePosX := mousePosX
        lastMousePosY := mousePosY
    }
}

RButton::{
    if draw_path("get-state") {
        draw_path("complete")
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
    global step_5_tab
    global step_5_margin
    global step_5_crossball
    ; step_5_window_0_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:1", "ESPRIT - ")
        step_5_crossball := 1
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:1", "ESPRIT - ")
        step_5_margin := 1
    }
}

!Numpad9::{
    global step_5_tab
    global step_5_margin
    global step_5_crossball
    ; step_5_window_120_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:2", "ESPRIT - ")
        step_5_crossball := 2
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:2", "ESPRIT - ")
        step_5_margin := 2
    }
}

!Numpad1::{
    global step_5_tab
    global step_5_margin
    global step_5_crossball
    ; step_5_window_240_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:3", "ESPRIT - ")
        step_5_crossball := 3
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:3", "ESPRIT - ")
        step_5_margin := 3
    }
}

!Numpad3::{
    global step_5_tab
    global step_5_margin
    global step_5_crossball
    ; step_5_window_270_deg()
    ; Sleep(20)
    if step_5_tab = 1{
        ; step_5_window_90_plus_deg()
        send_WM_COPYDATA("SELECT_CROSSBALL:4", "ESPRIT - ")
        step_5_crossball := 4
    } else if step_5_tab == 2 {
        send_WM_COPYDATA("SELECT_MARGIN:4", "ESPRIT - ")
        step_5_margin := 4
    }
}

!Numpad0::{
    step_5_window_90_plus_deg()
}


z::{
    global step_5_tab
    ; step_5_window_tab_1()
    step_5_tab := 1
}

x::{
    global step_5_tab
    ; step_5_window_tab_2()
    step_5_tab := 2

    ; esp_info := get_active_esprit_info()

    ; if not esp_info.Step5Saved {
    ;     save_and_create_checkpoint("margins", esp_info.esp_id)
    ;     esp_info.Step5Saved := true
    ; }
}

^Numpad1::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }

    ExecuteMacroButtonCommand(1, get_active_esprit_info().esp_id)
}

^Numpad2::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    ExecuteMacroButtonCommand(2,get_active_esprit_info().esp_id)
}

^Numpad3::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    ExecuteMacroButtonCommand(3,get_active_esprit_info().esp_id)
}

^Numpad4::{

    esp_info := get_active_esprit_info()
    case_type := get_case_type(WinGetTitle("ahk_id" esp_info.esp_id))
    
    
    ExecuteMacroButtonCommand(4,get_active_esprit_info().esp_id)
    cam_automation_id := WinWaitTitleWithPID(esp_info.esp_pid, "CAM Automation", "[4] Rebuild Freeform")

    bottom_z_limit := -5
    send_WM_COPYDATA("SET_ALL_CROSSBALL_BOTTOM_Z_LIMIT:" bottom_z_limit, "ahk_id" esp_info.esp_id)
    if case_type != "TLOC" and case_type != "AOT" {
        
        send_WM_COPYDATA("CREATE_CROSSBALLS", "ESPRIT - ")
        send_WM_COPYDATA("CREATE_MARGINS", "ESPRIT - ")
        send_WM_COPYDATA("BUILD_ESP", "ESPRIT - ")
    }

    WinWaitClose("ahk_id" cam_automation_id)
    go_to_next_esprit(esp_info.esp_id)
}
^Numpad5::{
    ; if not WinActive("ESPRIT - "){
    ;     WinActivate("ESPRIT - ")
    ; }
    ; macro_button5()
    ExecuteMacroButtonCommand(5, get_active_esprit_info().esp_id)
    step_5_tab := 2
}

^Numpad6::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    ExecuteMacroButtonCommand(6, get_active_esprit_info().esp_id)
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

; Tab 2
!s::{
    ; step_3_tab2()
    send_WM_COPYDATA("FACE_LIMITATION", "ESPRIT - ")
    update_angle(get_current_angle("ESPRIT - "), "ESPRIT - ")
}

; Tab 3
!d::{
    ; step_3_tab3()
    send_WM_COPYDATA("LAYER13_LIMITATION", "ESPRIT - ")
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

!XButton2::
!c::
^!MButton::{
    esp_info := get_active_esprit_info()
    PostMessage(ConfirmESPMsg, esp_info.esp_id, , , 0xFFFF)
}

^+NumpadEnter::
^+Enter::{
    CoordMode("Mouse", "Screen")
    click_and_return(106, 126)
    WinWaitActive("esprit", "OK")
    WinClose("esprit", "OK")
}

^!NumpadEnter::
^!Enter::{
    esp_info := get_active_esprit_info()

    CoordMode("Mouse", "Screen")
    click_and_return(103, 336)
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
    send_WM_COPYDATA("LOWER_MARGINS", "ESPRIT - ")
}

^+Up::{
    send_WM_COPYDATA("RAISE_MARGINS", "ESPRIT - ")
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