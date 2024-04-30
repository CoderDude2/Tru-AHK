#Requires Autohotkey v2.0
#SingleInstance Force

#Include "commands.ahk"
#Include "updater.ahk"

; if(FileExist(A_ScriptDir "\resources\prefs.ini")){
;     remote_path := IniRead(A_ScriptDir "\resources\prefs.ini")
; } else {
;     IniWrite()
; }


root := Gui()
root.Opt("+Resize")
root.Title := "Tru-AHK Dashboard"
root.show("w200 h300")

root.Add("GroupBox","r2 xm ym Section w175 h200","Test")
root.Add("Text","xs+5 ys+20","An Update is available")
root.Add("Button",,"Update Now")

root.Add("Text",,"F12 Mode")
root.Add("DropDownList","vf12_options",["Disabled","Active Instance", "All Instances"])

root.Add("CheckBox","h20","W as Delete Key")

root.OnEvent("Close", OnClose)
onClose(*){
    ExitApp
}

Gui_Size(thisGui, MinMax, Width, Height){
    if MinMax = -1
        return
}