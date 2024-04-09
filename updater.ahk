#Requires Autohotkey v2.0
SetWorkingDir A_ScriptDir

; IniWrite "1.3.1", "config.ini", "info", "version"
online_version := IniRead("C:\Users\TruUser\Desktop\AHK_Update\config.ini", "info", "version")
local_version := IniRead("config.ini", "info", "version")

check_for_update(){
    if(online_version != local_version){
        return True
    }

    return False
}

update(){
    Loop Files, "C:\Users\TruUser\Desktop\AHK_Update\*", "DF"{
        if(f_attr := FileExist(A_ScriptDir "\" A_LoopFileName)){
            if(f_attr == "D"){
                DirCopy A_LoopFileFullPath, A_ScriptDir "\" A_LoopFileName, true
            } else {
                FileMove A_ScriptDir "\" A_LoopFileName, A_ScriptDir "\old_" A_LoopFileName
                FileCopy A_LoopFileFullPath, A_ScriptDir
                if(A_LoopFileExt == "exe"){
                    Run A_ScriptDir "\" A_LoopFileName
                }
                Sleep(500)
                FileDelete "old_" A_LoopFileName
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
}