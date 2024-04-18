#Requires Autohotkey v2.0
#SingleInstance Force

root := Gui()
root.Opt("+Resize")
root.Title := "Tru-AHK Dashboard"
root.show("w500 h500")

root.OnEvent("Size", Gui_Size)

tab_control := root.Add("Tab3", "w480 h480",["Home","Settings","Help"])

tab_control.UseTab("Help")


Gui_Size(thisGui, MinMax, Width, Height){
    if MinMax = -1
        return
    
    tab_control.Move(,,Width-20, Height-20)
}