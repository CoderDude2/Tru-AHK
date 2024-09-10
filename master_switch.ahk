#Requires Autohotkey v2.0

#SingleInstance Force
A_HotkeyInterval := 9900000  ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 9900000
KeyHistory 0
ListLines False
ProcessSetPriority "A"
SetKeyDelay -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetControlDelay -1

SetWorkingDir A_ScriptDir


#Include %A_ScriptDir%\Lib\views.ahk
#Include %A_ScriptDir%\Lib\commands.ahk
#Include %A_ScriptDir%\Lib\updater.ahk

if(FileExist("old_master_switch.exe")){
    FileDelete("old_master_switch.exe")
}

if(IniRead("config.ini", "info", "show_changelog") == "True"){
    Run A_ScriptDir "\resources\changelog.pdf"
    IniWrite("False", "config.ini", "info", "show_changelog")
}

; ===== Variables =====
initial_pos_x := 0
initial_pos_y := 0
click_index := 0
path_tool_active := false

showDebug := false

#HotIf WinActive("ahk_exe esprit.exe")

#SuspendExempt
;G1
f13::{
    Reload
}

SetTimer(debug, 20)

debug(){
    if(showDebug){
        try{
            MouseGetPos(&posX, &posY, &window, &active_control)
            ToolTip("(" posX "," posY ")`n" WinGetTitle(window) "`n" active_control, posX, posY+20)
        }
    } else {
        ToolTip()
    }
}

^f3::{
    global showDebug
    showDebug := !showDebug
}

;Ctrl+G1
^f13::{
    Suspend
}
#SuspendExempt False

; G4
f16::{
    selected_file := FileSelect(,"C:\Users\TruUser\Desktop\작업\스캔파일")
    if(selected_file != ""){
        SplitPath(selected_file, &name)
        found_pos := RegExMatch(name, "\(([A-Za-z0-9\-]+),", &sub_pat)
        open_file()
        WinWaitActive("ahk_class #32770")
        ControlSetText("C:\Users\TruUser\Desktop\Basic Setting\" sub_pat[1] ".esp", "Edit1", "ahk_class #32770")
        ControlSetChecked(0,"Button5","ahk_class #32770")
        ControlSend("{Enter}", "Button2","ahk_class #32770")
    }
}

f12::{
    ProcessExist("esprit.exe")
    pid := WinGetPID("A")
    ProcessClose(pid)
}


; ===== Remappings =====
Space::Enter
LWin::Delete

; ===== Hotstrings =====
:*:3-1::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := (get_current_angle() - 7) * 10
   Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:2-1::{
    esprit_title := WinGetTitle("ESPRIT")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "2-1. FRONT TURNING-SHORT"
    } else {
        Send "2-1. FRONT TURNING"
    }
}

:*:5-1::{
    esprit_title := WinGetTitle("ESPRIT")
    if(get_case_type(esprit_title) = "TLOC" || get_case_type(esprit_title) = "AOT"){
        Send "5-1. FRONT TURNING"
    }
}

; ===== View Controls=====

a::{
    deg0()
}

s::{
    deg90()
}

d::{
    deg180()
}

f::{
    deg270()
}

c::{
    face()
}

v::{
    rear()
}

!WheelDown::{
    if(WinActive("ESPRIT")){
        increment_10_degrees()
    }
}

+!WheelDown::{
    if(WinActive("ESPRIT")){   
        increment_90_degrees()
    }
}

!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_10_degrees()
    }
}

+!WheelUp::{
    if(WinActive("ESPRIT")){
        decrement_90_degrees()  
    }
}

f14::{
    solid_view()
}

