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
#Include %A_ScriptDir%\Lib\util.ahk
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

step_5_tab := 1

STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

SuspendScriptMsg := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
TerminateMsg := DllCall("RegisterWindowMessageA", "Str", "Terminate")

file_map := {data:loads_completed_files()}
ObjRegisterActive(file_map, "{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

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

save_on_exit_callback(*){
    save_completed_files(file_map.data)
    PostMessage(TerminateMsg, , , ,0xFFFF)
}
OnExit(save_on_exit_callback)


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
f17::{
    Run("C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe", , ,&esprit_pid)
}
#SuspendExempt False

#HotIf WinActive("ahk_exe esprit.exe") or WinActive("ahk_exe ESPRIT.NCEDIT.exe")
f16::{
    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " auto")
}

+f16::{
    esp_pid := WinGetPID("ESPRIT - ") 
    Run("esp.ahk " esp_pid " manual")
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
^b::
^f15::
f9::{
    _id := WinGetID("ESPRIT - ")
    save_file()
    generate_nc()
}

^f16::{
    selected_file := ""
    For k,v in file_map{
        if v = False and FileExist(STL_FILE_PATH "\" k){
            selected_file := k
            break
        }
    }
    found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
    if found_pos {
        SplitPath(selected_file, &name)
        open_file()
        WinWaitActive("Open")
        ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770")
        ControlSetChecked(0,"Button5","ahk_class #32770")
        ControlSend("{Enter}", "Button2","ahk_class #32770")
        WinWait("ahk_class #32770", "&Yes", 1)
        if WinExist("ahk_class #32770", "&Yes"){
            WinWaitClose("ahk_class #32770", "&Yes")
        }
        yn := show_custom_dialog("Is the basic setting loaded?", "Tru-AHK")
        if yn != "Yes"{
            return
        }
        file_map[name] := true
        WinActivate("ESPRIT")
        macro_button1()
        WinWaitActive("CAM Automation")
        Send("{Enter}")
        WinWaitActive("Select file to open")
        Sleep(200)
        ControlSetText(selected_file, "Edit1", "Select file to open")
        Send("{Enter}")
    }
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

; G4
; +f16::{
;     selected_file := FileSelect(, STL_FILE_PATH)
;     if(selected_file != ""){
;         SplitPath(selected_file, &name)
;         found_pos := RegExMatch(name, "\(([A-Za-z0-9\-]+),", &sub_pat)
;         open_file()
;         WinWaitActive("ahk_class #32770")
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
;         ; set_bounding_points()
;         macro_button1()
;         WinWaitActive("CAM Automation")
;         Send("{Enter}")
;         WinWaitActive("Select file to open")
;         Sleep(200)
;         ControlSetText(selected_file, "Edit1", "Select file to open")
;         Send("{Enter}")
;         switch get_case_type(name) {
;             case "DS":
;                 ds_startup_commands()
;             case "ASC":
;                 asc_startup_commands()
;             case "TLOC": 
;                 tl_aot_startup_commands()
;             case "AOT":
;                 tl_aot_startup_commands()
;             default: 
;                 return
;         }
;     }
; }

f12::{
    ProcessExist("esprit.exe")
    pid := WinGetPID("A")
    ProcessClose(pid)
}


; ===== Remappings =====
Space::Enter
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
    try{
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

!LButton::{
    Send("{LButton}{RButton}{LButton}")
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

r::{
    distance_val := 5
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
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
    draw_straight_border()
}

; G5 Key

f18::{
    save_file()
}

; ===== Auto-Complete Margins =====
~Escape::{
    global passes

    passes := 5

    if not WinActive("ahk_class #32770","No Intersections P->L"){
        draw_path("cancel")
    }
    stop_simulation()
}

CapsLock::{
    line_tool()
}

+CapsLock::
XButton2::{
    draw_path("start")
}

~LButton::{
    if draw_path("get-state") {
        draw_path("click")
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
    CoordMode("Mouse", "Screen")
    MouseMove(46, 38, 0) ; Press Tab 1
    Click(170, 325) ; Click the Entry Box
    Send("^a-5")
    Click(175, 275) ; Click Regenerate
}

AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
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
}

+AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(40)
    ; 4th Margin
    Click("180 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
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
    step_5_window_0_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad9::{
    global step_5_tab
    step_5_window_120_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad1::{
    global step_5_tab
    step_5_window_240_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad3::{
    global step_5_tab
    step_5_window_270_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad0::{
    step_5_window_90_plus_deg()
}


z::{
    global step_5_tab
    step_5_window_tab_1()
    step_5_tab := 1
}

x::{
    global step_5_tab
    step_5_window_tab_2()
    step_5_tab := 2
}

^!Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_10_degrees()
    }
}

^!Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_10_degrees()
    }
}

^+Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_90_degrees()
    }
}

^+Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_90_degrees()
    }
}

^Numpad1::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button1()
}

^Numpad2::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button2()
}

^Numpad3::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button3()
}

^Numpad4::{
    ; unsuppress_operation()
    Sleep(20)
    enable_layer("28 '경계소재-5'")
    Sleep(20)
    enable_layer("29 '경계소재-5'")
    Sleep(20)
    enable_layer("14 '경계소재-4'")
    Sleep(20)
    enable_layer("15 '경계소재-5'")
    macro_button4()
}

^Numpad5::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button5()
    step_5_tab := 2
}

^Numpad6::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button_text()
}

^!Numpad1::{
    CoordMode("Mouse", "Screen")
    click_and_return(32, 1020)
}

^!Numpad3::{
    CoordMode("Mouse", "Screen")
    click_and_return(80, 1020)
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
    step_3_tab1()
}

; Tab 2
!s::{
    step_3_tab2()
}

; Tab 3
!d::{
    step_3_tab3()
}

!Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 250)
}

!Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 250)
}

!Up::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 210)
}

!Down::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 210)
}

+Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 290)
}

+Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 290)
}

^+Enter::{
    CoordMode("Mouse", "Screen")
    click_and_return(106, 126)
    WinWaitActive("esprit", "OK")
    WinClose("esprit", "OK")
}

^!Enter::{
    CoordMode("Mouse", "Screen")
    click_and_return(103, 336)
}

!e::{
    show_milling_tool()
}

; G3 Key
f15::{
    ids := WinGetList("esprit", "&Yes")
    for this_id in ids{
        try {
            WinMove(-600, 275, , , "ahk_id" this_id, "&Yes")
        }
    }
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

; G4
; f16::{
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
;         switch get_case_type(selected_file) {
;             case "DS":
;                 ds_startup_commands()
;             case "ASC":
;                 asc_startup_commands()
;             case "TLOC": 
;                 tl_aot_startup_commands()
;             case "AOT":
;                 tl_aot_startup_commands()
;             default: 
;                 return
;         }
;     }
; }

+3::{
    res := SendMessage(TVM_GETITEMW, , , "SysTreeView321", "Project Manager")
    MsgBox(res)
}