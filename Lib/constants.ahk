#Requires AutoHotkey v2.0

get_language(){
	language := IniRead(prefs_file_path, "language", "value")
	return language
}

PREFS_DIRECTORY := A_AppData "\tru-ahk"
PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
USER_LANGUAGE := get_language()
REMOTE_PATH := IniRead("config.ini", "info", "remote_path")

if USER_LANGUAGE == "en" {
    extrude_window_name := "Extrude Boss/Cut"
} else if USER_LANGUAGE == "ko" {
    extrude_window_name := "보스 돌출/잘라내기"
}