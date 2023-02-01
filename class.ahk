#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force


class Deg  ;;; shortcut keys to deg views
{
	FACE() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 5, ComboBox1, ahk_class %deg_class%
	}

	REAR() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 6, ComboBox1, ahk_class %deg_class%
	}
	deg0() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 7, ComboBox1, ahk_class %deg_class%
	}

	deg10() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 8, ComboBox1, ahk_class %deg_class%
	}

	deg20() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 9, ComboBox1, ahk_class %deg_class%
	}

	deg30() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 10, ComboBox1, ahk_class %deg_class%
	}

	deg40() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 11, ComboBox1, ahk_class %deg_class%
	}

	deg50() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 12, ComboBox1, ahk_class %deg_class%
	}

	deg60() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 13, ComboBox1, ahk_class %deg_class%
	}

	deg70() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 14, ComboBox1, ahk_class %deg_class%
	}

	deg80() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 15, ComboBox1, ahk_class %deg_class%
	}

	deg90() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 16, ComboBox1, ahk_class %deg_class%
	}

	deg100() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 17, ComboBox1, ahk_class %deg_class%
	}

	deg110() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 18, ComboBox1, ahk_class %deg_class%
	}

	deg120() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 19, ComboBox1, ahk_class %deg_class%
	}

	deg130() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 20, ComboBox1, ahk_class %deg_class%
	}

	deg140() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 21, ComboBox1, ahk_class %deg_class%
	}

	deg150() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 22, ComboBox1, ahk_class %deg_class%
	}

	deg160() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 23, ComboBox1, ahk_class %deg_class%
	}

	deg170() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 24, ComboBox1, ahk_class %deg_class%
	}

	deg180() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 25, ComboBox1, ahk_class %deg_class%
	}

	deg190() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 26, ComboBox1, ahk_class %deg_class%
	}

	deg200() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 27, ComboBox1, ahk_class %deg_class%
	}

	deg210() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 28, ComboBox1, ahk_class %deg_class%
	}

	deg220() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 29, ComboBox1, ahk_class %deg_class%
	}

	deg230() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 30, ComboBox1, ahk_class %deg_class%
	}


	deg240() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 31, ComboBox1, ahk_class %deg_class%
	}

	deg250() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 32, ComboBox1, ahk_class %deg_class%
	}

	deg260() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 33, ComboBox1, ahk_class %deg_class%
	}

	deg270() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 34, ComboBox1, ahk_class %deg_class%
	}

	deg280() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 35, ComboBox1, ahk_class %deg_class%
	}

	deg290() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 36, ComboBox1, ahk_class %deg_class%
	}

	deg300() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 37, ComboBox1, ahk_class %deg_class%
	}

	deg310() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 38, ComboBox1, ahk_class %deg_class%
	}

	deg320() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 39, ComboBox1, ahk_class %deg_class%
	}

	deg330() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 40, ComboBox1, ahk_class %deg_class%
	}

	deg340() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 41, ComboBox1, ahk_class %deg_class%
	}

	deg350() {
		WinActivate, ESPRIT
		wingetclass, deg_class, A
		control, choose, 42, ComboBox1, ahk_class %deg_class%
	}
}

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