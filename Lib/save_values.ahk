save_values(text_x_list, text_x_asc_list, process_last_list, process_last_asc_list, non_library, non_library_asc,file_path){
    current_date := FormatTime("A_Now", "yyyyMMdd")
    if(FileExist(file_path "\log.txt")){
        FileDelete(file_path "\log.txt") ; Overwrite previous file.
    }
    FileAppend(current_date "`n", file_path "\log.txt")
    
    FileAppend("`nText X:`n", file_path "\log.txt")
    ; If text_x is not empty, add the contents to the file
    if(IsObject(text_x_list) and text_x_list.Length > 0){
        for key, value in text_x_list
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }

    FileAppend("`nProcess Last:`n", file_path "\log.txt")
    if(IsObject(process_last_list) and process_last_list.Length > 0){
        for key, value in process_last_list
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }
    FileAppend("`nNon Library:`n", file_path "\log.txt")
    if(IsObject(non_library) and non_library.Length > 0){
        for key, value in non_library
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }

    FileAppend("`nText X(ASC):`n", file_path "\log.txt")
    if(IsObject(text_x_asc_list) and text_x_asc_list.Length > 0){
        for key, value in text_x_asc_list
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }

    FileAppend("`nProcess Last(ASC):`n", file_path "\log.txt")
    if(IsObject(process_last_asc_list) and process_last_asc_list.Length > 0){
        for key, value in process_last_asc_list
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }

    FileAppend("`nNon Library(ASC):`n", file_path "\log.txt")
    if(IsObject(non_library_asc) and non_library_asc.Length > 0){
        for key, value in non_library_asc
            FileAppend(value "`n", file_path "\log.txt")
    } else {
        FileAppend("NONE`n", file_path "\log.txt")
    }
}
