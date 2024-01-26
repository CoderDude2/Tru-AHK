#SingleInstance Force
SetWorkingDir A_ScriptDir

#Include "%A_ScriptDir%\Lib\views.ahk"
#Include %A_ScriptDir%\Lib\commands.ahk

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