#Requires AutoHotkey v2.0

; Configuration
BorderWidth := 2          ; Thickness of the border in pixels
Offset := -2              ; Configurable offset for additional gap
BorderColor := "ffa83c"   ; Orange color for the border
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
    "Progman",                      ; Ignore Desktop (main desktop window)
    "WorkerW"                       ; Ignore secondary desktop background window (behind desktop icons)
]

; Create the four border windows in an array
borders := [CreateBorderWindow(), CreateBorderWindow(), CreateBorderWindow(), CreateBorderWindow()]

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

    ; Get the process name and window class of the active window
    ProcessName := GetProcessExeFromHwnd(hwnd)
    WindowClass := WinGetClass("ahk_id " hwnd)

    ; Skip the update if the active window is one of the border windows
    for border in borders {
        if hwnd = border.Hwnd {
            HideBorders()  ; Hide borders if the active window is one of the border windows
            return
        }
    }

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

    x := NumGet(rect, 0, "Int")
    y := NumGet(rect, 4, "Int")
    w := NumGet(rect, 8, "Int") - x
    h := NumGet(rect, 12, "Int") - y

    ; Define variables for calculations with consistent naming
    xLeft := x + 7 - BorderWidth - Offset
    xRight := x + w - 7 + Offset
    yTop := y - BorderWidth - Offset
    yBottom := y + h - 7 + Offset
    width := (w - 14) + (BorderWidth * 2) + (Offset * 2)
    height := (h - 7) + (BorderWidth * 2) + (Offset * 2)

    ; Move the borders accordingly
    borders[1].Move(xLeft, yTop, width, BorderWidth)    ; Top border
    borders[2].Move(xLeft, yBottom, width, BorderWidth) ; Bottom border
    borders[3].Move(xLeft, yTop, BorderWidth, height)   ; Left border
    borders[4].Move(xRight, yTop, BorderWidth, height)  ; Right border

    ; Show the borders
    for border in borders {
        border.Show("NoActivate")
    }
}

; Function to hide the border windows
HideBorders() {
    for border in borders {
        border.Hide()
    }
}

; Function to check if the process is ignored
IsProcessIgnored(ProcessName) {
    global IgnoredProcesses
    for process in IgnoredProcesses {
        if (ProcessName = process) {
            return true
        }
    }
    return false
}

; Function to check if the window class is ignored
IsWindowClassIgnored(WindowClass) {
    global IgnoredWindowClasses
    for class in IgnoredWindowClasses {
        if (WindowClass = class) {
            return true
        }
    }
    return false
}

; Function to get the process executable name from the window handle
GetProcessExeFromHwnd(hwnd) {
    ProcessID := WinGetPID("ahk_id " hwnd)
    try {
        ProcessPath := ProcessGetPath(ProcessID)
    } catch {
        return ""
    }
    return StrSplit(ProcessPath, "\").Pop()
}

; Function to create a single border window
CreateBorderWindow() {
    borderGui := Gui("-Caption +ToolWindow +E0x20")
    borderGui.BackColor := BorderColor
    borderGui.Opt("+LastFound +AlwaysOnTop")
    borderGui.Show("x0 y0 w100 h100 NoActivate")

    WinSetTransparent(TransparencyLevel, borderGui)

    return borderGui
}

; Keep the script running
return
