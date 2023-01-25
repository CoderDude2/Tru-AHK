#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, forced
#include class.ahk

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
Return
f14::
Deg.deg90()
return
f15::
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
;; ========================= WIRE FRAME VIEW ==================================

wire_frame_is_active := false


XButton2::
if(wire_frame_is_active == false){
 sendinput, !a
 wire_frame_is_active := true
 return
} else {
 sendinput, !s
 wire_frame_is_active := false
 return
}

; XButton1::



;;; ==========================  borders ==========================================


f19::
border_icon.flatdoubleside()
return

f20::
border_icon.slant_circle()
return


;; ==========================

f21::
SENDINPUT, X,0
SENDINPUT, {ENTER}
RETURN
