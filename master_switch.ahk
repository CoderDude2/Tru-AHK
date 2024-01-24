#SingleInstance Force
SetWorkingDir A_ScriptDir

#Include "%A_ScriptDir%/Lib/views.ahk"
#Include %A_ScriptDir%\Lib\commands.ahk

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

; ===== Controls =====
t::{
    commands.transformation_window()
}

+c::{
    commands.circle_tool()
}

+a::{
    commands.unsuppress_operation()
}

+s::{
    commands.suppress_operation()
}

+r::{
    commands.rebuild_operation()
}

XButton1::{
    commands.trim_tool()
}

^e::{
    commands.extrude_tool()
}

CapsLock::{
    commands.line_tool()
}

+Space::{
    commands.toggle_simulation()
}