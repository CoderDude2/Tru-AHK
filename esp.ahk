#Requires AutoHotkey v2.0
#SingleInstance Off

SetDefaultMouseSpeed(0)

#Include Lib\views.ahk
#Include Lib\util.ahk
#Include Lib\nav.ahk


STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"


esp_pid := A_Args[1]

suspend_event_num := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
OnMessage(suspend_event_num, SuspendScript)

SuspendScript(wParam, lParam, msg, hwnd){
    Suspend(-1)
}

step_5_tab := 1
file_map := Map()

SetTimer(update_file_map, 500)


update_file_map(){
    Loop Files, STL_FILE_PATH "\*", "F"{
        if not file_map.Has(A_LoopFileName){
            file_map[A_LoopFileName] := false
        } 
    }        
}

check_window_exist(){
    if not ProcessExist(esp_pid) {
        ExitApp
    }
}

SetTimer(check_window_exist, 100)

esp_id := WinWaitTitleWithPID(esp_pid, "ESPRIT - ")

generate_nc(){
	PostMessage 0x111, 3323, , , "ahk_id" esp_id
}

extrude_tool(){
	PostMessage 0x111, 3130 , , , "ahk_id" esp_id
}

circle_tool(){
	PostMessage 0x111, 3005 , , , "ahk_id" esp_id
}

line_tool(){
	PostMessage 0x111, 3018 , , , "ahk_id" esp_id
}

line_tool_2(){
	PostMessage 0x111, 3019 , , , "ahk_id" esp_id
}

trim_tool(){
	PostMessage 0x111, 3033 , , , "ahk_id" esp_id
}

three_point_tool(){
	PostMessage 0x111, 3004 , , , "ahk_id" esp_id
}

wireframe_view(){
	PostMessage 0x111, 6130 , , , "ahk_id" esp_id
}

solid_view(){
	PostMessage 0x111, 6135 , , , "ahk_id" esp_id
}

generate_path(){
	PostMessage 0x111, 3054 , , , "ahk_id" esp_id
}

swap_path(){
	PostMessage 0x111, 3145 , , , "ahk_id" esp_id
}

toggle_simulation(){
	PostMessage 0x111, 6268 , , , "ahk_id" esp_id
}

stop_simulation(){
	PostMessage 0x111, 6276 , , , "ahk_id" esp_id
}

save_file(){
	PostMessage 0x111, 57603 , , , "ahk_id" esp_id
}

open_file(){
	PostMessage 0x111, 57601 , , , "ahk_id" esp_id
}

transformation_window(){
	PostMessage 0x111, 57634 , , , "ahk_id" esp_id
}

show_milling_tool(){
	PostMessage 0x111, 6278 , , , "ahk_id" esp_id
}

highlight_tool(){
	PostMessage 0x111, 6156 , , "msctls_statusbar322", "ahk_id" esp_id
}

draw_path(command){
    static click_index
    static path_tool_active := false
    static initial_pos_x, initial_pos_y
    switch command{
        case "start":
			if path_tool_active {
				Send("{Escape}")
			}
			Sleep(50)
            click_index := 0
            path_tool_active := true
            PostMessage 0x111, 3057, , , "ahk_id" esp_id 
        case "click":
			if path_tool_active{
				if click_index < 1{
					CoordMode("Mouse", "Screen")
					MouseGetPos(&initial_pos_x, &initial_pos_y)
					click_index += 1
				} else {
					click_index += 1
				}
			}
        case "cancel":
            path_tool_active := false
            click_index := 0
            initial_pos_x := 0
            initial_pos_y := 0
        case "complete":
             if path_tool_active{
				if click_index > 2 {
					CoordMode("Mouse", "Screen")
					MouseMove(initial_pos_x, initial_pos_y, 0)
					Click()
					path_tool_active := false
					click_index := 0
					initial_pos_x := 0
					initial_pos_y := 0
				} else {
					MsgBox("Must have 3 or more points to complete a path.")
				}
             } else {
                Send("{RButton}")
             }
    }
}

unsuppress_operation(){
    _id := WinExistTitleWithPID(esp_pid, "Project Manager")
    if _id {
        PostMessage 0x111, 32792 , , "SysTreeView321", "ahk_id" _id
    }
}

suppress_operation(){
    _id := WinExistTitleWithPID(esp_pid, "Project Manager")
    if _id {
	    PostMessage 0x111, 32770 , , "SysTreeView321", "ahk_id" _id
    }
}

