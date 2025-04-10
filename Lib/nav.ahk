click_and_return(posX, posY){
	MouseGetPos(&mouse_posX, &mouse_posY, &window, &active_control)
	Click(posX, posY)
	MouseMove(mouse_posX, mouse_posY)
}

macro_button1(title := unset){
    if IsSet(title) {
        WinActivate(title)
    }
    CoordMode("Mouse", "Client")
    click_and_return(25, 105)
}

macro_button2(title := unset) {
    if IsSet(title) {
        WinActivate(title)
    }
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(45, 105)
}

macro_button3(title := unset){
    if IsSet(title) {
        WinActivate(title)
    }
	CoordMode("Mouse", "Client")
    click_and_return(68, 105)
	window_title := WinGetTitle("A")
}

macro_button4(title := unset){
    if IsSet(title) {
        WinActivate(title)
    }
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(90, 105)
}

macro_button5(title := unset){
    if IsSet(title) {
        WinActivate(title)
    }
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(111, 105)
}

macro_button_text(title := unset){
    if IsSet(title) {
        WinActivate(title)
    }
	WinActivate("ESPRIT - ")
	CoordMode("Mouse", "Client")
    click_and_return(137, 105)
}

step_5_window_0_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(69, 170)
}

step_5_window_120_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(183, 172)
}

step_5_window_240_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(68, 213)
}

step_5_window_270_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(181, 226)
}

step_5_window_90_plus_deg(){
	CoordMode("Mouse", "Screen")
    click_and_return(45, 259)
}

step_5_window_tab_1(){
	CoordMode("Mouse", "Screen")
    click_and_return(52, 36)
}

step_5_window_tab_2(){
	CoordMode("Mouse", "Screen")
    click_and_return(131, 39)
}

step_3_deg1(){
    CoordMode("Mouse", "Screen")
    click_and_return(40, 101)
}

step_3_deg2(){
    CoordMode("Mouse", "Screen")
    click_and_return(120, 101)
}

step_3_deg3(){
    CoordMode("Mouse", "Screen")
    click_and_return(200, 101)
}

step_3_degplus90(){
    CoordMode("Mouse", "Screen")
    click_and_return(62, 190)
}

step_3_yellowcheckbox(){
    CoordMode("Mouse", "Screen")
    click_and_return(27, 62)
}

step_3_tab1(){
    CoordMode("Mouse", "Screen")
    click_and_return(31, 35)
}

step_3_tab2(){
    CoordMode("Mouse", "Screen")
    click_and_return(86, 40)
}

step_3_tab3(){
    CoordMode("Mouse", "Screen")
    click_and_return(126, 40)
}
