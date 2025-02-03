#Requires AutoHotkey v2.0

class EspritInstance{
    __new(pid){
        this.esprit_pid := pid
    }
}

class WindowManager{
    __new(){
        this.esprit_instance_map := Map()
    }

    scan_windows(){
        ids := WinGetList("ESPRIT - ")
        for _id in ids{
            pid := WinGetPID("ahk_id" _id)
            if not this.esprit_instance_map.Has(pid){
                this.esprit_instance_map[pid] := EspritInstance(pid)
            }
        }
    }
}