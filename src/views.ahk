#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

class views {
	update_angle(angle_index) {
		WinGetClass, deg_class, A
		Control, Choose, %angle_index%, ComboBox1, ahk_class %deg_class%
	}

	get_current_angle() {
		SendMessage, 0x0147, 0, 0, ComboBox1, ESPRIT ; Uses CB_GETCURSEL command to retrieve the current selected value in ComboBox1. This outputs to the ErrorLevel.
		current_angle := ErrorLevel<<32>>32 ; Convert UInt to Int to have -1 if there is no item selected.
		current_angle += 1
		return current_angle
	}

	increment_10_degrees() {
		new_angle := this.get_current_angle() + 1
		if(new_angle > 42){
			new_angle := 7
		}
		this.update_angle(new_angle)
	}

	decrement_10_degrees(){
		new_angle := this.get_current_angle() - 1
		if(new_angle < 7){
			new_angle := 42
		}

		this.update_angle(new_angle)
	}

	increment_90_degrees(){
		new_angle := this.get_current_angle() + 9
		if (new_angle > 42){
			new_angle := 6 + new_angle - 42
		}
		this.update_angle(new_angle)
	}

	decrement_90_degrees(){
		new_angle := this.get_current_angle() - 9
		if(new_angle < 7) {
			new_angle := 42 - (-1 * new_angle + 7 - 1)
		}
		this.update_angle(new_angle)
	}
}

class Deg {
	FACE() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 5, ComboBox1, ahk_class %deg_class%
	}

	REAR() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 6, ComboBox1, ahk_class %deg_class%
	}

	deg0() {
		global current_value := 7
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 7, ComboBox1, ahk_class %deg_class%
	}

	deg90() {
		global current_value := 16
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 16, ComboBox1, ahk_class %deg_class%
	}

	deg180() {
		global current_value := 25
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 25, ComboBox1, ahk_class %deg_class%
	}

	deg270() {
		global current_value := 34
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 34, ComboBox1, ahk_class %deg_class%
	}
}