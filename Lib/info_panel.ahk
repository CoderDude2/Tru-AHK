#Requires Autohotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

menu_bar := MenuBar()
menu_bar.AddStandard()

root := Gui()
root.MenuBar := menu_bar
rear_picture := root.Add("Picture", "w500 h-1", "rear.png")
side_picture := root.Add("Picture", "ys w500 h-1", "side.png")
root.show()