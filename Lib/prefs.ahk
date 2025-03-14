#Requires AutoHotkey v2.0

PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
PREFS_DIRECTORY := A_AppData "\tru-ahk"

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

get_language(){
    default_language := ""
    switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "language", "value")
            default_language := "en"
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            default_language := "ko"
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            default_language := "ko"
	} 
	language := IniRead(prefs_file_path, "language", "value", default_language)
	return language
}

get_system_language(){
    default_language := ""
    switch A_Language{
		case 0409:
			IniWrite("en", PREFS_FILE_PATH, "language", "value")
            default_language := "en"
		case 0012:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            default_language := "ko"
		case 0412:
			IniWrite("ko", PREFS_FILE_PATH, "language", "value")
            default_language := "ko"
	} 
    system_language := IniRead(prefs_file_path, "system_language", "value", default_language)
	return system_language
}