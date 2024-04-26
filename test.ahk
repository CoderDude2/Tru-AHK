#Requires Autohotkey v2.0
#SingleInstance Force

class DashboardGui{
    __New(){
        this.root := Gui()
        this.InitializeGui()
    }

    InitializeGui(){
        this.root.OnEvent("Close", this.OnClose)
    }

    OnClose(*){
        ExitApp
    }

    Show(width:=200, height:=200){
        this.root.Show("w" width " h" height)
    }

    Hide(){
        this.root.Hide()
    }
}

a := DashboardGui()
a.Show(500)