#Requires AutoHotkey v2.0

PREFS_DIRECTORY := A_AppData "\tru-ahk"
PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"

create_default_prefs_file(){
	DirCreate(A_AppData "\tru-ahk\")
	IniWrite("All Instances", PREFS_FILE_PATH, "f12_mode", "value")
	IniWrite("Line and Border", PREFS_FILE_PATH, "e_key_functionality", "value")
	IniWrite(true, PREFS_FILE_PATH, "w_as_delete", "value")
	IniWrite(true, PREFS_FILE_PATH, "auto_recycle_STL", "value")
	IniWrite("", PREFS_FILE_PATH, "macro_bar_control", "control")
	IniWrite("", PREFS_FILE_PATH, "project_manager_control", "control")
	IniWrite(true, PREFS_FILE_PATH, "project_manager_control", "is_attached")
	IniWrite("C:\Users\" A_UserName "\Desktop\Basic Setting", PREFS_FILE_PATH, "locations", "basic_setting_path")
	IniWrite("C:\Users\" A_UserName "\Desktop\작업\스캔파일", PREFS_FILE_PATH, "locations", "stl_path")
	switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "language", "value")
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
	}
	switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "system_language", "value")
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "system_language", "value")
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "system_language", "value")
	}
}

if not FileExist(PREFS_FILE_PATH){
    create_default_prefs_file()
}

get_language(){
	language := IniRead(prefs_file_path, "language", "value")
	return language
}

get_system_language(){
    system_language := IniRead(prefs_file_path, "system_language", "value")
	return system_language
}

USER_LANGUAGE := get_language()
SYSTEM_LANGUAGE := get_system_language()

REMOTE_PATH := IniRead("config.ini", "info", "remote_path")

if USER_LANGUAGE == "en" {
    extrude_window_name := "Extrude Boss/Cut"
} else if USER_LANGUAGE == "ko" {
    extrude_window_name := "보스 돌출/잘라내기"
}

if SYSTEM_LANGUAGE == "ko"{
    open_file_dialog := "열기"
    open_button_text := "열기(&O)"
    esprit_are_you_sure_text := "예(&Y)"
} else {
    open_file_dialog := "Open"
    open_button_text := "&Open"
    esprit_are_you_sure_text := "&Yes"
}