#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

save_metadata(text_x_list, text_x_asc_list, process_last_list, process_last_asc_list, file_path){
    FormatTime, current_date, A_Now, yyyy-MM-dd
    FileDelete, %file_path%\log.txt ; Overwrite previous file.
    FileAppend, %current_date%`n, %file_path%\log.txt
    
    FileAppend, `nText X:`n, %file_path%\log.txt
    ; If text_x is not empty, add the contents to the file
    if(IsObject(text_x_list) and text_x_list.Length() > 0){
        for key, value in text_x_list
            FileAppend, %value%`n, %file_path%\log.txt
    } else {
        FileAppend, NONE`n, %file_path%\log.txt
    }

    FileAppend, `nProcess Last:`n, %file_path%\log.txt
    if(IsObject(process_last_list) and process_last_list.Length() > 0){
        for key, value in process_last_list
            FileAppend, %value%`n, %file_path%\log.txt
    } else {
        FileAppend, NONE`n, %file_path%\log.txt
    }

    FileAppend, `nText X(ASC):`n, %file_path%\log.txt
    if(IsObject(text_x_asc_list) and text_x_asc_list.Length() > 0){
        for key, value in text_x_asc_list
            FileAppend, %value%`n, %file_path%\log.txt
    } else {
        FileAppend, NONE`n, %file_path%\log.txt
    }

    FileAppend, `nProcess Last(ASC):`n, %file_path%\log.txt
    if(IsObject(process_last_asc_list) and process_last_asc_list.Length() > 0){
        for key, value in process_last_asc_list
            FileAppend, %value%`n, %file_path%\log.txt
    } else {
        FileAppend, NONE`n, %file_path%\log.txt
    }
}