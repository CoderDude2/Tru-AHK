get_active_monitor(){
    CoordMode "Mouse", "Screen"
    MouseGetPos(&posX, &posY)

    monitor_count := MonitorGetCount()
    Loop monitor_count{
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if posX >= left && posX <= right && posY >= top && posY <= bottom {
            return A_Index
        }
    }
}
