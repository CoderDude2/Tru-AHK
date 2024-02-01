#Requires Autohotkey v2.0

#SingleInstance Force
SetWorkingDir A_ScriptDir

#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\load_values.ahk
#Include %A_ScriptDir%\Lib\save_values.ahk

; ===== Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

log_path := "C:\Users\TruUser\Desktop"

saved_values := load_values(log_path)
if(saved_values != ""){
    text_x := saved_values[1]
    text_x_asc := saved_values[2]
    process_last := saved_values[3]
    process_last_asc := saved_values[4]
}

#HotIf WinActive("ahk_exe esprit.exe")

#SuspendExempt
;G1
f13::{
    Reload
}

;Ctrl+G1
^f13::{
    Suspend
}
#SuspendExempt False

f16::{
    Run "C:\Users\TruUser\Desktop\SelectSTLFile_R3\SelectSTLFile.exe"
}

; ===== Remappings =====
Space::Enter
w::Delete

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := (get_current_angle() - 7) * 10
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
    if(WinActive("ESPRIT")){
        increment_10_degrees()
    }
}

+!WheelDown::{
    if(WinActive("ESPRIT")){   
        increment_90_degrees()
    }
}

!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_10_degrees()
    }
}

+!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_90_degrees()  
    }
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
    global click_index
    global path_tool_active
    
    click_index := 0
    path_tool_active := false

    stop_simulation()
}

XButton2::{
    global click_index
    global path_tool_active

    click_index := 0
    path_tool_active := true
    draw_path()
}

~LButton::{
    global click_index
    global path_tool_active
    global initial_pos_x
    global initial_pos_y


    if(path_tool_active == true && click_index < 1){
        CoordMode("Mouse", "Screen")
        click_index += 1
        MouseGetPos(&initial_pos_x, &initial_pos_y)
    }
}

RButton::{
    global path_tool_active
    global click_index
    global initial_pos_x
    global initial_pos_y

    if(path_tool_active == true){
        ; Snap to original position and click to complete the path
        CoordMode("Mouse", "Screen")
        MouseMove(initial_pos_x, initial_pos_y, 0)
        Click()
        path_tool_active := false
        click_index := 0
        initial_pos_x := 0
        initial_pos_y := 0
    } else {
        SendInput("{RButton}")
    }
}

; ===== Auto-Fill TLOC cases =====
+t::{
WinWaitActive("ahk_exe esprit.exe")
esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) = "TLOC"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)

    } else if(get_case_type(esprit_title) = "AOT"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        translate_selection(20, 0, 0)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)
    }
}

; ===== Text-X and Process Last Tracking =====
add_to_text_x(){
    global text_x
    global text_x_asc
    global process_last
    global process_last_asc
    esprit_title := WinGetTitle("A")
    id:=get_case_id(esprit_title)
    if(id = ""){
        return
    }

    if(get_case_type(esprit_title) = "ASC"){
        for key, value in text_x_asc
            if(value = id){
                text_x_asc.RemoveAt(key)
                MsgBox(id " removed from Text X.")
                return
            }
        text_x_asc.Push(id)
        MsgBox(id " added to Text X.")
    } else {
        for key, value in text_x
            if(value = id){
                text_x.RemoveAt(key)
                MsgBox(id " removed from Text X.")
                return
            }
        text_x.Push(id)
        MsgBox(id " added to Text X.")
    }    
}

add_to_process_last(){
    global text_x
    global text_x_asc
    global process_last
    global process_last_asc
    esprit_title := WinGetTitle("A")
    id:=get_case_id(esprit_title)
    if(id = ""){
        return
    }

    if(get_case_type(esprit_title) = "ASC"){
        for key, value in process_last_asc
            if(value = id){
                process_last_asc.RemoveAt(key)
                MsgBox(id " removed from Process Last.")
                return
            }
        process_last_asc.Push(id)
        MsgBox(id " added to Process Last.")
    } else {
        for key, value in process_last
            if(value = id){
                process_last.RemoveAt(key)
                MsgBox(id " removed from Process Last.")
                return
            }
        process_last.Push(id)
        MsgBox(id " added to Process Last.")
    }
}

+x::{
    global text_x
    global text_x_asc
    global process_last
    global process_last_asc
    saved_values := load_values(log_path)
    text_x := saved_values[1]
    text_x_asc := saved_values[2]
    process_last := saved_values[3]
    process_last_asc := saved_values[4]
    add_to_text_x()
    save_values(text_x, text_x_asc, process_last, process_last_asc, log_path)
}

+z::{
    global text_x
    global text_x_asc
    global process_last
    global process_last_asc
    saved_values := load_values(log_path)
    text_x := saved_values[1]
    text_x_asc := saved_values[2]
    process_last := saved_values[3]
    process_last_asc := saved_values[4]
    add_to_process_last()
    save_values(text_x, text_x_asc, process_last, process_last_asc, log_path)
}
