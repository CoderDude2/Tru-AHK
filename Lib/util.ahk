#Requires AutoHotkey v2.0

WM_COPYDATA := 0x004A
PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
PREFS_DIRECTORY := A_AppData "\tru-ahk"

class EspritInfo{
    esp_pid := unset
    esp_id := unset

    Step3Tab := 1
    Step3Tab1Deg := 0
    Step3Tab2Deg := 0
    Step3Tab3Deg := 0

    Step2Complete := false
    Step3Saved := false
    Step5Saved := false
    MarginsSaved := false
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

is_file_completed(file_name){
    if FileExist("C:\Users\TruUser\AppData\Roaming\TruCamAddIn\processed_files.txt"){
        Loop read, "C:\Users\TruUser\AppData\Roaming\TruCamAddIn\processed_files.txt"{
            Loop parse, A_LoopReadLine, "`n", "`r"{
                SplitPath(A_LoopField, &name)
                if file_name == name{
                    return true
                }
            }
        }
    }

    return false
}

get_stl_path(){
	stl_path := IniRead(PREFS_FILE_PATH, "locations", "stl_path")
	return stl_path
}

get_next_file(){
    Loop Files, get_stl_path() "\*", "F"{
        if InStr(A_LoopFileName, ".stl") and not is_file_completed(A_LoopFileName){
            return A_LoopFileName
        }
    }

    return ""
}

mark_file_as_completed(file_name){
    full_name := get_stl_path() "\" file_name
    FileAppend(full_name "`n", "C:\Users\TruUser\AppData\Roaming\TruCamAddIn\processed_files.txt", "UTF-8")
}

recv_WM_COPYDATA(wParam, lParam, msg, hwnd){
    StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")
    CopyOfData := StrGet(StringAddress)
    return True
}

send_WM_COPYDATA(StringToSend, TargetTitle){
    CopyDataStruct := Buffer(3 * A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("ptr", 1, CopyDataStruct, 0)
    NumPut("ptr", SizeInBytes, CopyDataStruct, A_PtrSize)
    NumPut("ptr", StrPtr(StringToSend), CopyDataStruct, A_PtrSize * 2)

    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows True
    SetTitleMatchMode 2

    TimeOutTime := 20000

    RetValue := SendMessage(WM_COPYDATA, 0, CopyDataStruct.Ptr, , "HiddenWindow" WinGetID(TargetTitle),,,,TimeOutTime)

    DetectHiddenWindows Prev_DetectHiddenWindows
    SetTitleMatchMode Prev_TitleMatchMode

    return RetValue
}