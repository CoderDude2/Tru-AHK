#Requires Autohotkey v2.0
#SingleInstance Force
#WinActivateForce
DetectHiddenWindows true

go_to_next_esprit(current_esp_id){
    esprit_ids := Map()
    static active_index := 1
    active_id := current_esp_id

    for this_id in WinGetList("ESPRIT - ") {
        esprit_ids[this_id] := this_id 
    }

    sorted_ids := []
    for k,v in esprit_ids {
        sorted_ids.Push(v)
    }

    for this_id in sorted_ids {
        if this_id == active_id {
            active_index := A_Index
        }
    }

    active_index += 1
    if active_index > sorted_ids.Length {
        active_index := 1
    }

    try {
        WinActivate("ahk_id" sorted_ids[active_index])
    } 
}

^Tab::{
    if WinExist("ESPRIT - "){
        current_id := WinGetID(WinGetTitle("ESPRIT - "))
        go_to_next_esprit(current_id)
    } 
}