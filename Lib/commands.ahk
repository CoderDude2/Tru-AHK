#SingleInstance Force
SetWorkingDir A_ScriptDir

consolelog(msg){
    msg := msg "`r`n"
    previous_clipboard := A_Clipboard
    A_Clipboard := msg
    ControlFocus("Edit1", "ESPRIT - ")
    Send("^{End}")
    PostMessage(0x111, 57637, , "Edit1", "ESPRIT - ")
    Sleep(200)
    A_Clipboard := previous_clipboard
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
            PostMessage 0x111, 3057, , , "ESPRIT"
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

show_milling_tool(){
	PostMessage 0x111, 6278 , , , "ESPRIT"
}

unsuppress_operation(){
	project_manager := get_project_manager()
	if project_manager != ""{
		is_attached := IniRead(PREFS_FILE_PATH, "project_manager_control", "is_attached")
		if(is_attached){
			PostMessage 0x111, 32792 , , project_manager, "ESPRIT"
		} else {
			if USER_LANGUAGE == "en"{
				PostMessage 0x111, 32792 , , project_manager, "Project Manager"
			} else if USER_LANGUAGE == "ko"{
				PostMessage 0x111, 32792 , , project_manager, "프로젝트 매니저"
			}
		}
	}	
}

suppress_operation(){
	project_manager := get_project_manager()
	if project_manager != ""{
		is_attached := IniRead(PREFS_FILE_PATH, "project_manager_control", "is_attached")
		if(is_attached) {
			PostMessage 0x111, 32770 , , project_manager, "ESPRIT"
		} else {
			if USER_LANGUAGE == "en"{
				PostMessage 0x111, 32770 , , project_manager, "Project Manager"
			} else if USER_LANGUAGE == "ko"{
				PostMessage 0x111, 32770 , , project_manager, "프로젝트 매니저"
			}
		}
	}
}

rebuild_operation(){
	project_manager := get_project_manager()
	if project_manager != ""{
		is_attached := IniRead(PREFS_FILE_PATH, "project_manager_control", "is_attached")
		if(is_attached) {
			PostMessage 0x111, 32768 , , project_manager, "ESPRIT"
		} else {
			if USER_LANGUAGE == "en"{
				PostMessage 0x111, 32768 , , project_manager, "Project Manager"
			} else if USER_LANGUAGE == "ko"{
				PostMessage 0x111, 32768 , , project_manager, "프로젝트 매니저"
			}
		}
	}
}

ds_startup_commands(){
	while not WinExist("STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check") or 
		   WinActive("esprit", "예(&Y)" or WinActive("esprit", "확인")){
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
	if IniRead(PREFS_FILE_PATH, "auto_recycle_STL", "value") == true{
		recycle_active_file()
	}
	macro_button_3()
}

asc_startup_commands(){
	while not WinExist("STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check") or 
		   WinActive("esprit", "예(&Y)" or WinActive("esprit", "확인")){
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
	if IniRead(PREFS_FILE_PATH, "auto_recycle_STL", "value") == true{
		recycle_active_file()
	}
	macro_button_3()
}

tl_aot_startup_commands(){
    while not WinExist("STL Rotate"){
		if WinActive("esprit", "&Yes") or WinActive("esprit", "OK") or WinActive("Direction Check") or 
		   WinActive("esprit", "예(&Y)" or WinActive("esprit", "확인")){
			Send("{Enter}")
		}
	}
    WinWaitActive("STL Rotate")
	WinActivate("ESPRIT -")
    deg0()
}

toggle_extrude_window_reverse_side(){
	try{
		_id := WinGetID(extrude_window_name)
		val := ControlGetChecked("Button8", "ahk_id" _id)
		if val {
			ControlSetChecked(0,"Button8", "ahk_id" _id)
		} else {
			ControlSetChecked(1,"Button8", "ahk_id" _id)
		}
	}
}

toggle_extrude_window_reverse_direction(){
	try{
		_id := WinGetID(extrude_window_name)
		val := ControlGetChecked("Button2", "ahk_id" _id)
		if val {
			ControlSetChecked(0,"Button2", "ahk_id" _id)
		} else {
			ControlSetChecked(1,"Button2", "ahk_id" _id)
		}
	}
}

double_sided_border() {
	PostMessage(0x111, 3130, , , "ESPRIT")
	WinWait(extrude_window_name,,0.1)
	
	try{
		_id := WinGetID(extrude_window_name)
		ControlSetText(11, "Edit1", "ahk_id" _id)
		ControlSetText(1, "Edit4", "ahk_id" _id)
		Sleep(50)
		ControlSetChecked(0,"Button8","ahk_id" _id)
		ControlChooseIndex(2,"ComboBox1","ahk_id" _id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
		consolelog("[Tru-AHK] No geometry selected")
	}
}

cut_with_border() {
	PostMessage(0x111, 3130, , , "ESPRIT")
	WinWait(extrude_window_name,,0.1)
	try{
		_id := WinGetID(extrude_window_name)
		ControlChooseIndex(2,"ComboBox1","ahk_id" _id)
		ControlSetText(11, "Edit1", "ahk_id" _id)
		ControlSetText(4, "Edit4", "ahk_id" _id)
		ControlChooseIndex(2,"ComboBox2","ahk_id" _id)
		Sleep(50)
		ControlSetChecked(1,"Button8","ahk_id" _id)
		ControlSetChecked(1,"Button3","ahk_id" _id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
		consolelog("[Tru-AHK] No geometry selected")
	}
}

extrude_by(length) {
	PostMessage(0x111, 3130, , , "ESPRIT")
	WinWait(extrude_window_name,,0.1)

	try{
		_id := WinGetID(extrude_window_name)
		ControlSetText(length, "Edit1", "ahk_id" _id)
		ControlSetChecked(0,"Button2", "ahk_id" _id)
		ControlChooseIndex(1,"ComboBox1","ahk_id" _id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
		consolelog("[Tru-AHK] No geometry selected")
	}
}

click_client_pos(posX, posY, window_name, block_input := false, return_to_start := true){
	SetDefaultMouseSpeed 0
	try{
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

			if return_to_start {
				CoordMode "Mouse", "Screen"
				MouseMove mouse_screen_posX, mouse_screen_posY
			}
			
			BlockInput("MouseMoveOff")
		}
	}
}

draw_straight_border(){
	try{
		BlockInput("MouseMove")
		line_tool()
		Click("Left")
		Send("20{Enter}0{Enter}{Esc}")
		Click("Left 2")
		WinWaitClose("ahk_class #32770", "PIN")
		double_sided_border()
		BlockInput("MouseMoveOff")
	} catch {
		BlockInput("MouseMoveOff")
	}
}

draw_straight_line(){
	CoordMode("Mouse", "Screen")
	BlockInput("MouseMove")
	MouseGetPos(&posX, &posY)
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
	Click(posX, posY, 2)
	BlockInput("MouseMoveOff")
}

translate_selection(x := 0, y := 0, z := 0){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

	if USER_LANGUAGE == "en"{
		english_index := ControlFindItem("Translate", "ComboBox1", "ahk_class #32770")
		ControlChooseIndex(english_index, "ComboBox1", "ahk_class #32770")
		ControlSetChecked(1,"Button7","ahk_class #32770")
		ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
		ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
		ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")
		Send("{Enter}")
	} else if USER_LANGUAGE == "ko"{
		korean_index := ControlFindItem("이동", "ComboBox1", "ahk_class #32770")
		ControlChooseIndex(korean_index, "ComboBox1", "ahk_class #32770")
		ControlSetChecked(1,"Button7","ahk_class #32770")
		ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
		ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
		ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")
		Send("{Enter}")
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

get_basic_setting_path(){
	basic_setting_path := IniRead(PREFS_FILE_PATH, "locations", "basic_setting_path")
	return basic_setting_path
}

get_stl_path(){
	stl_path := IniRead(PREFS_FILE_PATH, "locations", "stl_path")
	return stl_path
}

get_project_manager(){
	class_nn := IniRead(PREFS_FILE_PATH, "project_manager_control", "control")
	is_attached := IniRead(PREFS_FILE_PATH, "project_manager_control", "is_attached")

	if class_nn == ""{
		MsgBox("Project manager control not set. Go to the dashboard to set it.", "Error - Project manager not set", "0x30")
		return ""
    }

	try {
		if(is_attached){
			project_manager_control := ControlGetClassNN(class_nn, "ESPRIT - ")
		} else {
			if USER_LANGUAGE == "en"{
				project_manager_control := ControlGetClassNN(class_nn, "Project Manager")
			} else if USER_LANGUAGE == "ko" {
				project_manager_control := ControlGetClassNN(class_nn, "프로젝트 매니저")
			}
		}
	} catch TargetError {
		MsgBox("Project manager control not found, try setting it in the dashboard.", "Error - Project manager not found", "0x10")
		return ""
	}

	return project_manager_control
}

get_macro_bar(){
	class_nn := IniRead(PREFS_FILE_PATH, "macro_bar_control", "control")

    if class_nn == ""{
        MsgBox("Macro bar control not set. Go to the dashboard to set it.", "Error - Macro bar not set", "0x30")
		return ""
    }
    
    try {
        macro_bar_control := ControlGetClassNN(class_nn, "ESPRIT - ")
		return macro_bar_control
    } catch TargetError {
		MsgBox("Macro bar control not found, try setting it in the dashboard.", "Error - Macro bar not found", "0x10")
		return ""
	}
}

macro_button_1(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+20, y+14
	}
}

macro_button_2(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+45, y+14
	}    
}

macro_button_3(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+68, y+14
	}
}

macro_button_4(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+90, y+14
	}
}

macro_button_5(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+115, y+14
	}
}

macro_button_text(){
	macro_bar := get_macro_bar()
	if macro_bar != ""{
		WinActivate("ESPRIT - ")
		CoordMode "Mouse", "Client"
		ControlGetPos(&x, &y, &w, &h, macro_bar, "ESPRIT - ")
		Click x+135, y+14
	}
}

recycle_active_file(){
	WinActivate("ESPRIT - ")
	window_title := WinGetTitle("A")
    found_pos := RegExMatch(window_title, "(?<PDO>\w+-\w+-\d+)__\((?<connection>[A-Za-z0-9-]+),(?<id>\d+)\)\[?(?<angle>[A-Za-z0-9\.\-#= ]+)?\]?(?<file_type>\.\w+)", &SubPat)
    if found_pos{
        esp_filename := SubStr(window_title, SubPat.Pos, SubPat.Len)
        stl_filename := StrSplit(esp_filename, '.esp')[1] ".stl"
        if FileExist(get_stl_path() "\" stl_filename){
            FileRecycle(get_stl_path() "\" stl_filename)        
        }
    }
}