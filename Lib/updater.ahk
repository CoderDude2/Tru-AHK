#Requires Autohotkey v2.0
SetWorkingDir A_ScriptDir

check_for_update(local_path, online_path){
    online_version := IniRead(online_path "\config.ini", "info", "version")
    local_version := IniRead(local_path "\config.ini", "info", "version")

    if(online_version != local_version){
        return True
    }

    return False
}

update(online_path){
    Loop Files, online_path "\*", "DF"{
        if(f_attr := FileExist(A_ScriptDir "\" A_LoopFileName)){
            if(f_attr == "D"){
                DirCopy A_LoopFileFullPath, A_ScriptDir "\" A_LoopFileName, true
            } else {
                FileMove A_ScriptDir "\" A_LoopFileName, A_ScriptDir "\old_" A_LoopFileName
                FileCopy A_LoopFileFullPath, A_ScriptDir
                if(A_LoopFileExt != "exe"){
                     FileDelete "old_" A_LoopFileName
                }
            }
        } else {
            f_attr := FileGetAttrib(A_LoopFileFullPath)

            if(f_attr = "D"){
                DirCopy A_LoopFileFullPath, A_ScriptDir "\" A_LoopFileName
            } else {
                FileCopy A_LoopFileFullPath, A_ScriptDir
            }
        }
    }
    IniWrite("True", "config.ini", "info", "show_changelog")
    Sleep(300)

    if(FileExist(A_ScriptDir "\old_text_x.exe") and FileExist(A_ScriptDir "\text_x.exe")){
        Run A_ScriptDir "\text_x.exe"
        Sleep(300)
        FileDelete A_ScriptDir "\old_text_x.exe"
    }

    if(FileExist(A_ScriptDir "\old_master_switch.exe") and FileExist(A_ScriptDir "\master_switch.exe")){
        Run A_ScriptDir "\master_switch.exe"
        Sleep(300)
        FileDelete A_ScriptDir "\old_master_switch.exe"
    }
}