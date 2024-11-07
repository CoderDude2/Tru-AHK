#Requires Autohotkey v2.0

#SingleInstance Force
SetWorkingDir A_ScriptDir

; ===== Global Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

if(!DirExist("C:\Users\TruUser\AppData\Roaming\tru-ahk\")){
    DirCreate "C:\Users\TruUser\AppData\Roaming\tru-ahk\"
}

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\updater.ahk
#Include %A_ScriptDir%\Lib\dashboard.ahk

remote_path := IniRead("config.ini", "info", "remote_path")
if(check_for_update(A_ScriptDir, remote_path)){
    result := MsgBox("An update is available. Do you want to install it?",,"Y/N")
    if(result == "Yes"){
        update(remote_path)
    }
}

if(FileExist("old_master_switch.exe")){
    FileDelete("old_master_switch.exe")
}

if(IniRead(A_ScriptDir "\config.ini", "info", "show_changelog") == "True"){
    Run A_ScriptDir "\resources\changelog.pdf"
    IniWrite("False", A_ScriptDir "\config.ini", "info", "show_changelog")
}

prefs_file_path := IniRead(A_ScriptDir "\config.ini", "info", "user_preferences")
if(!FileExist(prefs_file_path)){
    IniWrite("All Instances", prefs_file_path, "f12_mode", "value")
    IniWrite(true, prefs_file_path, "w_as_delete", "value")

    IniWrite("", prefs_file_path, "macro_bar_control", "control")

    IniWrite("", prefs_file_path, "project_manager_control", "control")
    IniWrite(True, prefs_file_path, "project_manager_control", "is_attached")
}

; ===== Dashboard Menu =====
A_TrayMenu.Add()
A_TrayMenu.Add("Open Dashboard", open_dashboard)

SetDefaultMouseSpeed 0

#SuspendExempt
;G1
f13::{
    Reload
}

;Ctrl+G1
^f13::{
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

f12::{
    mode := IniRead(prefs_file_path, "f12_mode", "value")

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

; G5 Key
f17::{
    Run "C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe"
}

#SuspendExempt False

#HotIf WinActive("ahk_exe esprit.exe")

^f1::{
    open_help()
}

^f2::{
    open_changelog()   
}

f16::{
    Run "C:\Users\TruUser\Desktop\SelectSTLFile_R3\SelectSTLFile.exe"
}

; ===== Remappings =====
Space::Enter
w::{
    if(IniRead(prefs_file_path, "w_as_delete", "value") == 1){
        Send("{Delete}")
    }
}

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
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
    increment_10_degrees()
}

+!WheelDown::{ 
    increment_90_degrees()
}

!WheelUp::{
    decrement_10_degrees()
}

+!WheelUp::{
    decrement_90_degrees()  
}

f14::{
    solid_view()
}

; Tilde(~) key
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
    double_sided_border()
}

b::{
    cut_with_border()
}

r::{
    extrude_by(6)
}

r & Numpad1::
r & 1::{
    extrude_by(1)
}

r & Numpad2::
r & 2::{
    extrude_by(2)
}

r & Numpad3::
r & 3::{
    extrude_by(3)
}

r & Numpad4::
r & 4::{
    extrude_by(4)
}

r & Numpad5::
r & 5::{
    extrude_by(5)
}

r & Numpad6::
r & 6::{
    extrude_by(6)
}

r & Numpad7::
r & 7::{
    extrude_by(7)
}

r & Numpad8::
r & 8::{
    extrude_by(8)
}

r & Numpad9::
r & 9::{
    extrude_by(9)
}

e::{
    draw_straight_border()
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
        WinActivate("[5]DEG 경계소재 & 마진")
        CoordMode("Mouse", "Client")
        SetDefaultMouseSpeed(0)
        Click(180, 300)
        Send("^a-5")
        Click(170, 240)
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

; +90 Degree
!q::{
    click_client_pos(55, 158, "Check Rough ML & Create Border Solid", true)
}

; Yellow Outline Checkbox
!w::{
    click_client_pos(8, 30, "Check Rough ML & Create Border Solid", true)
}

; Tab 1
!a::{
    click_client_pos(20, 4, "Check Rough ML & Create Border Solid", true)
}

; Tab 2
!s::{
    click_client_pos(70, 4, "Check Rough ML & Create Border Solid", true)
}

; Tab 3
!d::{
    click_client_pos(120, 4, "Check Rough ML & Create Border Solid", true)
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

!Up::{
    click_client_pos(136, 180, "Engraving Program Number Text", false)
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