#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force


class border_icon
{
		flatdoubleside()
		{

		PostMessage, 0x111, 3130,,, ESPRIT
		winwaitactive, 보스 돌출/잘라내기
		control, choose, 2, ComboBox1, ahk_class #32770
		controlsettext, Edit1, 11, ahk_class #32770
		controlsettext, Edit4, 1, ahk_class #32770
		SLEEP, 100
		control, check,, Button8, ahk_class #32770
		SLEEP, 100
		control, uncheck,, Button8, ahk_class #32770
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


		center_border_3()
		{

		winactivate, ESPRIT
		PostMessage, 0x111, 3130,,, ESPRIT

		winwaitactive, 보스 돌출/잘라내기
		controlsettext, Edit1, 6, ahk_class #32770
		sleep, 100
		control, CHECK,, Button2, ahk_class #32770
		SLEEP, 100
		control, unCHECK,, Button2, ahk_class #32770
		}


	}

	class list_search
{
		layer(search_term, box, title) ;;; 			list_search.layer("euro", "combobox5", "Font")
		{
			ControlGet, LB_list, List, , %box%, %title%
			matchflag=0 ; no match yet
			loop, parse, LB_list, `n, `r
			IfInString, A_LoopField, %search_term%
			  {
				matchflag=1 ; match found
				Match := A_LoopField
				break
			  }
			;;msgbox %LB_list%`r`n`r`n %match%
			control, ChooseString, %match%, %box%, %title%
			return
			}
			;;; ===================================================================
		string(search_term, box, title) ;;; 			list_search.string("euro", "combobox5", "Font")
		;; returns a string of the match

		/* example
		list_search.string("ish", "combobox5", "Font")
		x := list_search.returnstring
		control, choosestring, %x%, combobox5, Font
		*/

		{

			ControlGet, LB_list, List, , %box%, %title%
			matchflag=0 ; no match yet
			loop, parse, LB_list, `n, `r
			IfInString, A_LoopField, %search_term%
			  {
				matchflag=1 ; match found
				Match := A_LoopField
				break
			  }
			;;msgbox %LB_list%`r`n`r`n %match%
			;control, ChooseString, %match%, %box%, %title%
			;return
			this.returnstring := match
			return
			}
}