rebuild_operation(){
    _id := WinExistTitleWithPID(esp_pid, "Project Manager")
    if _id {
	    PostMessage 0x111, 32768 , , "SysTreeView321", "ahk_id" _id
    }
}

translate_selection(x := 0, y := 0, z := 0){
    WinActivate("ahk_id" esp_id)
    transformation_window()
    _id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "Transformation Type")

    ControlChooseString("Translate","ComboBox1","ahk_id" _id)
    ControlSetChecked(1,"Button7","ahk_id" _id)

    ControlSetText(Round(x, 4), "Edit2", "ahk_id" _id)
    ControlSetText(Round(y, 4), "Edit3", "ahk_id" _id)
    ControlSetText(Round(z, 4), "Edit4", "ahk_id" _id)

    Send("{Enter}")
}

translate_selection_click(){
	WinActivate("ahk_id" esp_id)
    transformation_window()
    _id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "Transformation Type")

	ControlChooseString("Translate","ComboBox1","ahk_id" _id)
	ControlSetChecked(1,"Button8","ahk_id" _id)
	Send("{Enter}")
}

translate(){
	WinActivate("ahk_id" esp_id)
    transformation_window()
	_id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "Transformation Type")

    ControlChooseString("Translate","ComboBox1","ahk_id" _id)
    ControlSetChecked(1,"Button7","ahk_id" _id)
}

rotate_selection(degrees, update_on_click:=False){
    WinActivate("ahk_id" esp_id)
    transformation_window()
    _id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "Transformation Type")

    ControlChooseString("Rotate","ComboBox1","ahk_id" _id)
    ControlSetText(Round(degrees, 4), "Edit6", "ahk_id" _id)

    if(update_on_click = True){
        ControlSetChecked(0,"Button10","ahk_id" _id)
    } else {
        ControlSetChecked(1,"Button10","ahk_id" _id)
    }

    Send("{Enter}")
}

scale_selection(scale){
    WinActivate("ahk_id" esp_id)
    transformation_window()
    _id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "Transformation Type")

    ControlChooseString("Scale","ComboBox1","ahk_class #32770")
    ControlSetText(Round(scale, 4), "Edit8", "ahk_class #32770")

    Send("{Enter}")
}

