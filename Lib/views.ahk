class views{
    get_current_angle(){
        index := SendMessage 0x0147, 0, 0, ComboBox1, "ESPRIT"
        MsgBox index
    }
}

