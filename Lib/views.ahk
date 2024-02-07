update_angle(angle_index){
	deg_class := WinGetClass("A")
	try {
		ControlChooseIndex(angle_index, "ComboBox1", "ahk_class " deg_class)
	} catch TargetError as err{

	}	
}

update_angle_deg(degree){
	if(degree >= 0 && degree < 360){
		index := (degree / 10) + 7
		update_angle(index)
	}
}

get_current_angle() {
	MsgReply := SendMessage(0x0147, 0, 0, "ComboBox1", "ESPRIT") ; Uses CB_GETCURSEL command to retrieve the current selected value in ComboBox1. This outputs to the ErrorLevel.
	current_angle := MsgReply<<32>>32 ; Convert UInt to Int to have -1 if there is no item selected.
	current_angle += 1
	return current_angle
}

increment_10_degrees() {
	new_angle := get_current_angle() + 1
	if(new_angle > 42){
		new_angle := 7
	}
	update_angle(new_angle)
}

decrement_10_degrees(){
	new_angle := get_current_angle() - 1
	if(new_angle < 7){
		new_angle := 42
	}

	update_angle(new_angle)
}

increment_90_degrees(){
	new_angle := get_current_angle() + 9
	if (new_angle > 42){
		new_angle := 6 + new_angle - 42
	}
	update_angle(new_angle)
}

decrement_90_degrees(){
	new_angle := get_current_angle() - 9
	if(new_angle < 7) {
		new_angle := 42 - (-1 * new_angle + 7 - 1)
	}
	update_angle(new_angle)
}

face() {
	WinActivate("ESPRIT")
	update_angle(5)
}

rear() {
	WinActivate("ESPRIT")
	update_angle(6)
}

deg0() {
	WinActivate("ESPRIT")
	update_angle(7)
}

deg90() {
	update_angle(16)
}

deg180() {
	WinActivate("ESPRIT")
	update_angle(25)
}

deg270() {
	WinActivate("ESPRIT")
	update_angle(34)
}