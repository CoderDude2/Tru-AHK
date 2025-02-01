#Requires AutoHotkey v2.0

SetTimer(win_move_msgbox, -5)
MsgBox(,"Decrease Latency", "")
ExitApp
Return

win_move_msgbox(){
    ID:=WinExist("Decrease Latency")
    WinMove(50, 50, ,, "ahk_id" ID)
}