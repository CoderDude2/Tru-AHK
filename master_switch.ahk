#SingleInstance Force
SetWorkingDir A_ScriptDir

^r::Reload

; ===== HOT STRINGS =====
:*:3-1::{
   formatted_angle := 0
   Send "3-1. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-2::{
   formatted_angle := 90
   Send "3-2. ROUGH_ENDMILL_" formatted_angle "DEG"
}

:*:3-3::{
   formatted_angle := 180
   Send "3-3. ROUGH_ENDMILL_" formatted_angle "DEG"
}