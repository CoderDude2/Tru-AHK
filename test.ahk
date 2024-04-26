#Requires Autohotkey v2.0
#SingleInstance Force

#Include %A_ScriptDir%\Lib\property_manager.ahk

class DashboardGui{
    __New(){
        this.IntializeGui()
    }

    IntializeGui(){
        this.root := Gui("+Resize")
        this.tab_control := this.root.Add("Tab3", "w480 h480",["Home","Settings","Help"])
        this.root.OnEvent("Size", Gui_Size)

        this.tab_control.UseTab("Home")
        this.root.Add("Text", ,"An update is available")
        update_btn := this.root.Add("Button", "Default w80", "Update Now")

        this.tab_control.UseTab("Settings")
        GeneratePropertyGui(this.root)

        this.tab_control.UseTab("Help")
        help_button := this.root.Add("Button", "Default w120", "Open Help")

        changelog_button := this.root.Add("Button", "Default w120", "Open Changelog")
        
        Gui_Size(thisGui, MinMax, Width, Height){
            if MinMax == -1
                return
            
            this.tab_control.Move(,,Width-20,Height-20)
        }
    }

    Show(){
        this.root.Show()
    }
}

a := DashboardGui()
a.Show()