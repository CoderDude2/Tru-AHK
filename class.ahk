#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force


class Deg  ;;; shortcut keys to deg views
{
		deg0()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 7, ComboBox1, ahk_class %deg_class%
		}

		deg90()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 16, ComboBox1, ahk_class %deg_class%
		}

		deg120()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 19, ComboBox1, ahk_class %deg_class%
		}

		deg180()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 25, ComboBox1, ahk_class %deg_class%
		}

		deg210()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 28, ComboBox1, ahk_class %deg_class%
		}

		deg240()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 31, ComboBox1, ahk_class %deg_class%
		}

		deg270()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 34, ComboBox1, ahk_class %deg_class%
		}

		deg330()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 40, ComboBox1, ahk_class %deg_class%
		}

		FACE()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 5, ComboBox1, ahk_class %deg_class%
		}
		REAR()
		{
			WinActivate, ESPRIT
			wingetclass, deg_class, A
			control, choose, 6, ComboBox1, ahk_class %deg_class%
		}


}


class border_icon
{
		flatdoubleside()
		{

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



		slant_circle()
		{
		winactivate, ESPRIT
		PostMessage, 0x111, 3130,,, ESPRIT
		winwaitactive, ahk_class #32770
		control, choose, 2, ComboBox1, ahk_class #32770
		controlsettext, Edit1, 11, ahk_class #32770
		controlsettext, Edit4, 4, ahk_class #32770
		control, choose, 2, ComboBox2, ahk_class #32770
		SLEEP, 100
		control, check,, Button8, ahk_class #32770
		control, check,, Button3, ahk_class #32770
		SLEEP, 100
		}

	}