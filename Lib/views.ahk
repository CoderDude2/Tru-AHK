class views{
    static get_current_angle() {
		MsgReply := SendMessage(0x0147, 0, 0, "ComboBox1", "ESPRIT") ; Uses CB_GETCURSEL command to retrieve the current selected value in ComboBox1. This outputs to the ErrorLevel.
		current_angle := MsgReply<<32>>32 ; Convert UInt to Int to have -1 if there is no item selected.
		current_angle += 1
		return current_angle
	}
}

