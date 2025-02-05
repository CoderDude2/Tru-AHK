#Requires AutoHotkey v2.0
#SingleInstance Force

; SetTimer(win_move_msgbox, -5)
; MsgBox(,"Decrease Latency", "")
; ExitApp
; Return

; win_move_msgbox(){
;     ID:=WinExist("Decrease Latency")
;     WinMove(50, 50, ,, "ahk_id" ID)
; }

; Open VB Editor

open_file(file_path){
	PostMessage 0x111, 57601 , , , "ESPRIT"
    WinWaitActive("Open")
    ControlSetText(file_path, "Edit1", "ahk_class #32770")
    ControlSend("{Enter}", "Button2","ahk_class #32770")
}

BASIC_SETTING_PATH := "C:\Users\TruUser\Desktop\작업\작업저장"

Loop Files, BASIC_SETTING_PATH "\*"{
    file_name := StrSplit(A_LoopFileName, ".")[1]
    WinActivate("ESPRIT - ")
    open_file(A_LoopFileFullPath)
    WinWait("ESPRIT - [" A_LoopFileName "]")
    WinWait("Microsoft Visual Basic for Applications - " file_name)
    WinActivate("Microsoft Visual Basic for Applications - " file_name)
    While Not InStr(ControlGetText("PROJECT1"), " VBAProject3"){
        Send("{Down}")
        Sleep(50)
    }
    Loop Files, "C:\Users\TruUser\Desktop\Modules\*"{
        WinWaitActive("Microsoft Visual Basic for Applications - " file_name)
        Send("^m")
        WinWait("Import File")
        ControlSendText("C:\Users\TruUser\Desktop\Modules\" A_LoopFileName, "Edit1")
        ControlSend("{Enter}", "Button2")
    }
}

^l::{
    SetTitleMatchMode(2)
    PostMessage(0x111, 6469, , ,"ESPRIT - ")
    WinWait("Microsoft Visual Basic for Applications")
    WinActivate("Microsoft Visual Basic for Applications")


    ; Ensure we go to the local project section
    While Not InStr(ControlGetText("PROJECT1"), " VBAProject3"){
        Send("{Down}")
        Sleep(20)
    }

    ; Import the Macros:
    Loop Files, "C:\Users\TruUser\Desktop\Modules\*"{
        Send("^m")
        WinWait("Import File")
        ControlSendText("C:\Users\TruUser\Desktop\Modules\" A_LoopFileName, "Edit1")
        ControlSend("{Enter}", "Button2")
        Sleep(500)
    }
    WinHide("Microsoft Visual Basic for Applications")
    
    ; Send("{LButton}")
}