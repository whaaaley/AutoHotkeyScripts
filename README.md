# AutoHotkeyScripts

## Legend
- [active-window-border.ahk](#active-window-borderahk)
- [close-active-window.ahk](#close-active-windowahk)
- [monitor-padding.ahk](#monitor-paddingahk)
- [restore-work-area.ahk](#restore-work-areaahk)

## active-window-border.ahk

This script adds a configurable border around the active window. The border dynamically updates its size and position whenever the active window changes. The borders are completely click-through and always stay on top of other windows.

### Features:
- **Dynamic Border**: Automatically adjusts around the active window.
- **Always on Top**: Ensures that the border remains visible above all other windows.
- **Click-Through**: Does not interfere with window interaction.
- **Ignored Processes/Windows**: Excludes specific processes and window classes from showing borders.
- **Configurable**: Easily adjust border properties like width, color, and transparency.

### Configuration:
```ahk
BorderWidth := 2              ; Thickness of the border in pixels
Offset := -2                  ; Configurable offset for additional gap
BorderColor := "ffa83c"       ; Border color in hexadecimal format (default: orange)
TransparencyLevel := 255      ; Set transparency level (255 = fully opaque)
DisableWhileDragging := true  ; Disable borders while dragging (default: true)
```

### Ignored Processes and Window Classes:
- **Ignored Processes**: Windows or applications that should not display the border. This includes processes like `Flow.Launcher.exe`, `ShellExperienceHost.exe`, and `Rainmeter.exe` by default.
- **Ignored Window Classes**: Specific window classes that are excluded from the border, such as system elements like the **Taskbar**, **Start Menu**, and **System Tray**.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Adjust the configuration section to customize the border behavior, such as color, thickness, and transparency.
3. Add or modify the list of ignored processes or window classes if needed.
4. Run the script to apply a border to any active window that is not on the ignored list.

### Known Issues:
- **Work Area Orange Square on Start**: A small orange square may appear in the corner of the work area on startup. This issue will go away once you interact with a window.
- **Elevated Windows**: Elevated windows (e.g., those running with administrative privileges) will return "Access Denied" when trying to retrieve the process name, causing the border to be skipped for those windows.

---

## close-active-window.ahk

This script provides a hotkey (`Ctrl+Q`) that prompts the user with a confirmation dialog before closing the active window. It retrieves the window's title and displays it in the confirmation dialog. If the window title can't be retrieved, it defaults to a generic message.

### Features:
- **Hotkey**: `Ctrl+Q` to trigger the window close confirmation.
- **Confirmation Dialog**: Ensures the user doesn't accidentally close the window by asking for confirmation.
- **Displays Active Window Title**: Shows the title of the window in the confirmation dialog. If the title can't be retrieved, it displays "this window" as a fallback.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Press `Ctrl+Q` to trigger a confirmation prompt before closing the active window. The window title will be displayed if available.

### Known Issues:
- **Fallback for Untitled or Elevated Windows**:
   If the active window doesn't have a valid title (e.g., if it's a system window or process without a clear title), the confirmation dialog will display the fallback message "this window". This might cause some confusion about which window is being closed.
- **Handling Elevated Windows**:
   The confirmation dialog will appear for elevated windows (e.g., those running with administrative privileges), but the script will be unable to close them due to system permission restrictions. To allow the script to close elevated windows, you must run it with administrative privileges by right-clicking the script and selecting "Run as Administrator".

---

## monitor-padding.ahk

This script creates configurable transparent padding on all sides (top, bottom, left, and right) of two monitors. The transparent padding reserves space, ensuring that maximized windows do not overlap with the edges of the screen. The script also periodically verifies that the padding remains intact and restores the original work areas upon exit.

### Features:
- **Configurable Monitor Padding**: Creates transparent padding around the edges of two monitors with customizable sizes for each side (top, bottom, left, right).
- **Work Area Management**: Adjusts the reserved work area, ensuring maximized windows do not overlap with the configured padding.
- **Restoration**: Automatically restores the original work area to the full screen upon exit.
- **Multi-Monitor Support**: Configures two monitors by manually specifying their size and position.
- **Periodic Verification**: Regularly verifies and resets the work area if the current configuration does not match the desired settings.
- **Dynamic State**: Always retrieves fresh values for the current work area, ensuring changes in the environment are immediately reflected.


### Configuration:
```ahk
bar1 := { top: 36, bottom: 36, left: 36, right: 36 }
bar2 := { top: 36, bottom: 36, left: 36, right: 36 }
monitor2 := { left: 0, top: 0, width: 2560, height: 1440 }     ; Primary Monitor (Monitor 2)
monitor1 := { left: 2560, top: 0, width: 2560, height: 1440 }  ; Secondary Monitor (Monitor 1)
```

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Adjust the bar size configuration and monitor configuration according to your setup.
3. Run the script to apply the configured transparent padding around all sides of your monitors.
4. The script will periodically check and reset the work area if necessary.
5. The original work areas will be restored when the script exits.

### Known Issues:
- **Manual Updates**: The script needs to be manually updated to reflect changes in monitor configurations if they differ from the pre-set values.

---

## restore-work-area.ahk

This script restores the work area to encompass the full screen on all monitors by removing any reserved space (e.g., after padding or bars have been added). It automatically detects all monitors and restores their full-screen work area.

### Features:
- **Full-Screen Restoration**: Restores the work area of all monitors to the full screen by removing any padding or reserved space.
- **Automatic Detection**: Automatically enumerates all connected monitors and applies the restoration.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Run the script to automatically restore the full-screen work area for all monitors.

### Known Issues:
- None identified at this time.
