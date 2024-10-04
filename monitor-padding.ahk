#Requires AutoHotkey v2.0

; This script creates 36px black bars on all sides (top, bottom, left, and right) of Monitor 1 and Monitor 2.
; It reserves 36px on all sides of each monitor separately, so maximized windows don't overlap the bars.
; The script restores the original work areas upon exit and includes error handling.

; Configuration
BAR_SIZE := 36  ; The size (thickness) of each bar on each side

; Define monitor positions and sizes manually
; Adjust these values according to your actual monitor setup.
; Example setup:
; - Monitor 2 (Primary) is on the left: 2560x1440 at position (0,0)
; - Monitor 1 (Secondary) is on the right: 2560x1440 at position (2560,0)
monitor2 := { left: 0, top: 0, width: 2560, height: 1440 }      ; Primary Monitor (Monitor 2)
monitor1 := { left: 2560, top: 0, width: 2560, height: 1440 }   ; Secondary Monitor (Monitor 1)

; Function to create black bars on all sides of a monitor
CreateBarsForMonitor(monitor) {
    global BAR_SIZE
    bars := []

    ; Create top bar
    barTop := Gui("+AlwaysOnTop -Caption +ToolWindow")
    barTop.BackColor := "Black"
    barTop.Show(Format("x{1} y{2} w{3} h{4}", monitor.left, monitor.top, monitor.width, BAR_SIZE))
    WinSetTransparent(0, barTop)
    WinSetExStyle("+0x20", barTop)      ; Make the GUI click-through
    WinSetExStyle("+0x80000", barTop)   ; Prevent activation on click
    bars.Push(barTop)

    ; Create bottom bar
    barBottom := Gui("+AlwaysOnTop -Caption +ToolWindow")
    barBottom.BackColor := "Black"
    barBottom.Show(Format("x{1} y{2} w{3} h{4}", monitor.left, monitor.top + monitor.height - BAR_SIZE, monitor.width, BAR_SIZE))
    WinSetTransparent(0, barBottom)
    WinSetExStyle("+0x20", barBottom)
    WinSetExStyle("+0x80000", barBottom)
    bars.Push(barBottom)

    ; Create left bar
    barLeft := Gui("+AlwaysOnTop -Caption +ToolWindow")
    barLeft.BackColor := "Black"
    barLeft.Show(Format("x{1} y{2} w{3} h{4}", monitor.left, monitor.top, BAR_SIZE, monitor.height))
    WinSetTransparent(0, barLeft)
    WinSetExStyle("+0x20", barLeft)
    WinSetExStyle("+0x80000", barLeft)
    bars.Push(barLeft)

    ; Create right bar
    barRight := Gui("+AlwaysOnTop -Caption +ToolWindow")
    barRight.BackColor := "Black"
    barRight.Show(Format("x{1} y{2} w{3} h{4}", monitor.left + monitor.width - BAR_SIZE, monitor.top, BAR_SIZE, monitor.height))
    WinSetTransparent(0, barRight)
    WinSetExStyle("+0x20", barRight)
    WinSetExStyle("+0x80000", barRight)
    bars.Push(barRight)

    return bars
}

; Function to reserve space on all sides of the screen for a specific monitor
ReserveWorkAreaForMonitor(monitor) {
    global BAR_SIZE

    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40

    hMonitor := DllCall("MonitorFromPoint", "Int", monitor.left + 1, "Int", monitor.top + 1, "UInt", 2, "Ptr")
    DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)

    workArea := Buffer(16, 0)
    DllCall("RtlMoveMemory", "Ptr", workArea.Ptr, "Ptr", MONITORINFO.Ptr + 20, "UInt", 16)

    left   := NumGet(workArea, 0, "Int") + BAR_SIZE  ; Reserve space on the left
    top    := NumGet(workArea, 4, "Int") + BAR_SIZE  ; Reserve space at the top
    right  := NumGet(workArea, 8, "Int") - BAR_SIZE  ; Reserve space on the right
    bottom := NumGet(workArea, 12, "Int") - BAR_SIZE ; Reserve space at the bottom

    RECT := Buffer(16, 0)
    NumPut("Int", left, RECT, 0)      ; left
    NumPut("Int", top, RECT, 4)       ; top
    NumPut("Int", right, RECT, 8)     ; right
    NumPut("Int", bottom, RECT, 12)   ; bottom

    success := DllCall("SystemParametersInfo", "UInt", 0x002F, "UInt", 0, "Ptr", RECT.Ptr, "UInt", 0)  ; SPI_SETWORKAREA
    if (!success) {
        MsgBox("Error: Failed to set the new work area for the monitor.")
    }

    return workArea  ; Return the original work area for restoration
}

; Create Black Bars for Both Monitors
barsMonitor2 := CreateBarsForMonitor(monitor2)  ; Create bars for Monitor 2 (Primary)
barsMonitor1 := CreateBarsForMonitor(monitor1)  ; Create bars for Monitor 1 (Secondary)

; Store the original work areas for restoration
originalWorkArea1 := ReserveWorkAreaForMonitor(monitor1)  ; Reserve work area for Monitor 1
originalWorkArea2 := ReserveWorkAreaForMonitor(monitor2)  ; Reserve work area for Monitor 2

; Keep the Script Running and Handle Exit
OnExit(ExitFunc)
return

; Exit Handler Function to Restore the Original Work Areas
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

    ; Destroy the bars created for both monitors
    for bar in barsMonitor1 {
        bar.Destroy()
    }
    for bar in barsMonitor2 {
        bar.Destroy()
    }
}
