#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, forced

#Include %A_ScriptDir%\Lib\class.ahk
#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\tools.ahk
#Include %A_ScriptDir%\Lib\transformations.ahk

#IfWinExist ahk_exe esprit.exe
#IfWinActive ahk_exe esprit.exe

^f13::Suspend

;========================== REMAPPINGS ===========================================
Space::Enter
w::Delete

;========================== VARIABLES ===========================================

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
a::
Deg.deg0()
return

s::
Deg.deg90()
return

d::
Deg.deg180()
return

f::
Deg.deg270()
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
; ========================== WIRE FRAME VIEW ====================================
wireframe_is_active := false

; G2 Key
f14::
tools.solid_view()
wireframe_is_active := false
return

; Tilde Key
f19::
tools.wireframe_view()
wireframe_is_active := true
return

; ==========================  Controls ==========================================

t::
tools.transformation_window()
return

t::
tools.transformation_window()
return


XButton1::
tools.trim_tool()
return

^e::
tools.extrude_tool()
return

CapsLock::
tools.line_tool()
return

+Space::
tools.toggle_simulation()
return

; ========================== Borders ==========================================
g::
border_icon.flatdoubleside()
return

b::
border_icon.slant_circle()
return

r::
border_icon.center_border_3()
return

;; ========================= Macros ===========================================

; Draw a straight line, 20 mm long, and extrude it
; Useful for quickly creating limitations when all you need is a straight line
e::
BlockInput, On
;list_search.layer("도형", "combobox5", "ESPRIT")  ;;SET LAYER TO LINES ONLY, SO YOU CAN DRAW LINES ON TOP OF MODELS
;SLEEP, 50
;PostMessage, 0x111, 6384 , , , ESPRIT ;; OPTION "INT"  (BOTTOM RIGHT CORNER)  , THIS ALLOWS LINES TO BE DRAWN ON X/Y AXIS
sleep, 20
tools.line_tool()
Click, Left
Send, 20{Enter}0{Enter}{Esc}
Click, Left 2
Sleep, 100
border_icon.flatdoubleside()
sendinput, {enter}
SLEEP, 50
;list_search.layer("모두", "combobox5", "ESPRIT") ;; SET LAYER BACK TO EVERYTHING
;PostMessage, 0x111, 6384 , , , ESPRIT ;; TURN OFF "INT" SETTING

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

; ========================= Auto-Complete Margins ===========================================

initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active = false

~Escape::
tools.stop_simulation()
path_tool_active = false
click_index := 0
return

XButton2::
click_index := 0
tools.draw_path()
path_tool_active := true
return

~LButton::
CoordMode, Mouse, Screen
if(path_tool_active = true){
    click_index++
    ; Store the coordinates of the first click
    if(click_index = 1){
        MouseGetPos, initial_pos_x, initial_pos_y
    }
}
return

RButton::
    CoordMode, Mouse, Screen
    if(path_tool_active = true){
        ; Snap to original position and click to complete the path
        MouseMove, initial_pos_x, initial_pos_y
        Click
        path_tool_active := false
        click_index := 0
        initial_pos_x := 0
        initial_pos_y := 0
    } else {
        SendInput, {RButton}
    }
return

;; ========================= END PROCESS / RELOAD ==============================

f13::
Reload
return

f4::
Send, ^{F9}
return

f12:: ;; this close will prevent software from slowing down over time
Loop
{
Process, Exist, esprit.exe
If !ErrorLevel
    Break
Process, Close, esprit.exe
}
return