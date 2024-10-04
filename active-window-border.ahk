#Requires AutoHotkey v2.0

; === Configuration ===
BorderWidth := 2         ; Thickness of the border in pixels
Offset := 6              ; Configurable offset for additional gap
BorderColor := "FF8C00"  ; Orange color for the border
TransparencyLevel := 255  ; Set transparency level (255 = fully opaque)

; === List of Ignored Processes ===
IgnoredProcesses := [
    "Flow.Launcher.exe",         ; Ignoring Flow Launcher
    "ApplicationFrameHost.exe",  ; Ignoring Microsoft Store and other UWP apps
    "ShellExperienceHost.exe"    ; Ignoring Windows shell (Start Menu)
]

IgnoredWindowClasses := [
    "Windows.UI.Core.CoreWindow",   ; Ignoring Start Menu
    "Shell_TrayWnd",                ; Ignoring Taskbar
    "NotifyIconOverflowWindow",     ; Ignoring System Tray (Windows 10)
    "XamlExplorerHostIslandWindow", ; Previously thought to ignore System Tray (Windows 11)
    "TopLevelWindowForOverflowXamlIsland", ; Ignoring System Tray Overflow (Windows 11)
    "Windows.UI.Composition.DesktopWindowContentBridge1", ; Additional class found under mouse
    "Progman"                       ; Ignoring Desktop
]


; Create the four border windows
borderTop := CreateBorderWindow()
borderBottom := CreateBorderWindow()
borderLeft := CreateBorderWindow()
borderRight := CreateBorderWindow()

; Continuously update the border around the active window
SetTimer(UpdateBorder, 100)

; === Function to update the border around the active window ===
UpdateBorder() {
    try {
        hwnd := WinGetID("A")  ; Get the handle of the active window
    } catch {
        return  ; If no valid active window is found, skip the update
    }

    ; Skip update if the active window is one of the border windows
    if !hwnd || hwnd = borderTop.Hwnd || hwnd = borderBottom.Hwnd || hwnd = borderLeft.Hwnd || hwnd = borderRight.Hwnd {
        return
    }

    ; Get the process name and window class of the active window
    ProcessName := GetProcessExeFromHwnd(hwnd)
    WindowClass := WinGetClass("ahk_id " hwnd)

    ; Check if the process or window class is in the ignored list
    if IsProcessIgnored(ProcessName) || IsWindowClassIgnored(WindowClass) {
        return  ; If it's ignored, skip the border update
    }

    ; Use GetWindowRect for precise window boundaries
    rect := Buffer(16)  ; Buffer for the RECT structure (4 * 4 bytes)
    if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect) {
        return  ; If we fail to get the window rectangle, skip the update
    }

    ; Extract x, y, w, h from the RECT structure
    x := NumGet(rect, 0, "Int")  ; left
    y := NumGet(rect, 4, "Int")  ; top
    w := NumGet(rect, 8, "Int") - x  ; right - left = width
    h := NumGet(rect, 12, "Int") - y  ; bottom - top = height

    ; Apply hardcoded 7px adjustment for alignment, then add the real configurable Offset
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

    ; Ensure all the border windows stay always on top
    for border in [borderTop, borderBottom, borderLeft, borderRight] {
        border.Opt("+AlwaysOnTop")
    }
}

; === Function to check if the process is ignored ===
IsProcessIgnored(ProcessName) {
    global IgnoredProcesses
    for process in IgnoredProcesses {
        if (process = ProcessName) {
            return true
        }
    }
    return false
}

; === Function to check if the window class is ignored ===
IsWindowClassIgnored(WindowClass) {
    global IgnoredWindowClasses
    for class in IgnoredWindowClasses {
        if (class = WindowClass) {
            return true
        }
    }
    return false
}

; === Function to get the process executable name from the window handle ===
GetProcessExeFromHwnd(hwnd) {
    ProcessID := WinGetPID("ahk_id " hwnd)  ; Get the Process ID from the window handle
    ProcessPath := ProcessGetPath(ProcessID)  ; Get the full path of the process executable
    return StrSplit(ProcessPath, "\").Pop()  ; Extract and return just the executable name
}

; === Function to create a single border window ===
CreateBorderWindow() {
    ; Create a transparent, click-through border window
    borderGui := Gui("-Caption +ToolWindow +E0x20")  ; E0x20 for click-through
    borderGui.BackColor := BorderColor
    borderGui.Opt("+LastFound")
    borderGui.Show("x0 y0 w100 h100 NoActivate")

    ; Apply transparency
    WinSetTransparent(TransparencyLevel, borderGui)

    return borderGui
}

; Keep the script running
return