double_sided_border() {
	PostMessage(0x111, 3130, , , "ahk_id" esp_id)
    extrude_id := WinWaitTitleWithPID(esp_pid, "Extrude Boss/Cut", , 0.1)
	
	try{
		ControlSetText(11, "Edit1", "ahk_id" extrude_id)
		ControlSetText(1, "Edit4", "ahk_id" extrude_id)
		ControlSetChecked(0,"Button8","ahk_id" extrude_id)
		ControlChooseIndex(2,"ComboBox1","ahk_id" extrude_id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

cut_with_border() {
	PostMessage(0x111, 3130, , , "ahk_id" esp_id)
    extrude_id := WinWaitTitleWithPID(esp_pid, "Extrude Boss/Cut", , 0.1)

	try{
		ControlChooseIndex(2,"ComboBox1","ahk_id" extrude_id)
		ControlSetText(11, "Edit1", "ahk_id" extrude_id)
		ControlSetText(4, "Edit4", "ahk_id" extrude_id)
		ControlChooseIndex(2,"ComboBox2","ahk_id" extrude_id)
		ControlSetChecked(1,"Button8","ahk_id" extrude_id)
		ControlSetChecked(1,"Button3","ahk_id" extrude_id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

extrude_by(length) {
    PostMessage(0x111, 3130, , , "ahk_id" esp_id)
    extrude_id := WinWaitTitleWithPID(esp_pid, "Extrude Boss/Cut", , 0.1)
    
	try{
		ControlSetText(length, "Edit1", "ahk_id" extrude_id)
		ControlSetChecked(0,"Button2", "ahk_id" extrude_id)
		ControlChooseIndex(1,"ComboBox1","ahk_id" extrude_id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

toggle_extrude_window_reverse_side(){
    _id := WinActiveTitleWithPID(esp_pid, "Extrude Boss/Cut")
	if _id {
		val := ControlGetChecked("Button8", "ahk_id" _id)
		if val {
			ControlSetChecked(0,"Button8", "ahk_id" _id)
		} else {
			ControlSetChecked(1,"Button8", "ahk_id" _id)
		}
	}
}

toggle_extrude_window_reverse_direction(){
    _id := WinActiveTitleWithPID(esp_pid, "Extrude Boss/Cut")
	if _id {
		val := ControlGetChecked("Button2", "ahk_id" _id)
		if val {
			ControlSetChecked(0,"Button2", "ahk_id" _id)
		} else {
			ControlSetChecked(1,"Button2", "ahk_id" _id)
		}
	}
}

draw_straight_border(){
	BlockInput("MouseMove")
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
	Click("Left 2")
	BlockInput("MouseMoveOff")
}

get_case_type(title){
    if InStr(title, "AOT", true) {
        return "AOT"
    } else if InStr(title, "TLOC", true) {
        return "TLOC"
    } else if InStr(title, "T-L", true) {
        return "TLOC"
    } else if InStr(title, "ASC", true) {
        return "ASC"
    } else if InStr(title, "TA", true) {
        return "DS"
    } else {
        return -1
    }
}

get_case_id(title){
    FoundPos := RegExMatch(title, ",([0-9]+)", &SubPat)

    if FoundPos{
        return SubPat[1]
    }

    return ""
}

get_connection_type(title){
    FoundPos := RegExMatch(title, "\(([A-Za-z0-9;-]+),", &SubPat)
    if FoundPos {
        return StrSplit(SubPat[1], "-")[1]
    }

    return ""
}

is_non_engaging(title){
	if(InStr(title, "CB", true)){
		return true
	}

	return false
}

remove_stl_file(STL_FILE_PATH) {
    if FileExist(STL_FILE_PATH){
        FileRecycle(STL_FILE_PATH)        
    }
}

ds_startup_commands(){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
        if win_1 {
            ControlSend("{Enter}", , "ahk_id" win_1)
        }

        win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
        if win_2 {
            ControlSend("{Enter}", , "ahk_id" win_2)
        }

        win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
        if win_3 {
            ControlSend("{Enter}", , "ahk_id" win_3)
        }
	}
    stl_rotate_id := WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
	deg0("ahk_id" esp_id)
    yn := MsgBox("Is the connection correct?", "Tru-AHK", "YesNoCancel")
    if yn != "Yes"{
        return
    }
    WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("65 115")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
	WinWaitClose("ahk_id" base_work_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)

    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
}

asc_startup_commands(){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
        if win_1 {
            ControlSend("{Enter}", , "ahk_id" win_1)
        }

        win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
        if win_2 {
            ControlSend("{Enter}", , "ahk_id" win_2)
        }

        win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
        if win_3 {
            ControlSend("{Enter}", , "ahk_id" win_3)
        }
	}
	stl_rotate_id := WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
	WinActivate("ahk_id" esp_id)
	deg0("ahk_id" esp_id)
	yn := MsgBox("Is the connection correct?", "Tru-AHK", "YesNoCancel")
    if yn != "Yes"{
        return
    }
	WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("60 147")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
	WinWaitClose("ahk_id" base_work_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)

    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
}

tl_aot_startup_commands(){
    while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
        if win_1 {
            ControlSend("{Enter}", , "ahk_id" win_1)
        }

        win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
        if win_2 {
            ControlSend("{Enter}", , "ahk_id" win_2)
        }

        win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
        if win_3 {
            ControlSend("{Enter}", , "ahk_id" win_3)
        }
	}
    WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
    deg0("ahk_id" esp_id)
}

#HotIf WinActive("ahk_pid" esp_pid)

; === Remappings ===
Space::Enter
LWin::Delete


f13::{
    Run("esp.ahk " esp_pid)
    ExitApp
}

f12::{
    ProcessExist("esprit.exe")
    pid := WinGetPID("A")
    ProcessClose(pid)
    ExitApp
}

; === Hotstrings ===
:*:3-1::{
    formatted_angle := (get_current_angle("ahk_id" esp_id) - 7) * 10
    Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
 }
 
 :*:3-2::{
    formatted_angle := (get_current_angle("ahk_id" esp_id) - 7) * 10
    Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
 }
 
 :*:3-3::{
    formatted_angle := (get_current_angle("ahk_id" esp_id) - 7) * 10
    Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
 }
 
 :*:2-1::{
     esprit_title := WinGetTitle("ahk_id" esp_id)
     if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
         Send "2-1. FRONT TURNING-SHORT"
     } else {
         Send "2-1. FRONT TURNING"
     }
 }
 
 :*:5-1::{
     esprit_title := WinGetTitle("ahk_id" esp_id)
     if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
         Send "5-1. FRONT TURNING"
     }
 }
 

; === View Controls ===
a::{
    try{
        deg0("ahk_id" esp_id)
    }
}

s::{
    try{
        deg90("ahk_id" esp_id)
    }
}

d::{
    try{
        deg180("ahk_id" esp_id)
    }
}

f::{
    try{
        deg270("ahk_id" esp_id)
    }
}

c::{
    try{
        face("ahk_id" esp_id)
    }
}

v::{
    try{
        rear("ahk_id" esp_id)
    }
}

!WheelDown::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        increment_10_degrees("ahk_id" esp_id)
    }
}

+!WheelDown::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        increment_90_degrees("ahk_id" esp_id)
    }
}

