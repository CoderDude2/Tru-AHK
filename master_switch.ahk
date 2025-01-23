#Requires Autohotkey v2.0

#SingleInstance Force
SetWorkingDir A_ScriptDir

if(FileExist("old_master_switch.exe")){
    FileDelete("old_master_switch.exe")
}

; ===== Global Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false
prefs_file_path := A_AppData "\tru-ahk\prefs.ini"

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\updater.ahk
#Include %A_ScriptDir%\Lib\dashboard.ahk

USER_LANGUAGE := get_language()

if USER_LANGUAGE == "en" {
    extrude_window_name := "Extrude Boss/Cut"
} else if USER_LANGUAGE == "ko" {
    extrude_window_name := "보스 돌출/잘라내기"
}   

if(!FileExist(prefs_file_path)){
    create_default_prefs_file()
}

remote_path := IniRead("config.ini", "info", "remote_path")
if(check_for_update(A_ScriptDir, remote_path)){
    result := MsgBox("An update is available. Do you want to install it?",,"Y/N")
    if(result == "Yes"){
        update(remote_path)
    }
}

if(IniRead(A_ScriptDir "\config.ini", "info", "show_changelog") == "True"){
    Run A_ScriptDir "\resources\changelog.html"
    IniWrite("False", A_ScriptDir "\config.ini", "info", "show_changelog")
}

; ===== Dashboard Menu =====
A_TrayMenu.Add()
A_TrayMenu.Add("Open Dashboard", open_dashboard)

SetDefaultMouseSpeed 0

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


file_map := loads_completed_files()

save_on_exit_callback(*){
    save_completed_files(file_map)   
}
OnExit(save_on_exit_callback)

#SuspendExempt
SetTimer(update_file_map, 100)

update_file_map(){
    Loop Files, get_stl_path() "\*", "F"{
        if not file_map.Has(A_LoopFileName){
            file_map[A_LoopFileName] := false
        }
    }

    for k,v in file_map{
        if not FileExist(get_stl_path() "\" k){
            file_map.Delete(k)
        }
    }
}

;G1
f13::
^.::{
    save_completed_files(file_map)
    Reload
}

;Ctrl+G1
^f13::
^+,::{
    Suspend
}

~Escape::{
    BlockInput("MouseMoveOff")
    global click_index
    global path_tool_active

    click_index := 0
    path_tool_active := false

    if WinActive("ahk_exe esprit.exe"){
        stop_simulation()
        cancel_all_set()
    }   
}

; G5 Key
f17::
^+o::{
    Run "C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe"
}

#SuspendExempt False

#HotIf WinActive("ahk_exe esprit.exe")

f12::{
    try{
        mode := IniRead(prefs_file_path, "f12_mode", "value")    
    } catch OSError {
        create_default_prefs_file()
        mode := IniRead(prefs_file_path, "f12_mode", "value")  
    }
    

    switch mode{
        Case "Disabled":
            Send("{F12}")
        Case "Active Instance":
            ProcessExist("esprit.exe")
            pid := WinGetPID("A")
            ProcessClose(pid)
        Case "All Instances":
            while ProcessExist("esprit.exe"){
                ProcessClose("esprit.exe")
            }
    }
}

^f1::{
    open_help()
}

^f2::{
    open_changelog()   
}

^,::{
    open_dashboard()
}

