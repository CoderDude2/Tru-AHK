; On the isaac branch, I have a few differences with how the keyboard is layed out
; The keys G1-G6 have been remapped to F13-F18
; Win-Left is Delete
; CapsLock is Enter
; All other keys have been returned to their original state
;
; My goal is to have the autohotkey script manage context, rather than a keyboard profile.
; The reason being is for ease of updates.
; If we change the keyboard layout with a keyboard profile; we will have to go to each computer and re-import the respective keyboard profiles.
; If managed by the scripts themselves, there's no need for an extra step, and updates will be more seamless.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, forced

#include %A_ScriptDir%\src\class.ahk
#include %A_ScriptDir%\src\views.ahk
#include %A_ScriptDir%\src\tools.ahk

#IfWinExist ahk_exe DaouMessenger.exe
#IfWinActive ahk_exe DaouMessenger.exe
:*:$mf::I can take more files{!}

#IfWinExist ahk_exe esprit.exe
#IfWinActive ahk_exe esprit.exe

^F13::Pause
return
;========================== HOT STRINGS =========================================
:*:3-1::
formatted_angle := (views.get_current_angle() - 7) * 10
Send 3-1. ROUGH_ENDMILL_%formatted_angle%DEG
return

:*:3-2::
formatted_angle := (views.get_current_angle() - 7) * 10
Send 3-2. ROUGH_ENDMILL_%formatted_angle%DEG
return

:*:3-3::
formatted_angle := (views.get_current_angle() - 7) * 10
Send 3-3. ROUGH_ENDMILL_%formatted_angle%DEG
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
views.increment_10_degrees()
return

+!WheelDown::
views.increment_90_degrees()
return

!WheelUp::
views.decrement_10_degrees()
return

+!WheelUp::
views.decrement_90_degrees()
return
; ========================== WIRE FRAME VIEW ====================================
wireframe_is_active := false

!a::
a::
tools.solid_view()
wireframe_is_active := false
return

!s::
s::
tools.wireframe_view()
wireframe_is_active := true
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

+XButton1::
tools.three_point_tool()
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

; ========================== Borders ==========================================
g::
border_icon.flatdoubleside()
return

b::
border_icon.slant_circle()
return

;; ========================= Macros ===========================================

; G3 Key
; Draw a straight line, 20 mm long, and extrude it
; Useful for quickly creating limitations when all you need is a straight line
f15::
BlockInput, On
tools.line_tool()
Click, Left
Send, 20{Enter}0{Enter}{Esc}
Click, Left 2
Sleep, 100
border_icon.flatdoubleside()
BlockInput, Off
return

; G5 Key
; This is for special cases when you have to enter "X,90"
f17::
BlockInput, On
Send X,90{Enter}
BlockInput, Off
return

; G6 Key
f18::
tools.save_file()
return