!WheelUp::{
    try{
        if not WinActive("ahk_id" esp_id){
            WinActivate("ahk_id" esp_id)
        }
        decrement_10_degrees("ahk_id" esp_id)
    }
}

+!WheelUp::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        decrement_90_degrees("ahk_id" esp_id)  
    }
}

; === Controls ===

f14::{
    solid_view()
}

; Tilde(~) key
`::{
    wireframe_view()
}

t::{
    transformation_window()
}

^t::{
    translate_selection_click()
}

^r::{
    rotate_selection(90)
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

!x::
XButton1::{
    trim_tool()
}

+XButton2::{
    three_point_tool()
}

!LButton::{
    Send("{LButton}{RButton}{LButton}")
}

^d::{
    highlight_tool()
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

g::{
    if not WinActive("Extrude Boss/Cut"){
        double_sided_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

b::{
    if not WinActive("Extrude Boss/Cut"){
        cut_with_border()
    } else {
        toggle_extrude_window_reverse_side()
    }
}

r::{
    distance_val := 5
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
    
}

r & Numpad1::{
    distance_val := 1
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad2::{
    distance_val := 2
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad3::{
    distance_val := 3
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad4::{
    distance_val := 4
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad5::{
    distance_val := 5
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad6::{
    distance_val := 6
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad7::{
    distance_val := 7
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

r & Numpad8::{
    distance_val := 8
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}
r & Numpad9::{
    distance_val := 9
    if not WinActive("Extrude Boss/Cut"){
        extrude_by(distance_val)
    } else if WinActive("Extrude Boss/Cut") and ControlGetText("Edit1", "Extrude Boss/Cut") != distance_val{
        extrude_by(distance_val)
    } else {
        toggle_extrude_window_reverse_direction()
    }
}

e::{
    draw_straight_border()
}

f18::{
    save_file()
}

; === Auto-Complete Margins ===
~Escape::{
    if not WinActive("ahk_class #32770","No Intersections P->L"){
        draw_path("cancel")
    }
    stop_simulation()
}

+CapsLock::
XButton2::{
    draw_path("start")
}

~LButton::{
    draw_path("click")
}

RButton::{
    draw_path("complete")
}

; ===== Auto-Fill TLOC cases =====
+t::{
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) == "TLOC"){
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
    } else if(get_case_type(esprit_title) == "AOT"){
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

y::{
    CoordMode("Mouse", "Screen")
    MouseMove(46, 38, 0) ; Press Tab 1
    Click(170, 325) ; Click the Entry Box
    Send("^a-5")
    Click(175, 275) ; Click Regenerate
}

AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("30 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("31 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
}

+AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(40)
    ; 4th Margin
    Click("180 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("30 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("31 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
}

q::{
    swap_path()
    generate_path()
}

w::{
    swap_path()
}

!Numpad7::{
    global step_5_tab
    step_5_window_0_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad9::{
    global step_5_tab
    step_5_window_120_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad1::{
    global step_5_tab
    step_5_window_240_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad3::{
    global step_5_tab
    step_5_window_270_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad0::{
    step_5_window_90_plus_deg()
}


z::{
    global step_5_tab
    step_5_window_tab_1()
    step_5_tab := 1
}

x::{
    global step_5_tab
    step_5_window_tab_2()
    step_5_tab := 2
}

^!Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_10_degrees()
    }
}

^!Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_10_degrees()
    }
}

^+Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_90_degrees()
    }
}

^+Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_90_degrees()
    }
}

^Numpad1::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button1()
}

^Numpad2::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button2()
}

^Numpad3::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button3()
}

^Numpad4::{
    ; unsuppress_operation()
    Sleep(20)
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    macro_button4()
}

^Numpad5::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button5()
    step_5_tab := 2
}

^Numpad6::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button_text()
}

^!Numpad1::{
    CoordMode("Mouse", "Screen")
    click_and_return(32, 1020)
}

^!Numpad3::{
    CoordMode("Mouse", "Screen")
    click_and_return(80, 1020)
}

; Deg 1
!1::{
    step_3_deg1()
}

; Deg 2 
!2::{
    step_3_deg2()
}

; Deg 3 
!3::{
    step_3_deg3()
}

; +90 Deg
!q::{
    step_3_degplus90()
}

; Toggle Yellow Checkbox
!w::{
    step_3_yellowcheckbox()
}

; Tab 1
!a::{
    step_3_tab1()
}

; Tab 2
!s::{
    step_3_tab2()
}

; Tab 3
!d::{
    step_3_tab3()
}

!Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 250)
}

!Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 250)
}

!Up::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 210)
}

!Down::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 210)
}

+Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 290)
}

+Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 290)
}

^+Enter::{
    CoordMode("Mouse", "Screen")
    click_and_return(106, 126)
    WinWaitActiveTitleWithPID(esp_pid, "esprit", "OK")
    WinClose("esprit", "OK")
}

^!Enter::{
    CoordMode("Mouse", "Screen")
    click_and_return(103, 336)
}

!e::{
    show_milling_tool()
}

; G3 Key
f15::{
    WinMove(-600, 275, , , "esprit", "&Yes")
}

^Left::{
    translate_selection(-0.5, 0, 0)
}

^Up::{
    if(WinExist("Check Rough ML & Create Border Solid")){
        WinActivate("Check Rough ML & Create Border Solid")
        BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        ; Get the current number of passes
        A_Clipboard := ""
        Click("30 70")
        Sleep(20)
        Click("154 240")
        Send("^a^c")
        ClipWait(2)

        if(IsInteger(A_Clipboard)){
            passes := A_Clipboard + 1

            Click("30 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")

            Sleep(20)
            Click("108 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")
            Sleep(20)

            Click("53 157")
            BlockInput("MouseMoveOff")
        }
    }
}

^Down::{
    if(WinExist("Check Rough ML & Create Border Solid")){
        WinActivate("Check Rough ML & Create Border Solid")
        BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
        CoordMode("Mouse", "Client")
        ; Get the current number of passes
        A_Clipboard := ""
        Click("30 70")
        Sleep(20)
        Click("154 240")
        Send("^a^c")
        ClipWait(2)

        if(IsInteger(A_Clipboard)){
            passes := A_Clipboard - 1

            Click("30 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")

            Sleep(20)
            Click("108 70")
            Sleep(20)
            Click("154 240")
            Sleep(20)
            Send("^a" passes "{Enter}")
            Send("^a" (-1*passes) "{Enter}")
            Click("112 320")
            Sleep(20)

            Click("53 157")
            BlockInput("MouseMoveOff")
        }
    }
}

; G4
f16::{
    selected_file := ""
    For k,v in file_map{
        if v = False and FileExist(STL_FILE_PATH "\" k){
            selected_file := k
            break
        }
    }
    found_pos := RegExMatch(selected_file, "\(([A-Za-z0-9\-]+),", &sub_pat)
    if found_pos {
        SplitPath(selected_file, &name)
        open_file()
        WinWaitTitleWithPID(esp_pid, "Open", "&Open")
        open_id := WinActivateTitleWithPID(esp_pid, "Open", "&Open")
        ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_id" open_id)
        ControlSetChecked(0,"Button5","ahk_id" open_id)
        ControlSend("{Enter}", "Button2","ahk_id" open_id)
        are_you_sure_id := WinWaitTitleWithPID(esp_pid, "ahk_class #32770", "&Yes", 1)
        if are_you_sure_id {
            WinWaitClose("ahk_id" are_you_sure_id)
        }
        yn := MsgBox("Is the basic setting loaded?", "Tru-AHK", "YesNoCancel")
        if yn != "Yes"{
            return
        }
        file_map[name] := true
        WinActivate("ahk_id" esp_id)
        macro_button1("ahk_id" esp_id)
        WinWaitActiveTitleWithPID(esp_pid, "CAM Automation")
        Send("{Enter}")
        WinWaitActiveTitleWithPID(esp_pid, "Select file to open")
        Sleep(200)
        ControlSetText(selected_file, "Edit1", "Select file to open")
        Send("{Enter}")
        switch get_case_type(selected_file) {
            case "DS":
                ds_startup_commands()
            case "ASC":
                asc_startup_commands()
            case "TLOC": 
                tl_aot_startup_commands()
            case "AOT":
                tl_aot_startup_commands()
            default: 
                return
        }
    }
}