#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

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
			;Control, ChooseString, %match%, %box%, %title%
			;return
			this.returnstring := match
			return
			}
}