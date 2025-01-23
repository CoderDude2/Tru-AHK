#Requires AutoHotkey v2.0

#include "constants.ahk"

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