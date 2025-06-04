#Requires AutoHotkey v2.0
#SingleInstance Force
DetectHiddenWindows true
SetDefaultMouseSpeed 0

#Include Lib\util.ahk
#Include Lib\views.ahk
#Include Lib\nav.ahk

STL_FILE_PATH := "C:\Users\TruUser\Desktop\작업\스캔파일"

SuspendScriptMsg := DllCall("RegisterWindowMessageA", "Str", "SuspendScript")
TerminateMsg := DllCall("RegisterWindowMessageA", "Str", "Terminate")

file_map := {data:loads_completed_files()}
ObjRegisterActive(file_map, "{EB5BAF88-E58D-48F9-AE79-56392D4C7AF6}")

step_5_tab := 1

update_file_map(){
    Loop Files, STL_FILE_PATH "\*", "F"{
        if not file_map.data.Has(A_LoopFileName){
            file_map.data[A_LoopFileName] := false
        }
    }

    for k,v in file_map.data{
        if not FileExist(STL_FILE_PATH "\" k){
            file_map.data.Delete(k)
        }
    }
}

SetTimer(update_file_map, 1000)

save_on_exit_callback(*){
    save_completed_files(file_map.data)
    PostMessage(TerminateMsg, , , ,0xFFFF)
}

OnExit(save_on_exit_callback)

for this_id in WinGetList("ESPRIT - "){
    esp_pid := WinGetPID("ahk_id" this_id)
    
    Run("esp.ahk " esp_pid)
}

^f13::{
    PostMessage(SuspendScriptMsg, , , ,0xFFFF)
}

f17::{
    Run("C:\Program Files (x86)\D.P.Technology\ESPRIT\Prog\esprit.exe", , , &esp_pid)
    Run("esp.ahk " esp_pid)
}

#HotIf WinActive("ahk_exe esprit.exe")
AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("30 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("31 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
}

+AppsKey::{
    BlockInput("MouseMove")
    CoordMode("Mouse", "Screen")

    ; 1st Margin
    Click("70 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 2nd Margin
    Click("180 170")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(20)
    ; 3rd Margin
    Click("70 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    Sleep(40)
    ; 4th Margin
    Click("180 215")
    Click("180, 290") ; Click the Text box and enter 0.025
    Send("^a0.025")
    Click("120, 325") ; Click Re-Generate Operation
    BlockInput("MouseMoveOff")
    face()
    Sleep(20)
    face()
    ; unsuppress_operation()
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("30 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("31 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
}

!Numpad7::{
    global step_5_tab
    step_5_window_0_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad9::{
    global step_5_tab
    step_5_window_120_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad1::{
    global step_5_tab
    step_5_window_240_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad3::{
    global step_5_tab
    step_5_window_270_deg()
    Sleep(20)
    if step_5_tab = 1{
        step_5_window_90_plus_deg()
    }
}

!Numpad0::{
    step_5_window_90_plus_deg()
}


z::{
    global step_5_tab
    step_5_window_tab_1()
    step_5_tab := 1
}

x::{
    global step_5_tab
    step_5_window_tab_2()
    step_5_tab := 2
}

^!Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_10_degrees()
    }
}

^!Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_10_degrees()
    }
}

^+Up::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        decrement_90_degrees()
    }
}

^+Down::{
    try{
        if not WinActive("ESPRIT - "){
            WinActivate("ESPRIT - ")
        }
        
        increment_90_degrees()
    }
}

^Numpad1::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button1()
}

^Numpad2::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button2()
}

^Numpad3::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button3()
}

^Numpad4::{
    ; unsuppress_operation()
    Sleep(20)
    ControlChooseString("28 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("29 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("14 '경계소재-4'", "ComboBox2", "ESPRIT - ")
    Sleep(20)
    ControlChooseString("15 '경계소재-5'", "ComboBox2", "ESPRIT - ")
    macro_button4()
}

^Numpad5::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button5()
    step_5_tab := 2
}

^Numpad6::{
    if not WinActive("ESPRIT - "){
        WinActivate("ESPRIT - ")
    }
    macro_button_text()
}

^!Numpad1::{
    CoordMode("Mouse", "Screen")
    click_and_return(32, 1020)
}

^!Numpad3::{
    CoordMode("Mouse", "Screen")
    click_and_return(80, 1020)
}

; Deg 1
!1::{
    step_3_deg1()
}

; Deg 2 
!2::{
    step_3_deg2()
}

; Deg 3 
!3::{
    step_3_deg3()
}

; +90 Deg
!q::{
    step_3_degplus90()
}

; Toggle Yellow Checkbox
!w::{
    step_3_yellowcheckbox()
}

; Tab 1
!a::{
    step_3_tab1()
}

; Tab 2
!s::{
    step_3_tab2()
}

; Tab 3
!d::{
    step_3_tab3()
}

!Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 250)
}

!Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 250)
}

!Up::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 210)
}

!Down::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 210)
}

+Left::{
    CoordMode("Mouse", "Screen")
    click_and_return(155, 290)
}

+Right::{
    CoordMode("Mouse", "Screen")
    click_and_return(205, 290)
}

y::{
    CoordMode("Mouse", "Screen")
    MouseMove(46, 38, 0) ; Press Tab 1
    Click(170, 325) ; Click the Entry Box
    Send("^a-5")
    Click(175, 275) ; Click Regenerate
}