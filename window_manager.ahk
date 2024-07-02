#Requires Autohotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

class EspritInstance{
    esprit_pid := 10900

    main_window_id := 70818
    step_3_window_id := 1450312
    step_5_window_id := 467050
    text_window_id := 467554
    
    extrude_window_id := 72174
    transformation_window_id := 991294
}

esp_window := EspritInstance()

; TODO
; 1. Get all esprit instances with the ESPRIT title
; 2. Track all of their ids for the main window and sub windows
; 3. Store them to objects and actively update them as the various windows are used
; 4. When an instance is closed delete the corresponding object
; 5. Run as a background process