^o::{
    selected_file := FileSelect(, get_stl_path())
    if(selected_file != ""){
        SplitPath(selected_file, &name)
        file_map[name] := true

        found_pos := RegExMatch(name, "\(([A-Za-z0-9\-]+),", &sub_pat)
        if not FileExist(get_basic_setting_path() "\" sub_pat[1] ".esp"){
            MsgBox("Basic setting `"" sub_pat[1] ".esp`" does not exist!")
            return
        }
        open_file()
        WinWaitActive("ahk_class #32770", "&Open")
        ControlSetText(get_basic_setting_path() "\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770")
        ControlSetChecked(0,"Button5","ahk_class #32770")
        ControlSend("{Enter}", "Button2","ahk_class #32770")
        yn := MsgBox("Is the basic setting loaded?",,"YesNoCancel 0x1000")
        if yn != "Yes"{
            return
        }
        WinActivate("ESPRIT")
        macro_button_1()
        WinWaitActive("CAM Automation")
        Send("{Enter}")
        WinWaitActive("Select file to open")
        ControlSetText(get_stl_path(), "Edit2", "Select file to open")
        ControlSetText(selected_file, "Edit1", "Select file to open")
        Send("{Enter}")
    }
}

; G4
f16::{
    selected_file := ""
    For k,v in file_map{
        if v = False and FileExist(get_stl_path() "\" k){
            selected_file := k
            file_map[k] := true
            break
        }
    }
    found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
    if found_pos {
        if not FileExist(get_basic_setting_path() "\" sub_pat[1] ".esp"){
            MsgBox("Basic setting `"" sub_pat[1] ".esp`" does not exist!")
            return
        }
        open_file()
        WinWaitActive("ahk_class #32770", "&Open")
        ControlSetText(get_basic_setting_path() "\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770", "&Open")
        ControlSetChecked(0,"Button5","ahk_class #32770", "&Open")
        ControlSend("{Enter}", "Button2","ahk_class #32770", "&Open")
        yn := MsgBox("Is the basic setting loaded?",,"YesNoCancel 0x1000")
        if yn != "Yes"{
            return
        }
        WinActivate("ESPRIT - ")
        macro_button_1()
        WinWaitActive("CAM Automation")
        Send("{Enter}")
        WinWaitActive("Select file to open")
        Sleep(200)
        ControlSetText(selected_file, "Edit1", "Select file to open")
        Send("{Enter}")
        switch get_case_type(selected_file) {
            case "DS":
                ds_startup_commands()
            case "ASC":
                asc_startup_commands()
            case "TLOC":
                tl_aot_startup_commands()
            case "AOT":
                tl_aot_startup_commands()
            default: 
                return
        }
    }
}

+f16::{
    selected_file := FileSelect(, get_stl_path())
    if(selected_file != ""){
        SplitPath(selected_file, &name)
        file_map[name] := true

        found_pos := RegExMatch(name, "\(([A-Za-z0-9\-]+),", &sub_pat)
        if not FileExist(get_basic_setting_path() "\" sub_pat[1] ".esp"){
            MsgBox("Basic setting `"" sub_pat[1] ".esp`" does not exist!")
            return
        }
        open_file()
        WinWaitActive("ahk_class #32770", "&Open")
        ControlSetText(get_basic_setting_path() "\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770", "&Open")
        ControlSetChecked(0,"Button5","ahk_class #32770", "&Open")
        ControlSend("{Enter}", "Button2","ahk_class #32770", "&Open")
        yn := MsgBox("Is the file loaded?",,"YesNoCancel 0x1000")
        if yn != "Yes"{
            return
        }
        WinActivate("ESPRIT - ")
        macro_button_1()
        WinWaitActive("CAM Automation")
        Send("{Enter}")
        WinWaitActive("Select file to open")
        Sleep(200)
        ControlSetText(selected_file, "Edit1", "Select file to open")
        Send("{Enter}")
        switch get_case_type(name) {
            case "DS":
                ds_startup_commands()
            case "ASC":
                asc_startup_commands()
            case "TLOC":
                tl_aot_startup_commands()
            case "AOT":
                tl_aot_startup_commands()
            default: 
                return
        }
    }
}

; ===== Remappings =====
Space::Enter
w::{
    try {
        w_pref := IniRead(prefs_file_path, "w_as_delete", "value")
    } catch OSError {
        create_default_prefs_file()
        w_pref := IniRead(prefs_file_path, "w_as_delete", "value")
    }

    if(w_pref = 1){
        Send("{Delete}")
    }
}

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send("3-1. ROUGH_ENDMILL_" formatted_angle "DEG")
}

:*:3-2::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send("3-2. ROUGH_ENDMILL_" formatted_angle "DEG")
}

:*:3-3::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send("3-3. ROUGH_ENDMILL_" formatted_angle "DEG")
}

:*:8-1::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-1. " formatted_angle "DEG CROSS BALL ENDMILL R0.75")
 }

 :*:8-2::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-2. " formatted_angle "DEG-1 CROSS BALL ENDMILL R0.75")
 }

 :*:8-3::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-3. " formatted_angle "DEG CROSS BALL ENDMILL R0.75")
 }

 :*:8-4::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-4. " formatted_angle "DEG-1 CROSS BALL ENDMILL R0.75")
 }

 :*:8-5::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-5. " formatted_angle "DEG CROSS BALL ENDMILL R0.75")
 }

 :*:8-6::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-6. " formatted_angle "DEG-1 CROSS BALL ENDMILL R0.75")
 }

 :*:8-7::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-7. " formatted_angle "DEG CROSS BALL ENDMILL R0.75")
 }

 :*:8-8::{
    formatted_angle := (get_current_angle() - 7) * 10
    Send("8-8. " formatted_angle "DEG-1 CROSS BALL ENDMILL R0.75")
 }

:*:2-1::{
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "2-1. FRONT TURNING-SHORT"
    } else {
        Send "2-1. FRONT TURNING"
    }
}

:*:5-1::{
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "5-1. FRONT TURNING"
    }
}

; ===== View Controls=====

a::{
    deg0()
}

s::{
    deg90()
}

d::{
    deg180()
}

f::{
    deg270()
}

c::{
    face()
}

v::{
    rear()
}

!WheelDown::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_10_degrees()
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
        decrement_10_degrees()
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

f14::{
    solid_view()
}

; Tilde(~) key
`::
f19::{
    wireframe_view()
}

; ===== Controls =====
t::{
    transformation_window()
}

+c::{
    circle_tool()
}

+a::{
    try{
        unsuppress_operation()
    }
}

+s::{
    try {
        suppress_operation()
    }
}

+r::{
    try {
        rebuild_operation()
    }
}

!x::
XButton1::{
    trim_tool()
}

+XButton2::{
    three_point_tool()
}

^e::{
    extrude_tool()
}

!e::{
    show_milling_tool()
}

CapsLock::{
    line_tool()
}

+Space::{
    toggle_simulation()
}

g::{
    if not WinExist(extrude_window_name){
        double_sided_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

b::{
    cut_with_border()
}

r::{
    distance_val := 6
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad1::{
    distance_val := 1
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad2::{
    distance_val := 2
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad3::{
    distance_val := 3
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad4::{
    distance_val := 4
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad5::{
    distance_val := 5
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad6::{
    distance_val := 6
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad7::{
    distance_val := 7
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad8::{
    distance_val := 8
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad9::{
    distance_val := 9
    if not WinActive(extrude_window_name){
        extrude_by(distance_val)
    } else if WinActive(extrude_window_name) and ControlGetText("Edit1", extrude_window_name) != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

e::{
    try {
        e_key_functionality := IniRead(prefs_file_path, "e_key_functionality", "value")
    } catch {
        IniWrite("Line and Border", prefs_file_path, "e_key_functionality", "value")
        e_key_functionality := "Line and Border"
    }

    if e_key_functionality = "Line and Border"{
        draw_straight_border()
    } else if e_key_functionality = "Line" {
        draw_straight_line()
    }
}

+q::{
    generate_path()
}

+w::{
    swap_path()
}

; G6 Key
f18::{
    save_file()
}

; ===== Auto-Complete Margins =====
+CapsLock::
XButton2::{
    global click_index
    global path_tool_active

    click_index := 0
    path_tool_active := true
    draw_path()
}

RButton::{
    global path_tool_active
    global click_index
    global initial_pos_x
    global initial_pos_y

    if(path_tool_active == true){
        ; Snap to original position and click to complete the path
        CoordMode("Mouse", "Screen")
        MouseMove(initial_pos_x, initial_pos_y, 0)
        Click()
        path_tool_active := false
        click_index := 0
        initial_pos_x := 0
        initial_pos_y := 0
    } else {
        SendInput("{RButton}")
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

; ===== Step-5 Window Navigation =====
	
; Degree 1 (Top Left)
!Numpad7::{
    click_client_pos(55, 140, "[5]DEG 경계소재 & 마진", true)
}

; Degree 2 (Top Right)
!Numpad9::{
    click_client_pos(170, 140, "[5]DEG 경계소재 & 마진", true)
}

; Degree 3 (Bottom Left)
!Numpad1::{
    click_client_pos(55, 190, "[5]DEG 경계소재 & 마진", true)
}

; Degree 4 (Bottom Right)

!Numpad3::{
    click_client_pos(170, 190, "[5]DEG 경계소재 & 마진", true)
}

; +90 Degree
!Numpad0::{
    click_client_pos(35, 235, "[5]DEG 경계소재 & 마진", true)
}

z::{
    click_client_pos(40, 8, "[5]DEG 경계소재 & 마진", true)
}

x::{
    click_client_pos(120, 8, "[5]DEG 경계소재 & 마진", true)
}

y::{
    if(WinExist("[5]DEG 경계소재 & 마진")){
        esprit_window_pid := WinGetPID("A")
        target_window_pid := WinGetPID("[5]DEG 경계소재 & 마진")
        
        if target_window_pid = esprit_window_pid{
            WinActivate("[5]DEG 경계소재 & 마진")
            CoordMode "Mouse", "Screen"
            MouseGetPos(&mouse_screen_posX, &mouse_screen_posY)
            CoordMode("Mouse", "Client")
            SetDefaultMouseSpeed(0)
            Click(180, 300)
            Send("^a-5")
            Click(170, 240)
            CoordMode "Mouse", "Screen"
            MouseMove mouse_screen_posX, mouse_screen_posY
        }
    }
}

; ===== Step-3 Window Navigation =====

; Degree 1
!1::{
    click_client_pos(32, 70, "Check Rough ML & Create Border Solid", true)
}

; Degree 2
!2::{
    click_client_pos(110, 70, "Check Rough ML & Create Border Solid", true)
}

; Degree 3
!3::{
    click_client_pos(188, 70, "Check Rough ML & Create Border Solid", true)
}

!a::{
    click_client_pos(23, 8, "Check Rough ML & Create Border Solid", true)
}

!s::{
    click_client_pos(75, 8, "Check Rough ML & Create Border Solid", true)
}

!d::{
    click_client_pos(117, 8, "Check Rough ML & Create Border Solid", true)
}

; +90 Degree
!q::{
    click_client_pos(55, 158, "Check Rough ML & Create Border Solid", true)
}

; Yellow Outline Checkbox
!w::{
    click_client_pos(8, 30, "Check Rough ML & Create Border Solid", true)
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

; ===== Text Placement Window Navigation =====
^Left::{
    translate_selection(-0.5, 0, 0)
}

!Up::{
    click_client_pos(136, 180, "Engraving Program Number Text", true)
}

!Down::{
    click_client_pos(190, 180, "Engraving Program Number Text", true)
}

!Left::{
    click_client_pos(130, 220, "Engraving Program Number Text", true)
}

!Right::{
    click_client_pos(190, 220, "Engraving Program Number Text", true)
}

+Left::{
    click_client_pos(130, 260, "Engraving Program Number Text", true)
}

+Right::{
    click_client_pos(190, 260, "Engraving Program Number Text", true)
}

; Create Text Projection Finishing Button
+NumpadEnter::
+Enter::{
    click_client_pos(98, 305, "Engraving Program Number Text", true)
}

; ===== Macro Buttons =====
#HotIf WinActive("ESPRIT")
^Numpad1::{
    try{
        macro_button_1()
    }
}

^Numpad2::{
    try{
        macro_button_2()
    }
}

^Numpad3::{
    try{
        macro_button_3()
    }
}

^Numpad4::{
    try{
        macro_button_4()
    }
}

^Numpad5::{
    try{
        macro_button_5()
    }
}

^Numpad6::{
    try{
        macro_button_text()
    }
}

#HotIf path_tool_active
~LButton::{
    global click_index
    global initial_pos_x
    global initial_pos_y

    if(click_index < 1){
        CoordMode("Mouse", "Screen")
        click_index += 1
        MouseGetPos(&initial_pos_x, &initial_pos_y)
    }
}

#HotIf (setMacroBar or setProjectManager)
LButton::{
    global 
    if(setMacroBar) {
        MouseGetPos(&posX, &posY, &window, &active_control)
        setMacroBarControl(active_control)
    }

    if(setProjectManager) {
        MouseGetPos(&posX, &posY, &window, &active_control)
        setProjectManagerControl(active_control)
    }
}