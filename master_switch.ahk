#Requires Autohotkey v2.0

#SingleInstance Force
; DetectHiddenWindows true
SetWorkingDir A_ScriptDir

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\load_values.ahk
#Include %A_ScriptDir%\Lib\save_values.ahk

; ===== Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

log_path := "C:\Users\TruUser\Desktop"

passes := 5

saved_values := load_values(log_path)
if(saved_values != ""){
    text_x := saved_values[1]
    text_x_asc := saved_values[2]
    process_last := saved_values[3]
    process_last_asc := saved_values[4]
}

#HotIf WinActive("ahk_exe esprit.exe")

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

; G4
f16::{
    DetectHiddenWindows true
    Run "C:\Users\TruUser\Desktop\SelectSTLFile_R3\SelectSTLFile.exe"
    WinWait("CAM Automation")
    WinActivate("CAM Automation")
    DetectHiddenWindows true
}

f12::{
    ProcessExist("esprit.exe")
    pid := WinGetPID("A")
    ProcessClose(pid)
}


; ===== Remappings =====
Space::Enter
w::Delete

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
    if(WinActive("ESPRIT")){
        increment_10_degrees()
    }
}

+!WheelDown::{
    if(WinActive("ESPRIT")){   
        increment_90_degrees()
    }
}

!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_10_degrees()
    }
}

+!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_90_degrees()  
    }
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

+XButton1::{
    three_point_tool()
}

^e::{
    extrude_tool()
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
    center_border_3()
}

e::{
    draw_straight_border()
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
    global passes

    passes := 5
    
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

; ===== Text X =====

; ===== More Keys =====
y::{
    CoordMode("Mouse", "Screen")
    MouseMove(1700, 370, 0)
    Click(2)
    Send("{Delete}-5")
    MouseMove(1705, 315, 0)
    Click(1)
}

AppsKey::{
    BlockInput("MouseMove")
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("1600 220")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation

    ; 2nd Margin
    Click("1700 222")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation

    ; 3rd Margin
    Click("1600 260")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
}

+AppsKey::{
    BlockInput("MouseMove")
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("1600 220")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation

    ; 2nd Margin
    Click("1700 222")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation

    ; 3rd Margin
    Click("1600 260")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation

    ; 4th Margin
    Click("1700 275")
    Click("1700, 330, 3") ; Click the Text box and enter 0.025
    Send("0.025")
    Click("1660, 370") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
}

q::{
    generate_path()
}

w::{
    swap_path()
}

; Macro 1
^Numpad1::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("25 105")
}

; Macro 2
^Numpad2::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("45 105")
}

; Macro 3
^Numpad3::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("68 105")
}

; Macro 4
^Numpad4::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("90 105")
}

; Macro 5
^Numpad5::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("111 105")
}

; Macro 6
^Numpad6::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Client")
    Click("137 105")
}

!1::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1584 145")
}

!2::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1657 143")
}

!q::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1605 233")
}

!a::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1580 83")
}

!s::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1630 83")
}

!d::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1670 83")
}

!e::{
    show_milling_tool()
}

; G3 Key
f15::{
    WinMove(-500, 275, , , "esprit", "&Yes")
}

; Auto-Start
+q::{
    WinWaitActive("ahk_exe esprit.exe")
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) == "ASC"){
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        Click("25 105")
        Sleep(50)
        Send("{Enter}")
        Sleep(50)
        Send("{Enter}")
        Sleep(50)
        Send("{Enter}")
        Sleep(50)
        Send("{Enter}")
        WinWaitActive("CAM Automation - To transform the STL")
        Send("X,90{Enter}")
        Sleep(50)
        WinWaitActive("STL Rotate")
        wireframe_view()
        deg0()

        result := MsgBox("Is the connection correct? Is the T showing?",,"Y/N 0x1000")
        if(result == "No"){
            return
        } else {
            WinActivate("STL Rotate")
            WinWaitActive("STL Rotate")
            Click("71 143")
            Sleep(50)
            Send("{Enter}")
            WinWaitActive("CAM Automation - For Turning Profile")
            Send("{Enter}")
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == false){
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        Click("25 105")
        Sleep(50)
        Send("{Enter}")
        Sleep(50)
        Send("{Enter}")
        WinWaitActive("Direction Check")
        Send("{Enter}")
        WinWaitActive("STL Rotate")
        deg0()

        result := MsgBox("Is the connection correct?",,"Y/N 0x1000")
        if(result == "No"){
            return
        } else {
            WinActivate("STL Rotate")
            WinWaitActive("STL Rotate")
            Click("71 117")
            Sleep(50)
            Send("{Enter}")
            WinWaitActive("CAM Automation - For Turning Profile")
            Send("{Enter}")
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == true){
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        Click("25 105")
        Sleep(50)
        Send("{Enter}")
        Sleep(50)
        Send("{Enter}")
        WinWaitActive("STL Rotate")
        deg0()

        result := MsgBox("Is the connection correct?",,"Y/N 0x1000")
        if(result == "No"){
            return
        } else {
            WinActivate("STL Rotate")
            WinWaitActive("STL Rotate")
            Click("71 117")
            Sleep(50)
            Send("{Enter}")
            WinWaitActive("CAM Automation - For Turning Profile")
            Send("{Enter}")
        }
    }
}

^Up::{
    global passes
    passes += 1
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1582 144")
    Sleep(20)
    Click("1703 317")
    Sleep(20)
    Send("^a" passes "{Enter}")
    Send("^a" (-1*passes) "{Enter}")
    Click("1662 393")
    Sleep(20)
    Click("1658 144")
    Sleep(20)
    Click("1703 317")
    Sleep(20)
    Send("^a" passes "{Enter}")
    Send("^a" (-1*passes) "{Enter}")
    Click("1662 393")
    Sleep(20)
    Click("1605 233")
}

^Down::{
    global passes
    passes -= 1
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    Click("1582 144")
    Sleep(20)
    Click("1703 317")
    Sleep(20)
    Send("^a" passes "{Enter}")
    Send("^a" (-1*passes) "{Enter}")
    Click("1662 393")
    Sleep(20)
    Click("1658 144")
    Sleep(20)
    Click("1703 317")
    Sleep(20)
    Send("^a" passes "{Enter}")
    Send("^a" (-1*passes) "{Enter}")
    Click("1662 393")
    Sleep(20)
    Click("1605 233")
}