; Tilde(~) key
`::{
    wireframe_view()
}

; ===== Controls =====
t::{
    transformation_window()
}

+c::{
    circle_tool()
}

+a::{
    unsuppress_operation()
}

+s::{
    suppress_operation()
}

+r::{
    rebuild_operation()
}

!x::
XButton1::{
    trim_tool()
}

+XButton2::{
    three_point_tool()
}

^e::{
    extrude_tool()
}

CapsLock::{
    line_tool()
}

+Space::{
    toggle_simulation()
}

g::{
    double_sided_border()
}

b::{
    cut_with_border()
}

r::{
    extrude_by(5)
}

^r::{
    extrude_by(2)
}

e::{
    draw_straight_border()
}

; G5 Key

f18::{
    save_file()
}

; ===== Auto-Complete Margins =====
~Escape::{
    global click_index
    global path_tool_active
    global passes

    passes := 5
    
    click_index := 0
    path_tool_active := false

    stop_simulation()
}

+CapsLock::
XButton2::{
    global click_index
    global path_tool_active

    click_index := 0
    path_tool_active := true
    draw_path()
}

~LButton::{
    global click_index
    global path_tool_active
    global initial_pos_x
    global initial_pos_y


    if(path_tool_active == true && click_index < 1){
        CoordMode("Mouse", "Screen")
        click_index += 1
        MouseGetPos(&initial_pos_x, &initial_pos_y)
    }
}

RButton::{
    global path_tool_active
    global click_index
    global initial_pos_x
    global initial_pos_y

    if(path_tool_active == true){
        ; Snap to original position and click to complete the path
        CoordMode("Mouse", "Screen")
        MouseMove(initial_pos_x, initial_pos_y, 0)
        Click()
        path_tool_active := false
        click_index := 0
        initial_pos_x := 0
        initial_pos_y := 0
    } else {
        SendInput("{RButton}")
    }
}

; ===== Auto-Fill TLOC cases =====
+t::{
WinWaitActive("ahk_exe esprit.exe")
esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) = "TLOC"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)

    } else if(get_case_type(esprit_title) = "AOT"){
        FoundPos := RegExMatch(esprit_title, "#101=([\-\d.]+) #102=([\-\d.]+) #103=([\-\d.]+) #104=([\-\d.]+) #105=([\-\d.]+)", &SubPat)
        working_degree := SubPat[1]
        rotate_stl_by := SubPat[2]
        y_pos := SubPat[3]
        z_pos := SubPat[4]
        x_pos := SubPat[5]

        update_angle_deg(working_degree)
        Sleep(50)
        translate_selection(20, 0, 0)
        Sleep(50)
        rotate_selection(rotate_stl_by)
        Sleep(50)
        translate_selection(x_pos, -1 * y_pos, -1 * z_pos)
        Sleep(50)
        rotate_selection(Mod(working_degree, 10), True)
    }
}

; ===== More Keys =====
y::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    MouseMove(46, 38, 0) ; Press Tab 1
    Click(170, 325) ; Click the Entry Box
    Send("^a-5")
    Click(175, 275) ; Click Regenerate
}

AppsKey::{
    BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
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
}

+AppsKey::{
        BlockInput("MouseMove")
        SetDefaultMouseSpeed(0)
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
}

q::{
    generate_path()
}

w::{
    swap_path()
}


^Numpad1::{
    macro_button1()
}

^Numpad2::{
    macro_button2()
}

^Numpad3::{
    macro_button3()
}

^Numpad4::{
    macro_button4()
}

^Numpad5::{
    macro_button5()
}

^Numpad6::{
    macro_button_text()
}

!1::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(40, 101)
}

!2::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(120, 101)
}

!3::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(200, 101)
}

!q::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(62, 190)
}

!w::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(27, 62)
}

!a::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(31, 35)
}

!s::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(86, 40)
}

!d::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(126, 40)
}

!Right::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(205, 250)
}

!Left::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(155, 250)
}

!Up::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(155, 210)
}

!Down::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(205, 210)
}

+Left::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(155, 290)
}

+Right::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    click_and_return(205, 290)
}

!e::{
    show_milling_tool()
}

; G3 Key
f15::{
    WinMove(-600, 275, , , "esprit", "&Yes")
}

^Left::{
    translate_selection(-0.5, 0, 0)
}

; Auto-Start
+q::{
    WinWaitActive("ahk_exe esprit.exe")
    esprit_title := WinGetTitle("A")
    if(get_case_type(esprit_title) == "ASC"){
        macro_button1()
        if(WinWait("esprit", "&Yes")){
            WinActivate("esprit")
            Send("{Enter}{Enter}{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("60 147")
            }
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == false){
        macro_button1()
        if(WinWait("CAM Automation")){
            WinActivate("CAM Automation")
            Send("{Enter}")
        }

        if(WinWait("esprit")){
            WinActivate("esprit")
            Send("{Enter}")
        }

        if(WinWait("Direction Check")){
            WinActivate("Direction Check")
            Send("{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("65 115")
            }
        }
    } else if(get_case_type(esprit_title) == "DS" && is_non_engaging(esprit_title) == true){
        macro_button1()
        if(WinWait("CAM Automation")){
            WinActivate("CAM Automation")
            Send("{Enter}")
        }

        if(WinWait("esprit")){
            WinActivate("esprit")
            Send("{Enter}")
        }

        if(WinWait("STL Rotate")){
            deg0()
            yn := MsgBox("Is connection properly aligned?", "Check Connection", 3)
            if(yn == "Yes"){
                WinActivate("STL Rotate")
                CoordMode("Mouse", "Client")
                Click("65 115")
            }
        }
    }
}

^Up::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    ; Get the current number of passes
    A_Clipboard := ""
    Click("1582 144")
    Sleep(20)
    Click("1703 317")
    Send("^a^c")
    ClipWait(2)
    if(IsInteger(A_Clipboard)){
        passes := A_Clipboard + 1
        
        ; Tab 1
        Click("1582 144")
    	Sleep(20)
    	Click("1703 317")
    	Sleep(20)
    	Send("^a" passes "{Enter}")
    	Send("^a" (-1*passes) "{Enter}")
    	Click("1662 393")
    	Sleep(20)

        ; Tab 2
    	Click("1658 144")
    	Sleep(20)
    	Click("1703 317")
    	Sleep(20)
    	Send("^a" passes "{Enter}")
    	Send("^a" (-1*passes) "{Enter}")
    	Click("1662 393")
    	Sleep(20)
    	Click("1605 233")
    }
}

^Down::{
    SetDefaultMouseSpeed(0)
    CoordMode("Mouse", "Screen")
    ; Get the current number of passes
    A_Clipboard := ""
    Click("1582 144")
    Sleep(20)
    Click("1703 317")
    Send("^a^c")
    ClipWait(2)
    if(IsInteger(A_Clipboard)){
        passes := A_Clipboard - 1
        
        ; Tab 1
        Click("1582 144")
    	Sleep(20)
    	Click("1703 317")
    	Sleep(20)
    	Send("^a" passes "{Enter}")
    	Send("^a" (-1*passes) "{Enter}")
    	Click("1662 393")
    	Sleep(20)

        ; Tab 2
    	Click("1658 144")
    	Sleep(20)
    	Click("1703 317")
    	Sleep(20)
    	Send("^a" passes "{Enter}")
    	Send("^a" (-1*passes) "{Enter}")
    	Click("1662 393")
    	Sleep(20)
    	Click("1605 233")
    }
}