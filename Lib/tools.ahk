#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; A set of functions to activate esprit tools
class tools{
	extrude_tool(){
		PostMessage, 0x111, 3130 , , , ESPRIT
	}

	circle_tool(){
		PostMessage, 0x111, 3005 , , , ESPRIT
	}

	line_tool(){
		PostMessage, 0x111, 3018 , , , ESPRIT
	}

	line_tool_2(){
		PostMessage, 0x111, 3019 , , , ESPRIT
	}

	trim_tool(){
		PostMessage, 0x111, 3033 , , , ESPRIT
	}

	three_point_tool(){
		PostMessage, 0x111, 3004 , , , ESPRIT
	}

	wireframe_view(){
		PostMessage, 0x111, 6130 , , , ESPRIT
	}

	solid_view(){
		PostMessage, 0x111, 6135 , , , ESPRIT
	}

	generate_path(){
		PostMessage, 0x111, 3054 , , , ESPRIT
	}

	swap_path(){
		PostMessage, 0x111, 3145 , , , ESPRIT
	}

	draw_path(){
		PostMessage, 0x111, 3057, , , ESPRIT
	}

	toggle_simulation(){
		PostMessage, 0x111, 6268 , , , ESPRIT
	}

	stop_simulation(){
		PostMessage, 0x111, 6276 , , , ESPRIT
	}

	save_file(){
		PostMessage, 0x111, 57603 , , , ESPRIT
	}

	transformation_window(){
		PostMessage, 0x111, 57634 , , , ESPRIT
	}

	unsuppress_operation(){
		PostMessage, 0x111, 32792 , , SysTreeView321, ESPRIT
	}

	suppress_operation(){
		PostMessage, 0x111, 32770 , , SysTreeView321, ESPRIT
	}

	rebuild_operation(){
		PostMessage, 0x111, 32768 , , SysTreeView321, ESPRIT
	}
}