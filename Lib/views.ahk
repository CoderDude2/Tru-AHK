update_angle(angle_index, title?){
    if not IsSet(title) {
        title := "A"
    }
	try {
		ControlChooseIndex(angle_index, "ComboBox1", title)
	} catch TargetError as err{

	}	
}

update_angle_deg(degree){
	if(degree >= 0 && degree < 360){
		index := (degree / 10) + 7
		update_angle(index)
	}
}

get_current_angle(title?) {
	MsgReply := SendMessage(0x0147, 0, 0, "ComboBox1", title?) ; Uses CB_GETCURSEL command to retrieve the current selected value in ComboBox1. This outputs to the ErrorLevel.
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

face(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(5)
}

rear(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(6)
}

deg0(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(7)
}

deg90(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(16)
}

deg180(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(25)
}

deg270(title?) {
    if not IsSet(title) {
        title := "ESPRIT - "
    }
	WinActivate(title)
	update_angle(34)
}
