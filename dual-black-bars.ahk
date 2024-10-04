#Requires AutoHotkey v2.0

; This script creates two 32px black bars at the top of Monitor 1 and Monitor 2 with 50% transparency and click-through functionality.
; It reserves 32px at the top of each monitor separately so maximized windows don't overlap the top bars.
; The script restores the original work areas upon exit and includes error handling.

; === Configuration ===

BAR_HEIGHT := 32  ; The height of each bar

; Define monitor positions and sizes manually
; Adjust these values according to your actual monitor setup.
; Example setup:
; - Monitor 2 (Primary) is on the left: 2560x1440 at position (0,0)
; - Monitor 1 (Secondary) is on the right: 2560x1440 at position (2560,0)

monitor2 := { left: 0, top: 0, width: 2560, height: 1440 }      ; Primary Monitor (Monitor 2)
monitor1 := { left: 2560, top: 0, width: 2560, height: 1440 }   ; Secondary Monitor (Monitor 1)

; === Function to create the black bar ===
CreateBar(monitor) {
    global BAR_HEIGHT
    bar := Gui("+AlwaysOnTop -Caption +ToolWindow")
    bar.BackColor := "Black"
    bar.Show(Format("x{1} y{2} w{3} h{4}", monitor.left, monitor.top, monitor.width, BAR_HEIGHT))

    ; Set transparency to 50%
    WinSetTransparent(128, bar)

    ; Make the bar click-through
    WinSetExStyle("+0x20", bar)    ; WS_EX_TRANSPARENT
    WinSetExStyle("+0x80000", bar) ; WS_EX_LAYERED

    return bar
}

; === Function to reserve space at the top of the screen for a specific monitor ===
; Reserve the work area for a specific monitor by adjusting its top boundary.
; This function reserves BAR_HEIGHT at the top to prevent windows from overlapping the bar.
ReserveWorkAreaForMonitor(monitor) {
    global BAR_HEIGHT

    ; Prepare MONITORINFO structure and retrieve monitor info
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    ; Get the monitor handle for the specific monitor
    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)

    ; Extract the current work area for the monitor
    workArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", workArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    left   := NumGet(workArea, 0, "Int")
    top    := NumGet(workArea, 4, "Int") + BAR_HEIGHT  ; Reserve space at the top
    right  := NumGet(workArea, 8, "Int")
    bottom := NumGet(workArea, 12, "Int")

    ; Prepare the RECT structure with the new work area
    RECT := Buffer(16, 0)
    NumPut("Int", left, RECT, 0)      ; left
    NumPut("Int", top, RECT, 4)       ; top (original top + BAR_HEIGHT)
    NumPut("Int", right, RECT, 8)     ; right
    NumPut("Int", bottom, RECT, 12)   ; bottom

    ; Set the new work area to reserve space for the bar
    success := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", RECT.Ptr, "UInt", 0)  ; SPI_SETWORKAREA
    if (!success) {
        MsgBox("Error: Failed to set the new work area for the monitor.")
    }

    return workArea  ; Return the original work area for restoration
}

; === Create Black Bars for Both Monitors ===

bar2 := CreateBar(monitor2)  ; Create bar for Monitor 2 (Primary)
bar1 := CreateBar(monitor1)  ; Create bar for Monitor 1 (Secondary)

; Store the original work areas for restoration
originalWorkArea1 := ReserveWorkAreaForMonitor(monitor1)  ; Reserve work area for Monitor 1
originalWorkArea2 := ReserveWorkAreaForMonitor(monitor2)  ; Reserve work area for Monitor 2

; === Keep the Script Running and Handle Exit ===

; Register the exit handler to restore the original work areas
OnExit(ExitFunc)
return

; === Exit Handler Function to Restore the Original Work Areas ===
ExitFunc(ExitReason, ExitCode) {
    global originalWorkArea1, originalWorkArea2

    ; Restore the original work area for Monitor 1
    success1 := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", originalWorkArea1.Ptr, "UInt", 0)
    if (!success1) {
        MsgBox("Error: Failed to restore the original work area for Monitor 1.")
    }

    ; Restore the original work area for Monitor 2
    success2 := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", originalWorkArea2.Ptr, "UInt", 0)
    if (!success2) {
        MsgBox("Error: Failed to restore the original work area for Monitor 2.")
    }
}
