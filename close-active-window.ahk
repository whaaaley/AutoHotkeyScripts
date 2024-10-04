#Requires AutoHotkey v2.0

; Ctrl+Q hotkey to close the active window after confirmation
^q::
{
    ; Get the active window ID
    active_id := WinExist("A")

    ; Get the title of the active window
    Title := WinGetTitle("ahk_id " . active_id)

    ; Display a confirmation dialog with Yes and No buttons
    result := MsgBox("Are you sure you want to close " . Title . "?", "Confirm Close", "YesNo")

    ; Check if the user pressed 'Yes' to close the window
    if (result = "Yes") {
        WinClose("ahk_id " . active_id)  ; Close the active window
    }

    return
}
