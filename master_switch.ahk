#Requires Autohotkey v2.0

#SingleInstance Force
SetWorkingDir A_ScriptDir

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\updater.ahk

; ===== Auto-Update =====
if(check_for_update(A_ScriptDir, "C:\Users\TruUser\Desktop\AHK_Update")){
    result := MsgBox("An update is available. Do you want to install it?",,"Y/N")
    if(result == "Yes"){
        update("C:\Users\TruUser\Desktop\AHK_Update")
    }
}

if(FileExist("old_master_switch.exe")){
    FileDelete("old_master_switch.exe")
}

if(IniRead("config.ini", "info", "show_changelog") == "True"){
    Run A_ScriptDir "\resources\changelog.pdf"
    IniWrite("False", "config.ini", "info", "show_changelog")
}

SetDefaultMouseSpeed 0

; ===== Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

#SuspendExempt
;G1
f13::{
    Reload
}

;Ctrl+G1
^f13::{
    Suspend
}
#SuspendExempt False

#HotIf WinActive("ahk_exe esprit.exe")
^f1::{
    Run A_ScriptDir "\resources\Autohotkey Keys v1.3.0.pdf"
}

f12::{
    while ProcessExist("esprit.exe"){
        ProcessClose("esprit.exe")
    }
}

f16::{
    Run "C:\Users\TruUser\Desktop\SelectSTLFile_R3\SelectSTLFile.exe"
}

; ===== Remappings =====
Space::Enter
; w::Delete

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

; ===== View Controls=====

p::{
    MsgBox "This is a new update!"
}

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

^t::{
    update_angle_deg(200)
}

g::{
    double_sided_border()
}

b::{
    cut_with_border()
}

r::{
    center_border_3()
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

; G5 Key
f17::{
    BlockInput true
    Send("X,90{Enter}")
    BlockInput false
}

f18::{
    save_file()
}

; ===== Auto-Complete Margins =====
~Escape::{
    global click_index
    global path_tool_active
    
    click_index := 0
    path_tool_active := false

    stop_simulation()
}

+CapsLock::
XButton2::{
    global click_index
    global path_tool_active

    click_index := 0
    path_tool_active := true
    draw_path()
}

~LButton::{
    global click_index
    global path_tool_active
    global initial_pos_x
    global initial_pos_y


    if(path_tool_active == true && click_index < 1){
        CoordMode("Mouse", "Screen")
        click_index += 1
        MouseGetPos(&initial_pos_x, &initial_pos_y)
    }
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
!Numpad7::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 55, 140
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 55, 140
        }
    }
}

!Numpad9::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 170, 140
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 170, 140
        }
    }
}

!Numpad1::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 55, 190
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 55, 190
        }
    }
}

!Numpad3::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 170, 190
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 170, 190
        }
    }
}

!Numpad0::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 35, 235
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 35, 235
        }
    }
}

z::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 40, 8
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 40, 8
        }
    }
}

x::{
    CoordMode "Mouse", "Client"
    if(WinExist("[5]DEG 경계소재 & 마진")){
        if(WinActive("[5]DEG 경계소재 & 마진")){
            Click 120, 8
        } else {
            WinActivate("[5]DEG 경계소재 & 마진")
            Click 120, 8
        }
    }
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
!1::{
    CoordMode "Mouse", "Client"
    if(WinExist("Check Rough ML & Create Border Solid")){
        if(WinActive("Check Rough ML & Create Border Solid")){
            Click 32, 70
        } else {
            WinActivate("Check Rough ML & Create Border Solid")
            Click 32, 70
        }
    }
}

!2::{
    CoordMode "Mouse", "Client"
    if(WinExist("Check Rough ML & Create Border Solid")){
        if(WinActive("Check Rough ML & Create Border Solid")){
            Click 110, 70
        } else {
            WinActivate("Check Rough ML & Create Border Solid")
            Click 110, 70
        }
    }
}

!q::{
    CoordMode "Mouse", "Client"
    if(WinExist("Check Rough ML & Create Border Solid")){
        if(WinActive("Check Rough ML & Create Border Solid")){
            Click 55, 158
        } else {
            WinActivate("Check Rough ML & Create Border Solid")
            Click 55, 158
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

; ===== Macro Buttons =====
#HotIf WinActive("ESPRIT")
^Numpad1::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+20, y+14
}

^Numpad2::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+45, y+14
}

^Numpad3::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+68, y+14
}

^Numpad4::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+90, y+14
}

^Numpad5::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+115, y+14
}

^Numpad6::{
    CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, "Afx:00400000:8:00010003:00000010:000000001" 
    Click x+135, y+14
}