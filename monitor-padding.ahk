#Requires AutoHotkey v2.0

; Configuration for bar sizes on each monitor
bar1 := { top: 36, bottom: 36, left: 36, right: 36 }
bar2 := { top: 36, bottom: 36, left: 36, right: 36 }

; Define monitor positions and sizes manually
monitor2 := { left: 0, top: 0, width: 2560, height: 1440 }     ; Primary Monitor (Monitor 2)
monitor1 := { left: 2560, top: 0, width: 2560, height: 1440 }  ; Secondary Monitor (Monitor 1)

; Create bars and reserve work areas for both monitors using the specific bar size configuration
barsMonitor1 := createBarsForMonitor(monitor1, bar1)
barsMonitor2 := createBarsForMonitor(monitor2, bar2)

; Calculate and store the desired work areas (fixed)
desiredWorkArea1 := calculateDesiredWorkArea(monitor1, bar1)
desiredWorkArea2 := calculateDesiredWorkArea(monitor2, bar2)

; Start a timer to periodically check and reset the work area if necessary
SetTimer(checkAndResetWorkArea, 1000)  ; Adjust the interval as needed

; Register an exit function to restore the work area on script exit
OnExit(restoreWorkAreaOnExit)

; Function to create bars on all sides of a monitor using the specific bar size configuration
createBarsForMonitor(monitor, barConfig) {
    return [
        createBar(monitor.left, monitor.top, monitor.width, barConfig.top),  ; Top bar
        createBar(monitor.left, monitor.top + monitor.height - barConfig.bottom, monitor.width, barConfig.bottom),  ; Bottom bar
        createBar(monitor.left, monitor.top, barConfig.left, monitor.height),  ; Left bar
        createBar(monitor.left + monitor.width - barConfig.right, monitor.top, barConfig.right, monitor.height)  ; Right bar
    ]
}

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

; Function to calculate the desired work area based on padding
calculateDesiredWorkArea(monitor, barConfig) {
    ; Prepare MONITORINFO structure
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    ; Get the monitor handle from point
    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    if !hMonitor {
        return
    }

    ; Get monitor information
    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)
    if !success {
        return
    }

    ; Retrieve the original work area
    originalWorkArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", originalWorkArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    ; Calculate the new (desired) work area based on padding
    desiredWorkArea := Buffer(16, 0)
    NumPut("Int", NumGet(originalWorkArea, 0, "Int") + barConfig.left, desiredWorkArea, 0)      ; left
    NumPut("Int", NumGet(originalWorkArea, 4, "Int") + barConfig.top, desiredWorkArea, 4)       ; top
    NumPut("Int", NumGet(originalWorkArea, 8, "Int") - barConfig.right, desiredWorkArea, 8)     ; right
    NumPut("Int", NumGet(originalWorkArea, 12, "Int") - barConfig.bottom, desiredWorkArea, 12)  ; bottom

    return desiredWorkArea  ; Return the calculated desired work area
}

; Function to set the work area based on the fixed desired work area
setWorkArea(desiredWorkArea) {
    ; Set the new work area
    DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", desiredWorkArea.Ptr, "UInt", 0)
}

; Function to check and reset the work area if necessary
checkAndResetWorkArea() {
    ; Check and reset work area for Monitor 1
    if !isWorkAreaCorrect(monitor1, desiredWorkArea1) {
        setWorkArea(desiredWorkArea1)
    }

    ; Check and reset work area for Monitor 2
    if !isWorkAreaCorrect(monitor2, desiredWorkArea2) {
        setWorkArea(desiredWorkArea2)
    }
}

; Function to check if the current work area matches the desired work area for a monitor
isWorkAreaCorrect(monitor, desiredWorkArea) {
    ; Get the monitor handle from point
    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    if !hMonitor {
        return false
    }

    ; Prepare MONITORINFO structure
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    ; Get monitor information
    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)
    if !success {
        return false
    }

    ; Retrieve the current work area from the system (fresh every time)
    currentWorkArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", currentWorkArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    ; Compare current work area with fixed desired work area
    for offset in [0, 4, 8, 12] {
        if NumGet(currentWorkArea, offset, "Int") != NumGet(desiredWorkArea, offset, "Int") {
            return false
        }
    }
    return true
}

; Function to restore work area to the full screen (no padding)
restoreWorkArea(monitor) {
    ; Prepare MONITORINFO structure
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    ; Get the monitor handle from point
    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    if !hMonitor {
        return
    }

    ; Get monitor information
    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)
    if !success {
        return
    }

    ; Use the monitor's full dimensions as the work area (no padding)
    fullWorkArea := Buffer(16, 0)
    NumPut("Int", NumGet(MONITORINFO, 8, "Int"), fullWorkArea, 0)    ; left
    NumPut("Int", NumGet(MONITORINFO, 12, "Int"), fullWorkArea, 4)   ; top
    NumPut("Int", NumGet(MONITORINFO, 16, "Int"), fullWorkArea, 8)   ; right
    NumPut("Int", NumGet(MONITORINFO, 20, "Int"), fullWorkArea, 12)  ; bottom

    ; Set the work area to full screen
    DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", fullWorkArea.Ptr, "UInt", 0)
}

; Function to restore work areas for both monitors on script exit
restoreWorkAreaOnExit(ExitReason, ExitCode) {
    restoreWorkArea(monitor1)
    restoreWorkArea(monitor2)

    destroyBars(barsMonitor1)
    destroyBars(barsMonitor2)
}

; Function to destroy all bars
destroyBars(bars) {
    for bar in bars {
        bar.Destroy()
    }
}

; Keep the script running
return
