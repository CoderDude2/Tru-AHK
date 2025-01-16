#SingleInstance Force
A_HotkeyInterval := 9900000  ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 9900000
KeyHistory 0
ListLines False
ProcessSetPriority "A"
SetKeyDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetControlDelay -1
SetWorkingDir A_ScriptDir

highlight_tool(){
	PostMessage 0x111, 6156 , , "msctls_statusbar322", "ESPRIT"
}

generate_nc(){
	PostMessage 0x111, 3323, , , "ESPRIT"
}

extrude_tool(){
	PostMessage 0x111, 3130 , , , "ESPRIT"
}

circle_tool(){
	PostMessage 0x111, 3005 , , , "ESPRIT"
}

line_tool(){
	PostMessage 0x111, 3018 , , , "ESPRIT"
}

line_tool_2(){
	PostMessage 0x111, 3019 , , , "ESPRIT"
}

trim_tool(){
	PostMessage 0x111, 3033 , , , "ESPRIT"
}

three_point_tool(){
	PostMessage 0x111, 3004 , , , "ESPRIT"
}

wireframe_view(){
	PostMessage 0x111, 6130 , , , "ESPRIT"
}

solid_view(){
	PostMessage 0x111, 6135 , , , "ESPRIT"
}

generate_path(){
	PostMessage 0x111, 3054 , , , "ESPRIT"
}

swap_path(){
	PostMessage 0x111, 3145 , , , "ESPRIT"
}

draw_path(){
	PostMessage 0x111, 3057, , , "ESPRIT"
}

toggle_simulation(){
	PostMessage 0x111, 6268 , , , "ESPRIT"
}

stop_simulation(){
	PostMessage 0x111, 6276 , , , "ESPRIT"
}

save_file(){
	PostMessage 0x111, 57603 , , , "ESPRIT"
}

open_file(){
	PostMessage 0x111, 57601 , , , "ESPRIT"
}

transformation_window(){
	PostMessage 0x111, 57634 , , , "ESPRIT"
}

unsuppress_operation(){
	PostMessage 0x111, 32792 , , "SysTreeView321", "Project Manager"
}

suppress_operation(){
	PostMessage 0x111, 32770 , , "SysTreeView321", "Project Manager"
}

rebuild_operation(){
	PostMessage 0x111, 32768 , , "SysTreeView321", "Project Manager"
}

set_point(x, y, z){
	try{
    	PostMessage 0x111, 10425, , , "Point"
		ControlSetText(x, "Edit1", "ahk_class #32770")
		ControlSetText(y, "Edit2", "ahk_class #32770")
		ControlSetText(z, "Edit3", "ahk_class #32770")
		PostMessage 0x111, 12321, , , "Point"
	}
}

set_bounding_points(){
	if not WinExist("Point"){
        PostMessage 0x111, 3014, , , "ESPRIT"
        Sleep(50)
        WinActivate "Point"
    } else {
        WinActivate "Point"
    }
    deg0()
    Sleep(50)

    set_point(17, 7, 0)
    Sleep(50)

    set_point(-5, 7, 0)
    Sleep(50)

    set_point(-5, -7, 0)
    Sleep(50)

    set_point(17, -7, 0)
    Sleep(50)

    face()
    Sleep(50)

    set_point(7, 0, 0)
    Sleep(50)

    set_point(-7, 0, 0)
    Sleep(50)

    set_point(0, 7, 0)
    Sleep(50)

    set_point(0, -7, 0)
    Sleep(50)

    deg0()
    Sleep(50)

    WinClose("Point")
}

ds_startup_commands(){
	while not WinExist("STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check", "OK"){
			Send("{Enter}")
		}
	}
	WinActivate("ESPRIT -")
	deg0()
	yn := MsgBox("Is the connection correct?",,"YesNoCancel 0x1000")
    if yn != "Yes"{
        return
    }
	WinActivate("STL Rotate")
	CoordMode("Mouse", "Client")
	Click("65 115")
	WinWaitActive("Base Work Plane(Degree)")
	WinWaitClose("Base Work Plane(Degree)")
	macro_button3()
}

asc_startup_commands(){
	while not WinExist("STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check", "OK"){
			Send("{Enter}")
		}
	}
	WinWaitActive("STL Rotate")
	WinActivate("ESPRIT -")
	deg0()
	yn := MsgBox("Is the connection correct?",,"YesNoCancel 0x1000")
    if yn != "Yes"{
        return
    }
	WinActivate("STL Rotate")
	CoordMode("Mouse", "Client")
	Click("60 147")
	WinWaitActive("Base Work Plane(Degree)")
	WinWaitClose("Base Work Plane(Degree)")
	macro_button3()
}

show_milling_tool(){
	PostMessage 0x111, 6278 , , , "ESPRIT"
}

click_and_return(posX, posY){
	MouseGetPos(&mouse_posX, &mouse_posY, &window, &active_control)
	Click(posX, posY)
	MouseMove(mouse_posX, mouse_posY)
}

double_sided_border() {
	WinActivate("ESPRIT")
	PostMessage(0x111, 3130, , , "ESPRIT")

	WinWaitActive("ahk_class #32770")
	try{
		ControlSetText(11, "Edit1", "ahk_class #32770")
		ControlSetText(1, "Edit4", "ahk_class #32770")
		ControlSetChecked(0,"Button8","ahk_class #32770")
		ControlChooseIndex(2,"ComboBox1","ahk_class #32770")
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
		MsgBox "Select a line first"
	}
}

