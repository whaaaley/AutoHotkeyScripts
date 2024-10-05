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

; Reserve work areas and store the desired work areas
result1 := reserveWorkAreaForMonitor(monitor1, bar1)
originalWorkArea1 := result1.originalWorkArea
desiredWorkArea1 := result1.desiredWorkArea

result2 := reserveWorkAreaForMonitor(monitor2, bar2)
originalWorkArea2 := result2.originalWorkArea
desiredWorkArea2 := result2.desiredWorkArea

; Start a timer to periodically check and reset the work area if necessary
SetTimer(checkAndResetWorkArea, 100)

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

; Function to reserve space on all sides of the monitor
reserveWorkAreaForMonitor(monitor, barConfig) {
    ; Prepare MONITORINFO structure
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    ; Get the monitor handle from point
    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    if !hMonitor {
        MsgBox("Error: Failed to retrieve monitor handle.")
        return
    }

    ; Get monitor information
    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)
    if !success {
        MsgBox("Error: Failed to get monitor info.")
        return
    }

    ; Retrieve the original work area
    originalWorkArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", originalWorkArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    ; Calculate the new (desired) work area
    desiredWorkArea := Buffer(16, 0)
    NumPut("Int", NumGet(originalWorkArea, 0, "Int") + barConfig.left, desiredWorkArea, 0)      ; left
    NumPut("Int", NumGet(originalWorkArea, 4, "Int") + barConfig.top, desiredWorkArea, 4)       ; top
    NumPut("Int", NumGet(originalWorkArea, 8, "Int") - barConfig.right, desiredWorkArea, 8)     ; right
    NumPut("Int", NumGet(originalWorkArea, 12, "Int") - barConfig.bottom, desiredWorkArea, 12)  ; bottom

    ; Set the new work area
    success := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", desiredWorkArea.Ptr, "UInt", 0)  ; SPI_SETWORKAREA
    if !success {
        MsgBox("Error: Failed to set the new work area for the monitor.")
    }

    ; Return both original and desired work areas
    return { originalWorkArea: originalWorkArea, desiredWorkArea: desiredWorkArea }
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

    ; Retrieve the current work area
    currentWorkArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", currentWorkArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    ; Compare current work area with desired work area
    for offset in [0, 4, 8, 12] {
        if NumGet(currentWorkArea, offset, "Int") != NumGet(desiredWorkArea, offset, "Int") {
            return false
        }
    }
    return true
}

; Function to set the work area
setWorkArea(workArea) {
    DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", workArea.Ptr, "UInt", 0)  ; SPI_SETWORKAREA
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

; Exit handler to restore original work areas and destroy bars
exitFunc(ExitReason, ExitCode) {
    restoreWorkArea(originalWorkArea1, "Monitor 1")
    restoreWorkArea(originalWorkArea2, "Monitor 2")

    destroyBars(barsMonitor1)
    destroyBars(barsMonitor2)
}

; Set up the exit function
OnExit(exitFunc)

; Keep the script running
return
