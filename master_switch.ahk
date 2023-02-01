#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, forced
#include class.ahk
#include tools.ahk

#IfWinExist ahk_exe esprit.exe
#IfWinActive ahk_exe esprit.exe
^F13::Pause
return

;;; HOTSTRING
; :*:3-1::3-1. ROUGH_ENDMILL_0DEG
; :*:3-2::3-2. ROUGH_ENDMILL_120DEG
; :*:3-3::3-3. ROUGH_ENDMILL_240DEG

;======================     SELECTING DEGREES        =====================
f13::
Deg.deg0()
return
f14::
Deg.deg90()
return
e::
Deg.deg180()
return
f16::
Deg.deg270()
return
c::
Deg.face()
return
v::
Deg.rear()
return
; ========================= WIRE FRAME VIEW ==================================

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

; ==========================  Tools ==========================================

; Circle Tool
+c::
tools.circle_tool()
return

; Line Tool
+f18::
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

; ==========================  borders ==========================================
f19::
border_icon.flatdoubleside()
return

f20::
border_icon.slant_circle()
return

;; ==========================

f21::
tools.line_tool()
Click Left
Send 20{Enter}0{Enter}{Esc}
Click Left 2
Sleep, 100
border_icon.flatdoubleside()
return
