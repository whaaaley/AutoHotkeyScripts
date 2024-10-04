#Requires AutoHotkey v2.0

; This script restores the work area to encompass the full screen on all monitors (no reserved space).

; === Function to Restore Work Area for a Monitor ===
RestoreWorkAreaForMonitor(hMonitor) {
    ; Get monitor information
    MONITORINFO := Buffer(40, 0)
    NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize = 40
    success := DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)

    if !success {
        MsgBox("Error: Failed to get monitor information.")
        return
    }

    ; Get the monitor's work area and dimensions
    left   := NumGet(MONITORINFO, 4, "Int")
    top    := NumGet(MONITORINFO, 8, "Int")
    right  := NumGet(MONITORINFO, 12, "Int")
    bottom := NumGet(MONITORINFO, 16, "Int")

    ; Define RECT structure for full monitor area (left, top, right, bottom)
    RECT := Buffer(16, 0)
    NumPut("Int", left, RECT, 0)      ; left
    NumPut("Int", top, RECT, 4)       ; top
    NumPut("Int", right, RECT, 8)     ; right
    NumPut("Int", bottom, RECT, 12)   ; bottom

    ; Set the work area back to the full monitor size
    SPI_SETWORKAREA := 0x002F
    success := DllCall("SystemParametersInfo", "UInt", SPI_SETWORKAREA, "UInt", 0, "Ptr", RECT.Ptr, "UInt", 0)

    if !success {
        MsgBox("Error: Failed to restore the work area for this monitor.")
    }
}

; === Function to Restore Work Area for All Monitors ===
RestoreWorkArea() {
    ; Enumerate monitors and restore the work area for each
    ; EnumDisplayMonitors is used to go through each monitor
    DllCall("EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", CallbackCreate(EnumMonitors), "Ptr", 0)
}

; === Callback for EnumDisplayMonitors ===
EnumMonitors(hMonitor, hdcMonitor, lprcMonitor, dwData) {
    ; Restore the work area for each monitor
    RestoreWorkAreaForMonitor(hMonitor)
    return true  ; Continue enumeration
}

; === Execute the Restore Function ===
RestoreWorkArea()
ExitApp()
