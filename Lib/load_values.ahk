load_values(file_path){
    text_x := []
    text_x_asc := []
    process_last := []
    process_last_asc := []
    current_list := ""
    reset_file := False

    Loop read, file_path "\log.txt"
    {
        if(A_Index == 1){
            current_time := FormatTime(, "yyyyMMdd")
            
            ; If the current date is greater than the saved date,
            ; then set the file to be reset.
            if(current_time > A_LoopReadLine){
                reset_file := true
            }
        }

        if(A_LoopReadLine = "Text X:"){
            current_list := "text-x"
        } else if(A_LoopReadLine = "Text X(ASC):"){
            current_list := "text-x-asc"
        } else if(A_LoopReadLine = "Process Last:"){
            current_list := "process-last"
        } else if(A_LoopReadLine = "Process Last(ASC):"){
            current_list := "process-last-asc"
        }

        if isInteger(A_LoopReadLine)
            if(current_list = "text-x"){
                text_x.Push(A_LoopReadLine)
            } else if(current_list = "text-x-asc"){
                text_x_asc.Push(A_LoopReadLine)
            } else if(current_list = "process-last"){
                process_last.Push(A_LoopReadLine)
            } else if(current_list = "process-last-asc"){
                process_last_asc.Push(A_LoopReadLine)
            }
    }


    if(reset_file = True){
        current_date := FormatTime("A_Now", "yyyyMMdd")
        FileDelete(file_path "\log.txt") ; Overwrite previous file.
        FileAppend(current_date "`n", file_path "\log.txt")
        return
    }

    return [text_x, text_x_asc, process_last, process_last_asc]
}