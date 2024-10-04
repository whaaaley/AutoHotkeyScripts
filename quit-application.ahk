#Requires AutoHotkey v2.0

^q::  ; Ctrl+Q hotkey
{
    active_id := WinExist("A")  ; Get the active window ID
    Title := WinGetTitle("ahk_id " . active_id)  ; Get the title of the active window

    ; Confirmation dialog with Yes and No buttons
    result := MsgBox("Are you sure you want to close " . Title . "?", "Your Title", "YesNo")

    if (result = "Yes")  ; Check if the user pressed 'Yes'
        WinClose("ahk_id " . active_id)  ; Close the active window

    return
}
