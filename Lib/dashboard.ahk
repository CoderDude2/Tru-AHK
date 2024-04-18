#Requires Autohotkey v2.0
#SingleInstance Force

root := Gui()
root.Title := "Tru-AHK Dashboard"
root.show("w1000 h1000")

root.Add("Tab3", "w700 h200",["Home","Settings","Help"])