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

check_for_tru_cam_addin_update(){
    remote_name := unset
    local_name := unset
    Loop Files, "\\192.168.1.100\Trubox\Tru Dept. - CAM\Development\*", "DF"{
        If InStr(A_LoopFileName, "TruCamAddIn"){
            remote_name := A_LoopFileName
            break
        }
    }

    Loop Files, "C:\Program Files (x86)\D.P.Technology\ESPRIT\AddIns\*", 'DF'{
        If InStr(A_LoopFileName, "TruCamAddIn"){
            local_name := A_LoopFileName
            break
        }
    }

    if not IsSet(local_name){
        return true
    }

    return remote_name != local_name
}

update_tru_cam_addin(){
    local_path := unset
    remote_path := unset
    remote_name := unset

    Loop Files, "\\192.168.1.100\Trubox\Tru Dept. - CAM\Development\*", "DF"{
        If InStr(A_LoopFileName, "TruCamAddIn"){
            remote_path := A_LoopFileFullPath
            remote_name := A_LoopFileName
            break
        }
    }

    Loop Files, "C:\Program Files (x86)\D.P.Technology\ESPRIT\AddIns\*", 'DF'{
        If InStr(A_LoopFileName, "TruCamAddIn"){
            local_path := A_LoopFileFullPath
            break
        }
    }

    Run("*RunAs " local_path "\unregister.bat")

    If IsSet(local_path) and DirExist(local_path) {
        DirDelete(local_path, true)
    }

    new_local_path := "C:\Program Files (x86)\D.P.Technology\ESPRIT\AddIns\" remote_name

    RegCreateKey("HKEY_LOCAL_MACHINE\Software\Wow6432Node\D.P.Technology\esprit\AddIns\TruCamAddIn.Connect")
    RegWrite("A bridge between Esprit and Tru-AHK.", "REG_SZ", "HKEY_LOCAL_MACHINE\Software\Wow6432Node\D.P.Technology\esprit\AddIns\TruCamAddIn.Connect", "Description")
    RegWrite("TruCamAddIn", "REG_SZ", "HKEY_LOCAL_MACHINE\Software\Wow6432Node\D.P.Technology\esprit\AddIns\TruCamAddIn.Connect", "FriendlyName")
    RegWrite(0x0000001, "REG_DWORD", "HKEY_LOCAL_MACHINE\Software\Wow6432Node\D.P.Technology\esprit\AddIns\TruCamAddIn.Connect", "LoadBehavior")
    DirCopy(remote_path, new_local_path, true)
    Run("*RunAs " new_local_path "\register.bat")
}