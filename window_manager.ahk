#Requires Autohotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

class EspritInstance{
    __New(main_window_id){
        this.main_window_id := main_window_id
        this.esprit_pid := unset

        this.step_3_window_id := unset
        this.step_5_window_id := unset
        this.text_window_id := unset

        this.extrude_window_id := unset
        this.transformation_window_id := unset
    }
}

get_instances(){
    esp_window_ids := WinGetList("ESPRIT")
    esp_instances := []
    for this_id in esp_window_ids{
        ; WinActivate("ahk_id" this_id)
        esp_instance := EspritInstance(this_id)
        esp_instances.Push(esp_instance)
    }

    return esp_instances
}



~^Numpad3::{
    instances := get_instances()
    active_instance := WinActive("ESPRIT")
    MsgBox(WinGetPID("ahk_id" active_instance))
}

; TODO
; 1. Get all esprit instances with the ESPRIT title
; 2. Track all of their ids for the main window and sub windows
; 3. Store them to objects and actively update them as the various windows are used
; 4. When an instance is closed delete the corresponding object
; 5. Run as a background process