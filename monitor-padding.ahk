#Requires AutoHotkey v2.0

; Configuration for bar sizes on each monitor
bar1 := { top: 36, bottom: 36, left: 36, right: 36 }
bar2 := { top: 36, bottom: 36, left: 36, right: 36 }

; Define monitor positions and sizes manually
monitor2 := { left: 0, top: 0, width: 2560, height: 1440 }     ; Primary Monitor (Monitor 2)
monitor1 := { left: 2560, top: 0, width: 2560, height: 1440 }  ; Secondary Monitor (Monitor 1)

; Function to create a bar on the screen
createBar(x, y, w, h) {
    ; Create a frameless, click-through GUI window
    bar := Gui("-Caption +ToolWindow +E0x20")

    ; Make the window fully transparent
    WinSetTransparent(0, bar)

    ; Show the bar at the specified position and size, without activating it
    bar.Show(Format("x{1} y{2} w{3} h{4} NoActivate", x, y, w, h))

    return bar
}

; Function to create bars on all sides of a monitor using the specific bar size configuration
createBarsForMonitor(monitor, barConfig) {
    return [
        createBar(monitor.left, monitor.top, monitor.width, barConfig.top),
        createBar(monitor.left, monitor.top + monitor.height - barConfig.bottom, monitor.width, barConfig.bottom),
        createBar(monitor.left, monitor.top, barConfig.left, monitor.height),
        createBar(monitor.left + monitor.width - barConfig.right, monitor.top, barConfig.right, monitor.height)
    ]
}

; Function to reserve space on all sides of the monitor
reserveWorkAreaForMonitor(monitor, barConfig) {
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    if !hMonitor {
        MsgBox("Error: Failed to retrieve monitor handle.")
        return
    }

    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)
    if !success {
        MsgBox("Error: Failed to get monitor info.")
        return
    }

    workArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", workArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    RECT := Buffer(16, 0)
    NumPut("Int", NumGet(workArea, 0, "Int") + barConfig.left, RECT, 0)      ; left
    NumPut("Int", NumGet(workArea, 4, "Int") + barConfig.top, RECT, 4)       ; top
    NumPut("Int", NumGet(workArea, 8, "Int") - barConfig.right, RECT, 8)     ; right
    NumPut("Int", NumGet(workArea, 12, "Int") - barConfig.bottom, RECT, 12)  ; bottom

    success := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", RECT.Ptr, "UInt", 0)  ; SPI_SETWORKAREA
    if !success {
        MsgBox("Error: Failed to set the new work area for the monitor.")
    }

    return workArea  ; Return the original work area for restoration
}

; Create black bars and reserve work areas for both monitors using the specific bar size configuration
barsMonitor1 := createBarsForMonitor(monitor1, bar1)
barsMonitor2 := createBarsForMonitor(monitor2, bar2)

originalWorkArea1 := reserveWorkAreaForMonitor(monitor1, bar1)
originalWorkArea2 := reserveWorkAreaForMonitor(monitor2, bar2)

; Exit handler to restore original work areas
exitFunc(ExitReason, ExitCode) {
    global originalWorkArea1, originalWorkArea2, barsMonitor1, barsMonitor2

    restoreWorkArea(originalWorkArea1, "Monitor 1")
    restoreWorkArea(originalWorkArea2, "Monitor 2")

    destroyBars(barsMonitor1)
    destroyBars(barsMonitor2)
}

; Function to restore work area
restoreWorkArea(originalWorkArea, monitorName) {
    success := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", originalWorkArea.Ptr, "UInt", 0)
    if !success {
        MsgBox("Error: Failed to restore the original work area for " . monitorName . ".")
    }
}

; Function to destroy all bars
destroyBars(bars) {
    for bar in bars {
        bar.Destroy()
    }
}

OnExit(exitFunc)
return
