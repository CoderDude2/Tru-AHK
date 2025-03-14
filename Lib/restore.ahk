#Requires Autohotkey v2.0

PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
ESP_DIRECTORY := "C:\Users\TruUser\Desktop\작업\작업저장"
ESP_CHECKPOINT_DIRECTORY := A_AppData "\tru-ahk\checkpoints"

if not DirExist(ESP_CHECKPOINT_DIRECTORY){
    DirCreate(ESP_CHECKPOINT_DIRECTORY)
}

create_checkpoint(tag, file_name){
    esp_file_path := ESP_DIRECTORY "\" file_name
    if not FileExist(esp_file_path){
        return
    }

    if not DirExist(ESP_CHECKPOINT_DIRECTORY "\" file_name){
        DirCreate(ESP_CHECKPOINT_DIRECTORY "\" file_name)
    }

    if not DirExist(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag){
        DirCreate(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag)
    }

    if FileExist(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name) {
        yn := MsgBox("Checkpoint already exist, do you want to overwrite it?", , "YesNo")
        if yn == "No"{
            return
        }
    }

    FileCopy(esp_file_path, ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag, true)
}

; Returns the checkpoint with name
restore_checkpoint(tag, file_name) {
    if FileExist(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name){
        FileCopy(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name, ESP_DIRECTORY, true)
    }
}

; create_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")
; restore_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")

^f18::{
    inp := InputBox("Enter a tag for the checkpoint", "New Checkpoint")
    MsgBox(inp.Value == "")
}