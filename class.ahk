#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force

class border_icon
{
	flatdoubleside() {
		PostMessage, 0x111, 3130 , , , ESPRIT
		WinWaitActive, 보스 돌출/잘라내기
		Control, choose, 2, ComboBox1, ahk_class #32770
		ControlSetText, Edit1, 11, ahk_class #32770
		ControlSetText, Edit4, 1, ahk_class #32770
		Sleep, 100
		Control, check,, Button8, ahk_class #32770
		Sleep, 100
		Control, uncheck,, Button8, ahk_class #32770
	}

	slant_circle() {
		WinActivate, ESPRIT
		PostMessage, 0x111, 3130,,, ESPRIT
		winwaitactive, ahk_class #32770
		Control, choose, 2, ComboBox1, ahk_class #32770
		ControlSetText, Edit1, 11, ahk_class #32770
		ControlSetText, Edit4, 4, ahk_class #32770
		Control, choose, 2, ComboBox2, ahk_class #32770
		SLEEP, 100
		control, check,, Button8, ahk_class #32770
		control, check,, Button3, ahk_class #32770
		SLEEP, 100
	}
}