#Requires Autohotkey v2.0


PREFS_FILE_PATH := A_AppData "\tru-ahk\prefs.ini"
PREFS_DIRECTORY := A_AppData "\tru-ahk"

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
    if FileExist(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name){
        FileCopy(ESP_CHECKPOINT_DIRECTORY "\" file_name "\" tag "\" file_name, ESP_DIRECTORY, true)
    }
}

load_esp_file(file_name){
    PostMessage 0x111, 57601 , , , "ESPRIT"
    WinWait("ahk_class #32770", "&Open")
    WinActivate("ahk_class #32770", "&Open")
    ControlSetText(ESP_DIRECTORY "\" file_name, "Edit1", "ahk_class #32770")
    ControlSetChecked(0,"Button5","ahk_class #32770")
    ControlSend("{Enter}", "Button2","ahk_class #32770")
}



restore_gui(){
    esprit_title := WinGetTitle("A")
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
    tag := ""
    
    if FoundPos{
        root := Gui()
        root.AddText(, "Select a checkpoint to restore from")
        FileList := []
        Loop Files, ESP_CHECKPOINT_DIRECTORY "\" SubPat[0] "\*", "D"{
            FileList.InsertAt(1, A_LoopFileName "`n")
        }
        checkpoint_listbox := root.AddListBox("r5 vCheckpointChoice", FileList) 

        onCheckpointListboxDoubleClick(gui_element, dbl_click_index, file_name, *){

            if InStr(gui_element.Text, "`n"){
                tag := SubStr(gui_element.Text, 1, StrLen(gui_element.Text) - 1)
            } else {
                tag := gui_element.Text
            }
            WinClose("ahk_id" root.Hwnd)
        }
        
        checkpoint_listbox.OnEvent("DoubleClick", onCheckpointListboxDoubleClick.Bind(,, SubPat[0]))

        root.Show()
        WinWaitClose("ahk_id " root.Hwnd)
    }
    
    return tag
}
; create_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")
; restore_checkpoint("front_turning", "PDO-PL-0556164__(ZV3-CS-TA10,6164).esp")

; #HotIf WinActive("ahk_exe esprit.exe")
; ^f18::{
;     esprit_title := WinGetTitle("ESPRIT - ")
;     FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
;     
;     if FoundPos{
;         inp := InputBox("Enter a tag for the checkpoint", "New Checkpoint")
;         if inp.Value != "" {
;             create_checkpoint(inp.Value, SubPat[0])
;         }
;     }
; }
; 
; ^+r::{
;     esprit_title := WinGetTitle("A")
;     FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)
; 
;     tag := restore_gui()
;     if tag != ""{
;         restore_checkpoint(tag, SubPat[0])
;         load_esp_file(SubPat[0])
;     }
; }
; 
save_and_create_checkpoint(tag, esprit_id){
    esprit_title := WinGetTitle("ahk_id " esprit_id)
    FoundPos := RegExMatch(esprit_title, "(\w+-\w+-\d+)__\(([A-Za-z0-9;\-]+),(\d+)\) ?\[?([#0-9-=. ]+)?\]?[_0-9]*?(\.\w+)", &SubPat)

    file_time := FileGetTime(ESP_DIRECTORY "\" SubPat[0])

    ; save the file
    PostMessage 0x111, 57603 , , , "ahk_id " esprit_id
    
    while file_time == FileGetTime(ESP_DIRECTORY "\" SubPat[0]) {
        Sleep(1)
    }
    
    create_checkpoint(tag, SubPat[0])
}
