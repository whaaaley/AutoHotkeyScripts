#Requires AutoHotkey v2.0

; This script provides a hotkey (Alt+F) to toggle the active window between fullscreen and windowed mode.
; It removes window decorations and maximizes to screen dimensions for true fullscreen.

!f:: {  ; Alt+F hotkey
    ToggleFullscreen(WinExist("A"))  ; Toggle the active window
    return
}

; Function to toggle window between fullscreen and windowed modes
ToggleFullscreen(active_id) {
    style := WinGetStyle("ahk_id " . active_id)

    if (style & 0x800000) {  ; If window has borders (normal mode)
        WinGetPos(&x, &y, &w, &h, "ahk_id " . active_id)
        WinSetStyle(-0x800000, "ahk_id " . active_id)  ; Remove border
        WinSetStyle(-0xC00000, "ahk_id " . active_id)  ; Remove title bar
        WinMove(0, 0, A_ScreenWidth, A_ScreenHeight, "ahk_id " . active_id)
    } else {  ; If window is fullscreen
        WinSetStyle(0x800000, "ahk_id " . active_id)   ; Restore border
        WinSetStyle(0xC00000, "ahk_id " . active_id)   ; Restore title bar
        WinMove(50, 50, A_ScreenWidth - 100, A_ScreenHeight - 100, "ahk_id " . active_id)
    }
}
