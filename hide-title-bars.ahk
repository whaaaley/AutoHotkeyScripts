#Requires AutoHotkey v2.0

; Configuration
CheckInterval := 1000          ; Check for new windows every 1 second

; Target Applications
TargetApps := [
    "Code.exe",               ; VS Code
    "WindowsTerminal.exe"     ; Windows Terminal
]

; Global variables
global ProcessedWindows := Map()

; Initialize script
Initialize()

; Main initialization function
Initialize() {
    CreateTrayMenu()
    A_IconTip := "Title Bar Hider - Running"
    
    SetTimer(CheckWindows, CheckInterval)
    ProcessAllWindows()
    
    TrayTip("Title Bar Hider Started", "Monitoring target applications", "Iconi")
}

; Main window checking function
CheckWindows() {
    for ProcessName in TargetApps {
        try {
            Windows := WinGetList("ahk_exe " . ProcessName)
            for Hwnd in Windows {
                if (!ProcessedWindows.Has(Hwnd) && IsWindowValid(Hwnd) && !IsDialogWindow(Hwnd, ProcessName)) {
                    HideTitleBar(Hwnd, ProcessName)
                    ProcessedWindows[Hwnd] := true
                }
            }
        } catch {
            ; Process not found, continue
        }
    }
    CleanupWindows()
}

; Process all existing windows
ProcessAllWindows() {
    ProcessedWindows.Clear()
    CheckWindows()
}

; Create system tray menu
CreateTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
}

; Check if window is valid for processing
IsWindowValid(Hwnd) {
    try {
        if (!WinExist("ahk_id " . Hwnd))
            return false
        Style := WinGetStyle("ahk_id " . Hwnd)
        return (Style & 0xC40000) != 0  ; Has title bar and borders
    } catch {
        return false
    }
}

; Check if window is a dialog or popup that should keep its title bar
IsDialogWindow(Hwnd, ProcessName) {
    try {
        if (ProcessName != "Code.exe")
            return false
            
        WindowClass := WinGetClass("ahk_id " . Hwnd)
        Style := WinGetStyle("ahk_id " . Hwnd)
        ExStyle := WinGetExStyle("ahk_id " . Hwnd)
        
        ; VS Code uses Chrome_WidgetWin_1 class (Electron/Chromium-based)
        ; Only process windows with this class
        if (WindowClass != "Chrome_WidgetWin_1")
            return true  ; Not a Chromium window, keep title bar
            
        ; Check for dialog/popup window styles
        ; Skip popup windows (dialogs, menus, etc.)
        if (Style & 0x80000000)  ; WS_POPUP
            return true
            
        ; Skip tool windows (developer tools, extensions panel, etc.)
        if (ExStyle & 0x80)      ; WS_EX_TOOLWINDOW
            return true
            
        ; Skip always-on-top windows (notifications, quick input, etc.)
        if (ExStyle & 0x8)       ; WS_EX_TOPMOST
            return true
            
        ; Main VS Code windows should have minimize/maximize buttons
        ; Dialogs typically don't have these
        if (!(Style & 0x20000) || !(Style & 0x10000))  ; No WS_MINIMIZEBOX or no WS_MAXIMIZEBOX
            return true
            
        ; Check window size - main editor windows are typically larger
        ; Small windows are likely dialogs (file picker, settings, etc.)
        try {
            WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . Hwnd)
            if (Width < 800 || Height < 500)  ; Main editor windows are usually larger
                return true
        } catch {
            ; Could not get position, err on the side of caution
            return true
        }
        
        ; Check if window is visible and not minimized
        if (Style & 0x20000000)  ; WS_MINIMIZE
            return true
            
        return false  ; This appears to be a main VS Code editor window
    } catch {
        ; If we can't determine, err on the side of caution and treat as dialog
        return true
    }
}

; Hide title bar for specific window
HideTitleBar(Hwnd, ProcessName) {
    try {
        WindowTitle := WinGetTitle("ahk_id " . Hwnd)
        WinSetStyle("-0xC40000", "ahk_id " . Hwnd)  ; Remove title bar and borders completely
        OutputDebug("Title bar hidden: " . ProcessName . " - " . WindowTitle)
    } catch Error as e {
        OutputDebug("Failed to hide title bar for " . Hwnd . ": " . e.Message)
    }
}

; Clean up windows that no longer exist
CleanupWindows() {
    ToRemove := []
    for Hwnd, Value in ProcessedWindows {
        if (!WinExist("ahk_id " . Hwnd))
            ToRemove.Push(Hwnd)
    }
    for Hwnd in ToRemove {
        ProcessedWindows.Delete(Hwnd)
    }
}

; Window event hook for immediate processing
OnMessage(0x0018, WM_ShowWindow)

WM_ShowWindow(wParam, lParam, msg, Hwnd) {
    if (!wParam)
        return
    SetTimer(() => CheckNewWindow(Hwnd), -100)
}

; Check newly shown window
CheckNewWindow(Hwnd) {
    try {
        ProcessName := WinGetProcessName("ahk_id " . Hwnd)
        for TargetProcess in TargetApps {
            if (ProcessName = TargetProcess && IsWindowValid(Hwnd) && !IsDialogWindow(Hwnd, ProcessName)) {
                HideTitleBar(Hwnd, ProcessName)
                ProcessedWindows[Hwnd] := true
                break
            }
        }
    } catch {
        ; Invalid window, ignore
    }
}