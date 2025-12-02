#Include nav.ahk
STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

highlight_tool(title := "ESPRIT - "){
	PostMessage 0x111, 6156 , , "msctls_statusbar322", title 
}

remove_stl_file(STL_FILE_PATH) {
    if FileExist(STL_FILE_PATH){
        FileRecycle(STL_FILE_PATH)        
    }
}

align_cap(title := "ESPRIT - "){
    PostMessage 0x111, 5038, , , title
}

generate_nc(title := "ESPRIT - "){
	PostMessage 0x111, 3323, , , title 
}

extrude_tool(title := "ESPRIT - "){
	PostMessage 0x111, 3130 , , , title 
}

circle_tool(title := "ESPRIT - "){
	PostMessage 0x111, 3005 , , , title 
}

three_point_circle(title := "ESPRIT - "){
	PostMessage 0x111, 3007 , , , title 
}

line_tool(title := "ESPRIT - "){
	PostMessage 0x111, 3018 , , , title 
}

line_tool_2(title := "ESPRIT - "){
	PostMessage 0x111, 3019 , , , title 
}

trim_tool(title := "ESPRIT - "){
	PostMessage 0x111, 3033 , , , title 
}

three_point_tool(title := "ESPRIT - "){
	PostMessage 0x111, 3004 , , , title 
}

wireframe_view(title := "ESPRIT - "){
	PostMessage 0x111, 6130 , , , title 
}

solid_view(title := "ESPRIT - "){
	PostMessage 0x111, 6135 , , , title 
}

generate_path(title := "ESPRIT - "){
	PostMessage 0x111, 3054 , , , title 
}

swap_path(title := "ESPRIT - "){
	PostMessage 0x111, 3145 , , , title 
}

draw_line(command){
    static click_index
    static line_tool_active := false
    static initial_pos_x, initial_pos_y
    switch command{
        case "get-state":
            return line_tool_active
        case "start":
			if line_tool_active {
				Send("{Escape}")
			}
			Sleep(50)
            click_index := 0
            line_tool_active := true
            PostMessage 0x111, 3018 , , , "ESPRIT" 
        case "click":
			if line_tool_active{
				if click_index < 1{
					CoordMode("Mouse", "Screen")
					MouseGetPos(&initial_pos_x, &initial_pos_y)
					click_index += 1
				} else {
					click_index += 1
				}
			}
        case "cancel":
            line_tool_active := false
            click_index := 0
            initial_pos_x := 0
            initial_pos_y := 0
        case "complete":
             if line_tool_active{
				if click_index > 2 {
					CoordMode("Mouse", "Screen")
					MouseMove(initial_pos_x, initial_pos_y, 0)
					Click()
					line_tool_active := false
					click_index := 0
					initial_pos_x := 0
					initial_pos_y := 0
                    Send("{Escape}{Escape}{Escape}")
				} else {
					MsgBox("Must have 3 or more points to complete a path.")
				}
             } else {
                Send("{RButton}")
             }
    }
}

