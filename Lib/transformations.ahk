#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

transform_selection(x := 0, y := 0, z := 0){
    WinActivate, ESPRIT
    tools.transformation_window()
    WinWaitActive, ahk_class #32770
    Control, Check, , Button7, ahk_class #32770
    Sleep 100
    Control, Choose, 5, ComboBox1, ahk_class #32770
    ControlSetText, Edit2, %x%, ahk_class #32770
    ControlSetText, Edit3, %y%, ahk_class #32770
    ControlSetText, Edit4, %z%, ahk_class #32770
    Send {Enter}
}

rotate_selection(degrees, update_on_click=False){
    WinActivate, ESPRIT
    tools.transformation_window()
    WinWaitActive, ahk_class #32770
    Control, Choose, 9, ComboBox1, ahk_class #32770
    ControlSetText, Edit6, %degrees%, ahk_class #32770
    if(update_on_click = True){
        Control, UnCheck, , Button10, ahk_class #32770
    } else {
        Control, Check, , Button10, ahk_class #32770
    }
    Send {Enter}
}

scale_selection(scale){
    WinActivate, ESPRIT
    tools.transformation_window()
    WinWaitActive, ahk_class #32770
    Control, Choose, 7, ComboBox1, ahk_class #32770
    ControlSetText, Edit8, %scale%, ahk_class #32770
    Send {Enter}
}