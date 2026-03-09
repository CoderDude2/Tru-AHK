#Requires AutoHotkey v2.0

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
    if FoundPos {
        return SubPat[1]
    }
    return 0
}

get_connection_type(title){
    FoundPos := RegExMatch(title, "\(([A-Za-z0-9;-]+),", &SubPat)
    if FoundPos {
        return StrSplit(SubPat[1], "-")[1]
    }
    return 0
}