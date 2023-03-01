#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, force


#include %A_ScriptDir%\src\class.ahk
#include %A_ScriptDir%\src\views.ahk
#include %A_ScriptDir%\src\tools.ahk
#include %A_ScriptDir%\src\gui.ahk

^F13::Pause
return

 ;;; HOTSTRING
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

;======================     SELECTING DEGREES        =====================
f13::
DEG.deg0()
Return
f14::
DEG.deg90()
return
f15::
DEG.DEG180()
return
f16::
DEG.DEG270()
return
f17::
DEG.FACE()
return
f18::
DEG.REAR()
return



!WheelDown::
views.increment_10_degrees()
return

^WheelDown::
views.increment_90_degrees()
return

!WheelUp::
views.decrement_10_degrees()
return

^WheelUp::
views.decrement_90_degrees()
return

;; ========================= WIRE FRAME VIEW ==================================
XButton2::

sendinput, !a
return

XButton1::
sendinput, !s
return


;; ========================= SELECT TOOLS ==================================


!f13::
tools.line_tool_2()
return

!f14::
tools.line_tool()
return

!f15::
tools.trim_tool()()
return

!f16::
tools.circle_tool()
return

!f17::
tools.three_point_tool()
return

;;; ==========================  borders ==========================================


f19::
border_icon.flatdoubleside()
return

f20::
border_icon.slant_circle()
return

f23::
border_icon.center_border_3()
return

;; ========================= Macros ===========================================

; G3 Key
; Draw a straight line, 20 mm long, and extrude it
; Useful for quickly creating limitations when all you need is a straight line


f21::
SENDINPUT, X,0
SENDINPUT, {ENTER}
RETURN


f22::
BlockInput, On
tools.line_tool()
Click Left
Send 20{Enter}0{Enter}{Esc}
Click Left 2
Sleep, 100
border_icon.flatdoubleside()
BlockInput, Off
return

!F20::
SEND, ^{F9}
RETURN

;; ========================= END PROCESS / RELOAD ==============================

!F18::
Reload
return


!F19::
Loop
{
Process, Exist, esprit.exe
If !ErrorLevel
    Break
Process, Close, esprit.exe
}
return


;;========== START BINDS FROM !F21 ===============
