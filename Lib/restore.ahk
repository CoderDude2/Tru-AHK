#SingleInstance Force
#Requires Autohotkey v2.0

#Include "prefs.ahk"

ESP_DIRECTORY := "C:\Users\TruUser\Desktop\작업\작업저장"
ESP_CHECKPOINT_DIRECTORY := PREFS_DIRECTORY "\checkpoints"

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
    MsgBox(file_name "\" tag "\" file_name)
    if FileExist(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name){
        FileCopy(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name, ESP_DIRECTORY, true)
    }
}

onCheckpointListboxDoubleClick(gui_element, dbl_click_index, file_name, *){
    tag := ""

    if InStr(gui_element.Text, "`n"){
        tag := SubStr(gui_element.Text, 1, StrLen(gui_element.Text) - 1)
    } else {
        tag := gui_element.Text
    }
   MsgBox(tag, gui_element.Value " " file_name)
   restore_checkpoint(tag, file_name)
}
; create_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")
; restore_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")

#HotIf WinActive("ESPRIT - ")
^f18::{
    esprit_title := WinGetTitle("A")
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
    
    if FoundPos{
        inp := InputBox("Enter a tag for the checkpoint", "New Checkpoint")
        if inp.Value != "" {
            create_checkpoint(inp.Value, SubPat[0])
        }
    }
}

^+r::{
    esprit_title := WinGetTitle("A")
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
    
    if FoundPos {
        root := Gui()
        FileList := []
        Loop Files, ESP_CHECKPOINT_DIRECTORY "\" SubPat[0] "\*", "D"{
            FileList.InsertAt(1, A_LoopFileName "`n")
        }
        root.AddText(, "Select a checkpoint to restore from")
        checkpoint_listbox := root.AddListBox("r5 vCheckpointChoice", FileList) 
        checkpoint_listbox.OnEvent("DoubleClick", onCheckpointListboxDoubleClick.Bind(,, SubPat[0]))

        root.Show()
        WinWaitClose("ahk_id " root.Hwnd)
    }
}
