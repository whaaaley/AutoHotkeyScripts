#Requires AutoHotkey v2.0

; Configuration
BorderWidth := 2              ; Thickness of the border in pixels
Offset := -2                  ; Configurable offset for additional gap
BorderColor := "ffa83c"       ; Border color in hexadecimal format (default: orange)
TransparencyLevel := 255      ; Set transparency level (255 = fully opaque)
DisableWhileDragging := true  ; Disable borders while dragging (default: true)

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

; List of Processes to Skip Offsets
SkipOffsetProcesses := [
    "chatterino.exe",
    "Discord.exe",
    "Flow.Launcher.exe",
    "GitHubDesktop.exe"
]

; Declare global variables
global moving := false
global prevHwnd := 0
global prevX := 0
global prevY := 0

; Create the four border windows in an array
borders := [
    CreateBorderWindow(), CreateBorderWindow(),
    CreateBorderWindow(), CreateBorderWindow()
]

; Continuously update the border around the active window
SetTimer(UpdateBorder, 100)

; Function to update the border around the active window
UpdateBorder() {
    global moving, prevHwnd, prevX, prevY, DisableWhileDragging  ; Access global variables

    try {
        hwnd := WinGetID("A")  ; Get the handle of the active window
    } catch {
        ResetState()
        return
    }

    ; Check if the active window is one of the border windows
    for border in borders {
        if hwnd = border.Hwnd {
            ResetState()
            return
        }
    }

    ; Get the process name and window class of the active window
    ProcessName := GetProcessExeFromHwnd(hwnd)
    WindowClass := WinGetClass(hwnd)

    ; Check if the process or window class is in the ignored list
    if IsProcessIgnored(ProcessName) || IsWindowClassIgnored(WindowClass) {
        ResetState()
        return
    }

    ; Use GetWindowRect for precise window boundaries
    rect := GetWindowRect(hwnd)
    if !rect {
        ResetState()
        return
    }

    x := rect.left
    y := rect.top
    w := rect.right - rect.left
    h := rect.bottom - rect.top

    ; Movement detection
    if DisableWhileDragging {
        if hwnd != prevHwnd || !GetKeyState("LButton", "P") {
            moving := false  ; Reset moving if the active window changes or mouse button is released
        } else if x != prevX || y != prevY {
            moving := true   ; Start moving
        }
    }

    ; Update previous position
    prevX := x
    prevY := y
    prevHwnd := hwnd

    if moving {
        HideBorders()
        return
    }

    ; Check if the process should skip offsets
    if IsProcessSkipOffset(ProcessName) {
        AdjustLeft := 0
        AdjustWidth := 0
        AdjustBottom := 0
    } else {
        AdjustLeft := 7
        AdjustWidth := 14
        AdjustBottom := 7
    }

    ; Calculate the positions and dimensions of the border windows
    xLeft := x + AdjustLeft - BorderWidth - Offset
    xRight := x + w - AdjustLeft + Offset
    yTop := y - BorderWidth - Offset
    yBottom := y + h - AdjustBottom + Offset
    width := (w - AdjustWidth) + (BorderWidth * 2) + (Offset * 2)
    height := (h - AdjustBottom) + (BorderWidth * 2) + (Offset * 2)

    ; Move the border windows to the calculated positions
    borders[1].Move(xLeft, yTop, width, BorderWidth)    ; Top border
    borders[2].Move(xLeft, yBottom, width, BorderWidth) ; Bottom border
    borders[3].Move(xLeft, yTop, BorderWidth, height)   ; Left border
    borders[4].Move(xRight, yTop, BorderWidth, height)  ; Right border

    ; Show the borders
    for border in borders {
        border.Show("NoActivate")
    }
}

; Function to reset state and hide borders
ResetState() {
    global moving, prevHwnd, prevX, prevY

    HideBorders()

    moving := false
    prevHwnd := 0
    prevX := 0
    prevY := 0

    return
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
        if StrLower(ProcessName) = process {
            return true
        }
    }

    return false
}

; Function to check if the window class is ignored
IsWindowClassIgnored(WindowClass) {
    global IgnoredWindowClasses

    for class in IgnoredWindowClasses {
        if StrLower(WindowClass) = class {
            return true
        }
    }

    return false
}

; Function to check if the process should skip offsets
IsProcessSkipOffset(ProcessName) {
    global SkipOffsetProcesses

    for process in SkipOffsetProcesses {
        if StrLower(ProcessName) = process {
            return true
        }
    }

    return false
}

; Function to get the process executable name from the window handle
GetProcessExeFromHwnd(hwnd) {
    ProcessID := WinGetPID(hwnd)

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

; Function to get the window rectangle
GetWindowRect(hwnd) {
    rect := Buffer(16)

    if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect) {
        return false
    }

    return {
        left: NumGet(rect, 0, "Int"),
        top: NumGet(rect, 4, "Int"),
        right: NumGet(rect, 8, "Int"),
        bottom: NumGet(rect, 12, "Int")
    }
}

; Keep the script running
return
