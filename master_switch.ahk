#SingleInstance Force
SetWorkingDir A_ScriptDir

#Include "%A_ScriptDir%\Lib\views.ahk"
#Include %A_ScriptDir%\Lib\commands.ahk

; ===== Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

#HotIf WinActive("ahk_exe esprit.exe")

^r::Reload

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := 0
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := 90
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := 180
   Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
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
    unsuppress_operation()
}

+s::{
    suppress_operation()
}

+r::{
    rebuild_operation()
}

XButton1::{
    trim_tool()
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
    stop_simulation()
    global path_tool_active := false
    global click_index := 0
}

XButton2::{
    global click_index := 0
    draw_path()
    global path_tool_active := true
}

~LButton::{
    ; MsgBox click_index
    CoordMode("Mouse", "Screen")
    if(path_tool_active == true){
        global click_index := click_index + 1
        ; Store the coordinates of the first click
        if(click_index == 1){
            MouseGetPos(&initial_pos_x, &initial_pos_y)
        }
    }
}

RButton::{
    CoordMode("Mouse", "Screen")
    if(path_tool_active == true){
        ; Snap to original position and click to complete the path
        MouseMove(initial_pos_x, initial_pos_y)
        Click()
        global path_tool_active := false
        global click_index := 0
        global initial_pos_x := 0
        global initial_pos_y := 0
    } else {
        SendInput("{RButton}")
    }
}
    