draw_path(command){
    static click_index
    static path_tool_active := false
    static initial_pos_x, initial_pos_y
    switch command{
        case "get-state":
            return path_tool_active
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
            Send("{Escape}{Escape}{Escape}")
        case "complete":
             if path_tool_active{
				if click_index > 1 {
					CoordMode("Mouse", "Screen")
                    MouseGetPos(&last_pox_x, &last_pos_y)
                    MouseMove(500, last_pos_y)
                    Click()
                    MouseMove(500, initial_pos_y)
                    Click()
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

toggle_simulation(title := "ESPRIT - "){
	PostMessage 0x111, 6268 , , , title 
}

stop_simulation(title := "ESPRIT - "){
	PostMessage 0x111, 6276 , , , title 
}

save_file(title := "ESPRIT - "){
	PostMessage 0x111, 57603 , , , title 
}

open_file(title := "ESPRIT - "){
	PostMessage 0x111, 57601 , , , title 
}

transformation_window(title := "ESPRIT - "){
	PostMessage 0x111, 57634 , , , title 
}

unsuppress_operation(){
    _id := WinGetID("Project Manager")
	PostMessage 0x111, 32792 , , "SysTreeView321", "ahk_id" _id
}

suppress_operation(){
    _id := WinGetID("Project Manager")
	PostMessage 0x111, 32770 , , "SysTreeView321", "ahk_id" _id
}

rebuild_operation(){
    _id := WinGetID("Project Manager")
	PostMessage 0x111, 32768 , , "SysTreeView321", "ahk_id" _id
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

    set_point(10, 5, 0)
    Sleep(50)

    set_point(-5, 5, 0)
    Sleep(50)

    set_point(-5, -5, 0)
    Sleep(50)

    set_point(10, -5, 0)
    Sleep(50)

    face()
    Sleep(50)

    set_point(5, 0, 0)
    Sleep(50)

    set_point(-5, 0, 0)
    Sleep(50)

    set_point(0, 5, 0)
    Sleep(50)

    set_point(0, -5, 0)
    Sleep(50)

    deg0()
    Sleep(50)

    WinClose("Point")
}

go_to_next_esprit(current_esp_id){
    esprit_ids := Map()
    static active_index := 1
    active_id := current_esp_id

    for this_id in WinGetList("ESPRIT - ") {
        esprit_ids[this_id] := this_id 
    }

    sorted_ids := []
    for k,v in esprit_ids {
        sorted_ids.Push(v)
    }

    for this_id in sorted_ids {
        if this_id == active_id {
            active_index := A_Index
        }
    }

    active_index += 1
    if active_index > sorted_ids.Length {
        active_index := 1
    }

    try {
        WinActivate("ahk_id" sorted_ids[active_index])
    } 
}

ds_startup_commands(esp_pid, esp_id){
	while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        try{
            win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
            if win_1 {
                ControlSend("{Enter}", , "ahk_id" win_1)
            }
        }
        
        try{
            win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
            if win_2 {
                ControlSend("{Enter}", , "ahk_id" win_2)
            }
        }

        try{
            win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
            if win_3 {
                ControlSend("{Enter}", , "ahk_id" win_3)
            }
        }
	}
    stl_rotate_id := WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
	deg0("ahk_id" esp_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        ; remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
    yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
    if yn != "Yes"{
        ExitApp
    }
    numOfSides := 3
    consolelog("[Tru-AHK] Rotate to desired angle and press either 3 or 4 for the side count")
    Loop {
        ih := InputHook("L1", "34{Numpad3}{Numpad4}{Enter}{NumpadEnter}{Space}{LShift}")
        ih.Start()
        ih.Wait()
        keyName := GetKeyName(ih.EndKey)
        if keyName == "3" or keyName == "Numpad3" or keyName == "Enter" or keyName == "NumpadEnter" or keyName == "Space"{
            numOfSides := 3
            break
        } else if keyName == "4" or keyName == "Numpad4" or keyName == "LShift"{
            numOfSides := 4
            break
        }
        consolelog("[Tru-AHK] Invalid input")
    }
    selected_view := get_current_angle("ahk_id" esp_id) - 7
    deg0("ahk_id" esp_id)
    WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("65 115")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
    Loop selected_view{
        ControlSend("{Down}", , "ahk_id" base_work_id)
    } 
    ControlSend("{Tab}{Tab}", , "ahk_id" base_work_id)
    if numOfSides == 3 {
        ControlSend("{Up}", , "ahk_id" base_work_id)
    }
    ControlSend("{Tab}{Tab}{Enter}", , "ahk_id" base_work_id)
	WinWaitClose("ahk_id" base_work_id)
}

asc_startup_commands(esp_pid, esp_id){
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
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
        ; remove_stl_file(STL_FILE_PATH "\" file_name_no_ext ".stl")
    }
	yn := show_custom_dialog("Is the connection correct?", "Tru-AHK", esp_id)
    if yn != "Yes"{
        ExitApp
    }
    consolelog("[Tru-AHK] Rotate to desired angle and press either 3 or 4 for the side count")
    numOfSides := 3
    Loop {
        ih := InputHook("L1", "34{Numpad3}{Numpad4}{Enter}{NumpadEnter}{Space}")
        ih.Start()
        ih.Wait()
        keyName := GetKeyName(ih.EndKey)
        if keyName == "3" or keyName == "Numpad3" or keyName == "Enter" or keyName == "NumpadEnter" or keyName == "Space"{
            numOfSides := 3
            break
        } else if keyName == "4" or keyName == "Numpad4" {
            numOfSides := 4
            break
        }
        consolelog("[Tru-AHK] Invalid input")
    }
    selected_view := get_current_angle("ahk_id" esp_id) - 7
    deg0("ahk_id" esp_id)
	WinActivate("ahk_id" stl_rotate_id)
	CoordMode("Mouse", "Client")
	Click("60 147")
	base_work_id := WinWaitActiveTitleWithPID(esp_pid, "Base Work Plane(Degree)")
    Loop selected_view{
        ControlSend("{Down}", , "ahk_id" base_work_id)
    } 
    ControlSend("{Tab}{Tab}", , "ahk_id" base_work_id)
    if numOfSides == 3 {
        ControlSend("{Up}", , "ahk_id" base_work_id)
    }
    ControlSend("{Tab}{Tab}{Enter}", , "ahk_id" base_work_id)
	WinWaitClose("ahk_id" base_work_id)
}

tl_aot_startup_commands(esp_pid, esp_id){
    while not WinExistTitleWithPID(esp_pid, "STL Rotate"){
        try{
            win_1 := WinActiveTitleWithPID(esp_pid, "esprit", "&Yes")
            if win_1 {
                ControlSend("{Enter}", , "ahk_id" win_1)
            }
        }
        
        try{
            win_2 := WinActiveTitleWithPID(esp_pid, "esprit", "OK")
            if win_2 {
                ControlSend("{Enter}", , "ahk_id" win_2)
            }
        }

        try{
            win_3 := WinActiveTitleWithPID(esp_pid, "Direction Check", "OK")
            if win_3 {
                ControlSend("{Enter}", , "ahk_id" win_3)
            }
        }
	}
    WinWaitActiveTitleWithPID(esp_pid, "STL Rotate")
    WinActivate("ahk_id" esp_id)
    deg0("ahk_id" esp_id)
    esp_title := WinGetTitle("ahk_id" esp_id)
    found_pos := RegExMatch(esp_title, "(?P<PDO>\w+-\w+-\d+)__\((?P<connection>[A-Za-z0-9;\-]+),(?P<id>\d+)\) ?\[?(?P<ug_values>[#0-9-=. ]+)?\]?[_0-9]*?(?P<file_type>\.\w+)", &sub_pat)
    if found_pos {
        file_name := SplitPath(STL_FILE_PATH "\" sub_pat[0], , , , &file_name_no_ext)
    }
}

align_tl_aot_cap(title := "ahk_exe esprit.exe"){
    WinWaitActive(title)
    esprit_title := WinGetTitle(title)
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

show_milling_tool(){
	PostMessage 0x111, 6278 , , , "ESPRIT"
}

double_sided_border(press_enter := False) {
	PostMessage(0x111, 3130, , , "ESPRIT")
	_id := WinWait("Extrude Boss/Cut",,0.1)
	
	try{
		ControlSetText(11, "Edit1", "ahk_id" _id)
		ControlSetText(1, "Edit4", "ahk_id" _id)
		ControlSetChecked(0,"Button8","ahk_id" _id)
		ControlChooseIndex(2,"ComboBox1","ahk_id" _id)
        if press_enter{
            ControlSend("{Enter}", "Button9", "ahk_id" _id)   
        }
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

cut_with_border() {
	PostMessage(0x111, 3130, , , "ESPRIT")
	_id := WinWait("Extrude Boss/Cut",,0.1)
	try{
		ControlChooseIndex(2,"ComboBox1","ahk_id" _id)
		ControlSetText(11, "Edit1", "ahk_id" _id)
		ControlSetText(4, "Edit4", "ahk_id" _id)
		ControlChooseIndex(2,"ComboBox2","ahk_id" _id)
		ControlSetChecked(1,"Button8","ahk_id" _id)
		ControlSetChecked(1,"Button3","ahk_id" _id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
	}
}

extrude_by(length) {
	PostMessage(0x111, 3130, , , "ESPRIT")
	_id := WinWait("Extrude Boss/Cut",,0.1)

	try{
		ControlSetText(length, "Edit1", "ahk_id" _id)
		ControlSetChecked(0,"Button2", "ahk_id" _id)
		ControlChooseIndex(1,"ComboBox1","ahk_id" _id)
	} catch TargetError as err {
		BlockInput("MouseMoveOff")
        consolelog("[Tru-AHK] No geometry selected")
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
        return "" 
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

enable_layer(layer_name) {
    ControlChooseString(layer_name, "ComboBox2", "ESPRIT - ")
}

create_layer(layer_name) {
    PostMessage 0x111, 10032, , , "Layers" 
    WinWait "Add layer"
    ControlSetText(layer_name, "Edit1", "Add layer")
    ControlSend("{Enter}", "Button1", "Add layer")
}

delete_layer(layer_name) {
    try {
        ControlChooseString(layer_name, "ListBox1", "Layers")
        ControlSend("{Home}", "ListBox1", "Layers")
        Sleep(100)
        Loop {
            choice := ControlGetChoice("ListBox1", "Layers")
            current_layer_name := StrSplit(choice, " ")[2]
            if current_layer_name == "'" layer_name "'" {
                break
            }
            ControlSend("{Down}", "ListBox1", "Layers")
            Sleep(1)
        }
        PostMessage 0x111, 10029, , , "Layers" 
        PostMessage 0x111, 10030, , , "Layers" 
        id_ := WinWait("esprit")
        ControlClick("Button1", "ahk_id" id_)
        ControlSend("{Enter}", "Button1","ahk_id" id_)
    } catch {
        return 0
    }
}

smash_selection(tolerance, mid_face_angle) {
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")

    ControlChooseString("Smash", "ComboBox1", "ahk_class #32770")
    ControlSetText(tolerance, "Edit25", "ahk_class #32770")
    ControlSetText(mid_face_angle, "Edit26", "ahk_class #32770")
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
