#SingleInstance Force
SetWorkingDir A_ScriptDir

class commands{
    static extrude_tool(){
		PostMessage 0x111, 3130 , , , "ESPRIT"
	}

	static circle_tool(){
		PostMessage 0x111, 3005 , , , "ESPRIT"
	}

	static line_tool(){
		PostMessage 0x111, 3018 , , , "ESPRIT"
	}

	static line_tool_2(){
		PostMessage 0x111, 3019 , , , "ESPRIT"
	}

	static trim_tool(){
		PostMessage 0x111, 3033 , , , "ESPRIT"
	}

	static three_point_tool(){
		PostMessage 0x111, 3004 , , , "ESPRIT"
	}

	static wireframe_view(){
		PostMessage 0x111, 6130 , , , "ESPRIT"
	}

	static solid_view(){
		PostMessage 0x111, 6135 , , , "ESPRIT"
	}

	static generate_path(){
		PostMessage 0x111, 3054 , , , "ESPRIT"
	}

	static swap_path(){
		PostMessage 0x111, 3145 , , , "ESPRIT"
	}

	static draw_path(){
		PostMessage 0x111, 3057, , , "ESPRIT"
	}

	static toggle_simulation(){
		PostMessage 0x111, 6268 , , , "ESPRIT"
	}

	static stop_simulation(){
		PostMessage 0x111, 6276 , , , "ESPRIT"
	}

	static save_file(){
		PostMessage 0x111, 57603 , , , "ESPRIT"
	}

	static transformation_window(){
		PostMessage 0x111, 57634 , , , "ESPRIT"
	}

	static unsuppress_operation(){
		PostMessage 0x111, 32792 , , "SysTreeView321", "ESPRIT"
	}

	static suppress_operation(){
		PostMessage 0x111, 32770 , , "SysTreeView321", "ESPRIT"
	}

	static rebuild_operation(){
		PostMessage 0x111, 32768 , , "SysTreeView321", "ESPRIT"
	}
}