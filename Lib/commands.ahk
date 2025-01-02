#SingleInstance Force
SetWorkingDir A_ScriptDir

prefs_file_path := A_AppData "\tru-ahk\prefs.ini"

create_default_prefs_file(){
	DirCreate(A_AppData "\tru-ahk\")
	IniWrite("All Instances", prefs_file_path, "f12_mode", "value")
	IniWrite("Line and Border", prefs_file_path, "e_key_functionality", "value")
	IniWrite(true, prefs_file_path, "w_as_delete", "value")
	IniWrite("", prefs_file_path, "macro_bar_control", "control")
	IniWrite("", prefs_file_path, "project_manager_control", "control")
	IniWrite(true, prefs_file_path, "project_manager_control", "is_attached")
}

open_help(*){
	Run A_ScriptDir "\resources\keymap.html"
}

open_changelog(*){
	Run A_ScriptDir "..\resources\changelog.html"
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

transformation_window(){
	PostMessage 0x111, 57634 , , , "ESPRIT"
}

unsuppress_operation(){
	is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")
	if(is_attached){
		PostMessage 0x111, 32792 , , get_project_manager(), "ESPRIT"
	} else {
		PostMessage 0x111, 32792 , , get_project_manager(), "Project Manager"
	}
}

suppress_operation(){
	is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")
	if(is_attached) {
		PostMessage 0x111, 32770 , , get_project_manager(), "ESPRIT"
	} else {
		PostMessage 0x111, 32770 , , get_project_manager(), "Project Manager"
	}
	
}

rebuild_operation(){
	global prefs_file_path
	is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")
	if(is_attached){
		PostMessage 0x111, 32768 , , get_project_manager(), "ESPRIT"
	} else {
		PostMessage 0x111, 32768 , , get_project_manager(), "Project Manager"
	}
	
}

show_milling_tool(){
	PostMessage 0x111, 6278 , , , "ESPRIT"
}

double_sided_border() {
	WinActivate("ESPRIT")
	PostMessage(0x111, 3130, , , "ESPRIT")

	WinWaitActive("ahk_class #32770")
	try{
		ControlSetText(11, "Edit1", "ahk_class #32770")
		ControlSetText(1, "Edit4", "ahk_class #32770")
		Sleep(100)
		ControlSetChecked(0,"Button8","ahk_class #32770")
		ControlChooseIndex(2,"ComboBox1","ahk_class #32770")
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
		MsgBox "No geometry was selected."
	}
}

cut_with_border() {
	WinActivate("ESPRIT")
	PostMessage(0x111, 3130, , , "ESPRIT")

	WinWaitActive("ahk_class #32770")
	try{
		ControlChooseIndex(2,"ComboBox1","ahk_class #32770")
		ControlSetText(11, "Edit1", "ahk_class #32770")
		ControlSetText(4, "Edit4", "ahk_class #32770")
		ControlChooseIndex(2,"ComboBox2","ahk_class #32770")
		Sleep(100)
		ControlSetChecked(1,"Button8","ahk_class #32770")
		ControlSetChecked(1,"Button3","ahk_class #32770")
	} catch TargetError as err {
		MsgBox "No geometry was selected."
	}
}

extrude_by(length) {
	WinActivate("ESPRIT")
	PostMessage(0x111, 3130, , , "ESPRIT")

	WinWaitActive("ahk_class #32770")
	try{
		ControlSetText(length, "Edit1", "ahk_class #32770")
		ControlSetChecked(0,"Button2","ahk_class #32770")
		ControlChooseIndex(1,"ComboBox1","ahk_class #32770")
	} catch TargetError as err {
		MsgBox "No geometry was selected."
	}
}

click_client_pos(posX, posY, window_name, block_input := false){
	if WinExist(window_name){
		esprit_window_pid := WinGetPID("A")
		target_window_pid := WinGetPID(window_name)

		if target_window_pid = esprit_window_pid{
			if(block_input){
				BlockInput("MouseMove")
			}
			CoordMode "Mouse", "Screen"
			MouseGetPos(&mouse_screen_posX, &mouse_screen_posY)
			CoordMode "Mouse", "Client"
			if WinActive(window_name){
				Click(posX, posY)
			} else{
				WinActivate(window_name)
				Click(posX, posY)
			}
			CoordMode "Mouse", "Screen"
			MouseMove mouse_screen_posX, mouse_screen_posY
			BlockInput("MouseMoveOff")
		}
	}
}

draw_straight_border(){
	WinActivate("ESPRIT")
	CoordMode("Mouse", "Screen")
	BlockInput("MouseMove")
	MouseGetPos(&posX, &posY)
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
	Click(posX, posY, 2)
	Sleep(100)
	double_sided_border()
	WinActivate("ahk_class #32770")
	ControlSend("{Enter}", "Button9", "ahk_class #32770")
	BlockInput("MouseMoveOff")
}

draw_straight_line(){
	WinActivate("ESPRIT")
	CoordMode("Mouse", "Screen")
	BlockInput("MouseMove")
	MouseGetPos(&posX, &posY)
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
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

translate_selection(x := 0, y := 0, z := 0){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

	try{
		korean_index := ControlFindItem("이동", "ComboBox1", "ahk_class #32770")

		if(korean_index != 4294967296){
			ControlChooseIndex(korean_index, "ComboBox1", "ahk_class #32770")
			ControlSetChecked(1,"Button7","ahk_class #32770")
			ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
			ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
			ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")
			Send("{Enter}")
		}
	}

	try{
		english_index := ControlFindItem("Translate", "ComboBox1", "ahk_class #32770")
	 	
		if(english_index != 4294967296){
			ControlChooseIndex(english_index, "ComboBox1", "ahk_class #32770")
			ControlSetChecked(1,"Button7","ahk_class #32770")
			ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
			ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
			ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")
			Send("{Enter}")
		} 
	}
	
}

rotate_selection(degrees, update_on_click:=False){
	
    WinActivate("ESPRIT")
    transformation_window()
	WinWaitActive("ahk_class #32770")
	try{
		korean_index := ControlFindItem("회전", "ComboBox1", "ahk_class #32770")
		if(korean_index != 4294967296){
			ControlChooseIndex(korean_index, "ComboBox1", "ahk_class #32770")
			ControlSetText(Round(degrees, 4), "Edit6", "ahk_class #32770")
			if(update_on_click = True){
				ControlSetChecked(0,"Button10","ahk_class #32770")
			} else {
				ControlSetChecked(1,"Button10","ahk_class #32770")
			}
			Send("{Enter}")
		}
	}
	
	try{
		english_index := ControlFindItem("Rotate", "ComboBox1", "ahk_class #32770")
		if(english_index != 4294967296){
			ControlChooseIndex(english_index, "ComboBox1", "ahk_class #32770")
			ControlSetText(Round(degrees, 4), "Edit6", "ahk_class #32770")
			if(update_on_click = True){
				ControlSetChecked(0,"Button10","ahk_class #32770")
			} else {
				ControlSetChecked(1,"Button10","ahk_class #32770")
			}
			Send("{Enter}")
		}
	}
}

scale_selection(scale){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

	try {
		korean_index := ControlFindItem("축척", "ComboBox1", "ahk_class #32770")
		if(korean_index != 4294967296){
			ControlChooseIndex(korean_index, "ComboBox1", "ahk_class #32770")

			ControlSetText(Round(scale, 4), "Edit8", "ahk_class #32770")
    		Send("{Enter}")
		}
	}

	try{
		english_index := ControlFindItem("Scale", "ComboBox1", "ahk_class #32770")
		if(english_index != 4294967296){
			ControlChooseIndex(english_index, "ComboBox1", "ahk_class #32770")
			ControlSetText(Round(scale, 4), "Edit8", "ahk_class #32770")
    		Send("{Enter}")
		}
	}

}

get_project_manager(){
	global prefs_file_path
	class_nn := IniRead(prefs_file_path, "project_manager_control", "control")
	is_attached := IniRead(prefs_file_path, "project_manager_control", "is_attached")

	if class_nn == ""{
        MsgBox("Project manager control not set!")
    }

	try {
		if(is_attached){
			project_manager_control := ControlGetClassNN(class_nn, "ESPRIT")
		} else {
			project_manager_control := ControlGetClassNN(class_nn, "Project Manager")
		}
	}

	return project_manager_control
}

get_macro_bar(){
	global prefs_file_path
	class_nn := IniRead(prefs_file_path, "macro_bar_control", "control")

    if class_nn == ""{
        MsgBox("Macro bar control not set!")
    }
    
    try {
        macro_bar_control := ControlGetClassNN(class_nn, "ESPRIT")
    }

	return macro_bar_control
}

macro_button_1(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar()
    Click x+20, y+14
}

macro_button_2(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar() 
    Click x+45, y+14
}

macro_button_3(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar()
    Click x+68, y+14
}

macro_button_4(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar()
    Click x+90, y+14
}

macro_button_5(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar()
    Click x+115, y+14
}

macro_button_text(){
	CoordMode "Mouse", "Client"
    ControlGetPos &x, &y, &w, &h, get_macro_bar()
    Click x+135, y+14
}