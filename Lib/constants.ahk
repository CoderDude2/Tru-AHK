#Requires AutoHotkey v2.0

get_language(){
	language := IniRead(prefs_file_path, "language", "value")
	return language
}

PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
USER_LANGUAGE := get_language()
