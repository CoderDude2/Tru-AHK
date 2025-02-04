#Requires AutoHotkey v2.0

; SetTimer(win_move_msgbox, -5)
; MsgBox(,"Decrease Latency", "")
; ExitApp
; Return

; win_move_msgbox(){
;     ID:=WinExist("Decrease Latency")
;     WinMove(50, 50, ,, "ahk_id" ID)
; }

; Open VB Editor
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