cut_with_border() {
	WinActivate("ESPRIT")
	extrude_tool()

	WinWaitActive("ahk_class #32770")
	try{
		ControlChooseIndex(2,"ComboBox1","ahk_class #32770")
		ControlSetText(11, "Edit1", "ahk_class #32770")
		ControlSetText(4, "Edit4", "ahk_class #32770")
		ControlChooseIndex(2,"ComboBox2","ahk_class #32770")
		ControlSetChecked(1,"Button8","ahk_class #32770")
		ControlSetChecked(1,"Button3","ahk_class #32770")
	} catch TargetError as err {
		MsgBox "Select a line first"
	}
}

extrude_by(length) {
	if not WinActive("Extrude Boss/Cut"){
		PostMessage(0x111, 3130, , , "ESPRIT")
	}
	
	WinWaitActive("Extrude Boss/Cut")
	try{
		ControlSetText(length, "Edit1", "ahk_class #32770")
		ControlSetChecked(0,"Button2","ahk_class #32770")
		ControlChooseIndex(1,"ComboBox1","ahk_class #32770")
	} catch TargetError as err {
		MsgBox "Select a line first"
	}
}

toggle_extrude_window_reverse_side(){
	if WinActive("Extrude Boss/Cut"){
		val := ControlGetChecked("Button8", "ahk_class #32770")
		if val {
			ControlSetChecked(0,"Button8", "ahk_class #32770")
		} else {
			ControlSetChecked(1,"Button8", "ahk_class #32770")
		}
	}
}

toggle_extrude_window_reverse_direction(){
	if WinActive("Extrude Boss/Cut"){
		val := ControlGetChecked("Button2", "ahk_class #32770")
		if val {
			ControlSetChecked(0,"Button2", "ahk_class #32770")
		} else {
			ControlSetChecked(1,"Button2", "ahk_class #32770")
		}
	}
}

draw_straight_border(){
	BlockInput("MouseMove")
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
	Click("Left 2")
	; Sleep(150)
	; double_sided_border()
	; Send("{Enter}")
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
    return SubPat[1]
}

get_connection_type(title){
    FoundPos := RegExMatch(title, "\(([A-Za-z0-9;-]+),", &SubPat)
    return StrSplit(SubPat[1], "-")[1]
}

is_non_engaging(title){
	if(InStr(title, "CB", true)){
		return true
	}

	return false
}

translate_selection(x := 0, y := 0, z := 0){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

    ControlChooseString("Translate","ComboBox1","ahk_class #32770")
    ControlSetChecked(1,"Button7","ahk_class #32770")

    ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
    ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
    ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")

    Send("{Enter}")
}

translate_selection_click(){
	WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

	ControlChooseString("Translate","ComboBox1","ahk_class #32770")
	ControlSetChecked(1,"Button8","ahk_class #32770")
	Send("{Enter}")
}

translate(){
	WinActivate("ESPRIT")
    transformation_window()
	WinWaitActive("ahk_class #32770")

    ControlChooseString("Translate","ComboBox1","ahk_class #32770")
    ControlSetChecked(1,"Button7","ahk_class #32770")
}

rotate_selection(degrees, update_on_click:=False){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")
    ControlChooseString("Rotate","ComboBox1","ahk_class #32770")
    ControlSetText(Round(degrees, 4), "Edit6", "ahk_class #32770")
    if(update_on_click = True){
        ControlSetChecked(0,"Button10","ahk_class #32770")
    } else {
        ControlSetChecked(1,"Button10","ahk_class #32770")
    }
    Send("{Enter}")
}

scale_selection(scale){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")
    ControlChooseString("Scale","ComboBox1","ahk_class #32770")
    ControlSetText(Round(scale, 4), "Edit8", "ahk_class #32770")
    Send("{Enter}")
}

macro_button1(){
	WinActivate("ESPRIT - ")
    CoordMode("Mouse", "Client")
    click_and_return(25, 105)
}

macro_button2(){
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(45, 105)
}

macro_button3(){
	CoordMode("Mouse", "Client")
    click_and_return(68, 105)

	window_title := WinGetTitle("A")
    found_pos := RegExMatch(window_title, "(?<PDO>\w+-\w+-\d+)__\((?<connection>[A-Za-z0-9-]+),(?<id>\d+)\)\[?(?<angle>[A-Za-z0-9\.\-#= ]+)?\]?(?<file_type>\.\w+)", &SubPat)
    if found_pos{
        esp_filename := SubStr(window_title, SubPat.Pos, SubPat.Len)
        stl_filename := StrSplit(esp_filename, '.esp')[1] . ".stl"
        if FileExist("C:\Users\TruUser\Desktop\작업\스캔파일\" stl_filename){
            FileRecycle("C:\Users\TruUser\Desktop\작업\스캔파일\" stl_filename)        
        }
    }
}

macro_button4(){
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(90, 105)
}

macro_button5(){
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(111, 105)
}

macro_button_text(){
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(137, 105)
}

step_5_window_0_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(69, 170)
}

step_5_window_120_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(183, 172)
}

step_5_window_240_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(68, 213)
}

step_5_window_270_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(181, 226)
}

step_5_window_90_plus_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(45, 259)
}

step_5_window_tab_1(){
	CoordMode("Mouse", "Screen")
    click_and_return(52, 36)
}

step_5_window_tab_2(){
	CoordMode("Mouse", "Screen")
    click_and_return(131, 39)
}

