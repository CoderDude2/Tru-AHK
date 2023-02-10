#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, forced

#include %A_ScriptDir%\src\class.ahk
#include %A_ScriptDir%\src\views.ahk
#include %A_ScriptDir%\src\tools.ahk

#IfWinExist ahk_exe esprit.exe
#IfWinActive ahk_exe esprit.exe
^F13::Pause
return

;========================== SELECTING DEGREES ===================================
q::
Deg.deg0()
return

w::
Deg.deg90()
return

e::
Deg.deg180()
return

r::
Deg.deg270()
return

c::
Deg.face()
return

v::
Deg.rear()
return

!WheelDown::
increment_10_degrees()
return

+!WheelDown::
increment_90_degrees()
return

!WheelUp::
decrement_10_degrees()
return

+!WheelUp::
decrement_90_degrees()
return
; ========================== WIRE FRAME VIEW ====================================

wire_frame_is_active := false

!a::
a::
tools.solid_view()
wire_frame_is_active := false
return

!s::
s::
tools.wireframe_view()
wire_frame_is_active := true
return

; ==========================  Controls ==========================================

+c::
tools.circle_tool()
return

XButton2::
tools.line_tool()
return

+XButton2::
tools.draw_path()
return

^x::
XButton1::
tools.trim_tool()
return

^e::
tools.extrude_tool()
return

^+3::
tools.three_point_tool()
return

Space::
tools.toggle_simulation()
return

+Space::
tools.stop_simulation()
return

f13::
tools.generate_path()
return

f14::
tools.swap_path()
return

; ==========================  Borders ==========================================
f19::
border_icon.flatdoubleside()
return

f20::
border_icon.slant_circle()
return

;; ==========================

; Draw a straight line, 20 mm long, and extrude it
; Useful for quickly creating limitations when all you need is a straight line
f15::
BlockInput, On
tools.line_tool()
Click Left
Send 20{Enter}0{Enter}{Esc}
Click Left 2
Sleep, 100
border_icon.flatdoubleside()
BlockInput, Off
return

; This is for special cases when you have to enter "X,90"
f18::
BlockInput, On
Send X,90{Enter}
BlockInput, Off
return
