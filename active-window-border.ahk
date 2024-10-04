#Requires AutoHotkey v2.0

; Configuration
BorderWidth := 2         ; Thickness of the border in pixels
Offset := -2             ; Configurable offset for additional gap
BorderColor := "FF8C00"  ; Orange color for the border
TransparencyLevel := 255  ; Set transparency level (255 = fully opaque)

; List of Ignored Processes
IgnoredProcesses := [
    "Flow.Launcher.exe",       ; Ignore Flow Launcher
    "ShellExperienceHost.exe", ; Ignore Windows shell (Start Menu)
    "Rainmeter.exe"            ; Ignore Rainmeter
]

; List of Ignored Window Classes
IgnoredWindowClasses := [
    "Windows.UI.Core.CoreWindow",   ; Ignore Start Menu
    "Shell_TrayWnd",                ; Ignore Taskbar
    "NotifyIconOverflowWindow",     ; Ignore System Tray (Windows 10)
    "XamlExplorerHostIslandWindow", ; Ignore System Tray (Windows 11)
    "TopLevelWindowForOverflowXamlIsland", ; Ignore System Tray Overflow (Windows 11)
    "Windows.UI.Composition.DesktopWindowContentBridge1", ; Ignore additional system windows under the mouse
    "Progman"                       ; Ignore Desktop
]

; Create the four border windows
borderTop := CreateBorderWindow()
borderBottom := CreateBorderWindow()
borderLeft := CreateBorderWindow()
borderRight := CreateBorderWindow()

; Continuously update the border around the active window
SetTimer(UpdateBorder, 100)

; Function to update the border around the active window
UpdateBorder() {
    try {
        hwnd := WinGetID("A")  ; Get the handle of the active window
    } catch {
        HideBorders()  ; Hide borders if no active window is found
        return
    }

    ; Skip the update if the active window is one of the border windows
    if !hwnd || hwnd = borderTop.Hwnd || hwnd = borderBottom.Hwnd || hwnd = borderLeft.Hwnd || hwnd = borderRight.Hwnd {
        HideBorders()  ; Hide borders if the active window is one of the border windows
        return
    }

    ; Get the process name and window class of the active window
    ProcessName := GetProcessExeFromHwnd(hwnd)
    WindowClass := WinGetClass("ahk_id " hwnd)

    ; Check if the process or window class is in the ignored list
    if IsProcessIgnored(ProcessName) || IsWindowClassIgnored(WindowClass) {
        HideBorders()  ; Hide the borders if the window is ignored
        return
    }

    ; Use GetWindowRect for precise window boundaries
    rect := Buffer(16)  ; Buffer for the RECT structure (4 * 4 bytes)
    if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect) {
        HideBorders()  ; Hide the borders if unable to get the window rectangle
        return
    }

    ; Extract x, y, w, h from the RECT structure
    x := NumGet(rect, 0, "Int")  ; left
    y := NumGet(rect, 4, "Int")  ; top
    w := NumGet(rect, 8, "Int") - x  ; right - left = width
    h := NumGet(rect, 12, "Int") - y  ; bottom - top = height

    ; Apply a hardcoded 7px adjustment for alignment, then add the real configurable Offset
    borderTop.Move(
        (x + 7) - BorderWidth - Offset,                 ; Apply hardcoded 7px and configurable Offset
        y - BorderWidth - Offset,                       ; Adjust Y for the top
        (w - 14) + (BorderWidth * 2) + (Offset * 2),    ; Adjust width, accounting for the real Offset
        BorderWidth                                    ; Height of the top border
    )

    borderBottom.Move(
        (x + 7) - BorderWidth - Offset,                 ; Apply hardcoded 7px and configurable Offset
        y + h - 7 + Offset,                             ; Adjust Y for the bottom border
        (w - 14) + (BorderWidth * 2) + (Offset * 2),    ; Adjust width, accounting for the real Offset
        BorderWidth                                    ; Height of the bottom border
    )

    borderLeft.Move(
        (x + 7) - BorderWidth - Offset,                 ; Apply hardcoded 7px and configurable Offset
        y - BorderWidth - Offset,                       ; Adjust Y for the left border
        BorderWidth,                                    ; Width of the left border
        (h - 7) + (BorderWidth * 2) + (Offset * 2)      ; Adjust height, accounting for the real Offset
    )

    borderRight.Move(
        x + w - 7 + Offset,                             ; Apply hardcoded 7px and configurable Offset
        y - BorderWidth - Offset,                       ; Adjust Y for the right border
        BorderWidth,                                    ; Width of the right border
        (h - 7) + (BorderWidth * 2) + (Offset * 2)      ; Adjust height, accounting for the real Offset
    )

    ; Show the borders if they are not hidden
    for border in [borderTop, borderBottom, borderLeft, borderRight] {
        border.Opt("+AlwaysOnTop")
        border.Show("NoActivate")  ; Ensure borders don't steal focus
    }
}

; Function to hide the border windows
HideBorders() {
    for border in [borderTop, borderBottom, borderLeft, borderRight] {
        border.Hide()  ; Hide the border window
    }
}

; Function to check if the process is ignored
IsProcessIgnored(ProcessName) {
    global IgnoredProcesses
    for process in IgnoredProcesses {
        if (process = ProcessName) {
            return true
        }
    }
    return false
}

; Function to check if the window class is ignored
IsWindowClassIgnored(WindowClass) {
    global IgnoredWindowClasses
    for class in IgnoredWindowClasses {
        if (class = WindowClass) {
            return true
        }
    }
    return false
}

; Function to get the process executable name from the window handle
GetProcessExeFromHwnd(hwnd) {
    ProcessID := WinGetPID("ahk_id " hwnd)  ; Get the Process ID from the window handle
    try {
        ProcessPath := ProcessGetPath(ProcessID)  ; Attempt to get the full path of the process executable
    } catch {
        return "Access Denied"  ; Return 'Access Denied' if an error occurs
    }
    return StrSplit(ProcessPath, "\").Pop()  ; Extract and return just the executable name
}

; Function to create a single border window
CreateBorderWindow() {
    ; Create a transparent, click-through border window
    borderGui := Gui("-Caption +ToolWindow +E0x20")  ; E0x20 for click-through (WS_EX_TRANSPARENT)
    borderGui.BackColor := BorderColor
    borderGui.Opt("+LastFound")
    borderGui.Show("x0 y0 w100 h100 NoActivate")  ; Show window without activating it

    ; Apply transparency
    WinSetTransparent(TransparencyLevel, borderGui)

    return borderGui
}

; Keep the script running
return
