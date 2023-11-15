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

saved_values := load_metadata(log_path)
global text_x := saved_values[1]
global text_x_asc := saved_values[2]
global process_last := saved_values[3]
global process_last_asc := saved_values[4]

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

+c::
tools.circle_tool()
return

+a::
tools.unsuppress_operation()
return

+s::
tools.suppress_operation()
return


+r::
tools.rebuild_operation()
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

+1::
translate_selection(0,0.25,0)
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
tools.line_tool()
Click, Left
Send, 20{Enter}0{Enter}{Esc}
Click, Left 2
Sleep, 100
border_icon.flatdoubleside()
BlockInput, Off
Send, {Enter}
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

; ========================= Auto-Fill TLOC cases ===========================================
+t::
WinWaitActive ahk_exe esprit.exe
WinGetTitle, esprit_title, A
if(get_case_type(esprit_title) = "TLOC"){
    FoundPos := RegExMatch(esprit_title, "O)#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", SubPat)
    working_degree := SubPat.Value(1)
    rotate_stl_by := SubPat.Value(2)
    y_pos := SubPat.Value(3)
    z_pos := SubPat.Value(4)
    x_pos := SubPat.Value(5)

    views.update_angle_deg(working_degree)
    Sleep 50
    rotate_selection(rotate_stl_by)
    Sleep 50
    translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
    Sleep 50
    rotate_selection(Mod(working_degree, 10), True)

} else if(get_case_type(esprit_title) = "AOT"){
    FoundPos := RegExMatch(esprit_title, "O)#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", SubPat)
    working_degree := SubPat.Value(1)
    rotate_stl_by := SubPat.Value(2)
    y_pos := SubPat.Value(3)
    z_pos := SubPat.Value(4)
    x_pos := SubPat.Value(5)

    views.update_angle_deg(working_degree)
    Sleep 50
    translate_selection(20, 0, 0)
    Sleep 50
    rotate_selection(rotate_stl_by)
    Sleep 50
    translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
    Sleep 50
    rotate_selection(Mod(working_degree, 10), True)
}
return
;========================== Text X and PL Tracker =============================

+x::
saved_values := load_metadata(log_path)
text_x := saved_values[1]
text_x_asc := saved_values[2]
process_last := saved_values[3]
process_last_asc := saved_values[4]
add_to_text_x()
save_metadata(text_x, text_x_asc, process_last, process_last_asc, log_path)
return

+z::
saved_values := load_metadata(log_path)
text_x := saved_values[1]
text_x_asc := saved_values[2]
process_last := saved_values[3]
process_last_asc := saved_values[4]
add_to_process_last()
save_metadata(text_x, text_x_asc, process_last, process_last_asc, log_path)
return

add_to_text_x(){
    WinGetTitle, esprit_title, A
    id:=get_case_id(esprit_title)
    if(id = ""){
        return
    }
    
    if(get_case_type(esprit_title) = "ASC"){
        for key, value in text_x_asc
            if(value = id){
                text_x_asc.RemoveAt(key)
                return
            }
        text_x_asc.Push(id)
    } else {
        for key, value in text_x
            if(value = id){
                text_x.RemoveAt(key)
                return
            }
        text_x.Push(id)
    }
}

add_to_process_last(){
    WinGetTitle, esprit_title, A
    id:=get_case_id(esprit_title)
    if(id = ""){
        return
    }
    if(get_case_type(esprit_title) = "ASC"){
        for key, value in process_last_asc
            if(value = id){
                process_last_asc.RemoveAt(key)
                return
            }
        process_last_asc.Push(id)
    } else {
        for key, value in process_last
            if(value = id){
                process_last.RemoveAt(key)
                return
            }
        process_last.Push(id)
    }
}

; ========================= END PROCESS / RELOAD ==============================

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
