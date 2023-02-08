#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

current_value := 7
min_value := 7
max_value := 42

update_angle(angle_index) {
	WinGetClass, deg_class, A
	Control, Choose, %angle_index%, ComboBox1, ahk_class %deg_class%
}

get_current_angle() {
	WinGetClass, deg_class, A
	ControlGet, string_combobox, choice, , combobox1, ahk_class %deg_class%
	ControlGet, current_angle, findstring, %string_combobox%, combobox1, ahk_class %deg_class%
	return current_angle
}

increment_10_degrees() {
	new_angle := get_current_angle() + 1
	if(new_angle > 42){
		new_angle := 7
	}
	update_angle(new_angle)
}

increment_90_degrees()

decrement_10_degrees(){
	new_angle := get_current_angle() - 1
	if(new_angle < 7){
		new_angle := 42
	}
	update_angle(new_angle)
}

; increment_90_degrees:
; 	current_value := current_value + 9
; 	if current_value > %max_value%
; 		current_value := min_value + (current_value - max_value - 1)
; 	activate()
; 	return

; decrement_90_degrees:
; 	current_value := current_value - 9
; 	if current_value < %min_value%
; 		current_value := max_value - (-1 * current_value + min_value - 1)
; 	activate()
	; return

class Deg  ;;; shortcut keys to deg views
{
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