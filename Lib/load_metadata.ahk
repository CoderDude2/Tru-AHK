#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

load_metadata(file_path){
    text_x := []
    text_x_asc := []
    process_last := []
    process_last_asc := []
    current_list := ""
    reset_file := False

    Loop, read, %file_path%\log.txt
    {
        FoundPos := RegExMatch(A_LoopReadLine, "O)(\d+)-(\d+)-(\d+)", "$3$2$1")
        if(FoundPos > 0){
            file_time := RegExReplace(A_LoopReadLine, "^(\d+)-(\d+)-(\d+)$", "$1$2$3")
            FormatTime, current_time,,yyyyMMdd

            if(current_time > file_time){
                reset_file := True
            }
        }
        
        ; if A_LoopReadLine is integer
        ;     MsgBox % A_LoopReadLine
        if(A_LoopReadLine = "Text X:"){
            current_list := "text-x"
        } else if(A_LoopReadLine = "Text X(ASC):"){
            current_list := "text-x-asc"
        } else if(A_LoopReadLine = "Process Last:"){
            current_list := "process-last"
        } else if(A_LoopReadLine = "Process Last(ASC):"){
            current_list := "process-last-asc"
        }

        if A_LoopReadLine is integer
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
        FormatTime, current_date, A_Now, yyyy-MM-dd
        FileDelete, %file_path%\log.txt ; Overwrite previous file.
        FileAppend, %current_date%`n, %file_path%\log.txt
        return
    }

    return [text_x, text_x_asc, process_last, process_last_asc]
}