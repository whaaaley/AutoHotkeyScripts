#Requires AutoHotkey v2.0

; This script provides a hotkey (Ctrl+Q) to close the active window with a confirmation dialog.
; It attempts to retrieve the window title and falls back to a generic message if the title can't be retrieved.

^q:: {  ; Hotkey to close the active window
    active_id := WinExist("A")  ; Get the active window ID
    Title := GetWindowTitle("ahk_id " . active_id)  ; Get the title of the active window, fallback if not found

    ; Confirmation dialog with Yes and No buttons
    result := MsgBox("Are you sure you want to close " . Title . "?", "Close Window", "YesNo")

    if (result = "Yes") {
        WinClose("ahk_id " . active_id)  ; Attempt to close the window
    }
    return
}

; Function to get the window title, handling cases where the title is unavailable
GetWindowTitle(hwnd) {
    try {
        Title := WinGetTitle(hwnd)  ; Attempt to retrieve the window title
        if (Title = "") {
            return "this window"  ; Fallback for untitled windows
        }
        return Title
    } catch {
        return "this window"  ; Fallback for elevated permission or inaccessible windows
    }
}
