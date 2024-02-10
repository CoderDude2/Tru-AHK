#SingleInstance Force
SetWorkingDir A_ScriptDir

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
	PostMessage 0x111, 32792 , , "SysTreeView321", "ESPRIT"
}

suppress_operation(){
	PostMessage 0x111, 32770 , , "SysTreeView321", "ESPRIT"
}

rebuild_operation(){
	PostMessage 0x111, 32768 , , "SysTreeView321", "ESPRIT"
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

center_border_3() {
	WinActivate("ESPRIT")
	PostMessage(0x111, 3130, , , "ESPRIT")

	WinWaitActive("ahk_class #32770")
	try{
		ControlSetText(6, "Edit1", "ahk_class #32770")
		ControlSetChecked(0,"Button2","ahk_class #32770")
		ControlChooseIndex(1,"ComboBox1","ahk_class #32770")
	} catch TargetError as err {
		MsgBox "Select a line first"
	}
}

draw_straight_border(){
	BlockInput("MouseMove")
	line_tool()
	Click("Left")
	Send("20{Enter}0{Enter}{Esc}")
	Click("Left 2")
	Sleep(100)
	double_sided_border()
	BlockInput("MouseMoveOff")
	Send("{Enter}")
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

    ControlChooseIndex(5,"ComboBox1","ahk_class #32770")
    ControlSetChecked(1,"Button7","ahk_class #32770")

    ControlSetText(Round(x, 4), "Edit2", "ahk_class #32770")
    ControlSetText(Round(y, 4), "Edit3", "ahk_class #32770")
    ControlSetText(Round(z, 4), "Edit4", "ahk_class #32770")

    Send("{Enter}")
}

rotate_selection(degrees, update_on_click:=False){
    WinActivate("ESPRIT")
    transformation_window()
    WinWaitActive("ahk_class #32770")
    ControlChooseIndex(9,"ComboBox1","ahk_class #32770")
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
    ControlChooseIndex(7,"ComboBox1","ahk_class #32770")
    ControlSetText(Round(scale, 4), "Edit8", "ahk_class #32770")
    Send("{Enter}")
}