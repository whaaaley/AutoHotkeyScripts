#Requires AutoHotkey v2.0

; This script provides a hotkey (Ctrl+Q) to close the active window with a confirmation dialog.

^q:: {  ; Hotkey to close the active window
    active_id := WinExist("A")  ; Get the active window ID

    ; Confirmation dialog with Yes and No buttons
    result := MsgBox("Are you sure you want to close this window?", "Close Window", "YesNo")

    if (result = "Yes") {
        WinClose("ahk_id " . active_id)  ; Attempt to close the window
    }
    return
}
