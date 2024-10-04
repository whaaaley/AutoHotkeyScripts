# AutoHotkeyMods
My personal AHK scripts

## Legend
- [active-window-border.ahk](#active-window-borderahk)
- [close-active-window.ahk](#close-active-windowahk)
- [monitor-padding.ahk](#monitor-paddingahk)
- [restore-work-area.ahk](#restore-work-areaahk)

## active-window-border.ahk

**Description**:
This script adds a 2px orange square border around the active window with 100% opacity. The border dynamically updates its size and position whenever the active window changes. The borders are completely click-through and always stay on top of other windows.

### Features:
- **Dynamic Border**: Automatically adjusts around the active window.
- **Always on Top**: Ensures that the border remains visible above all other windows.
- **Transparent and Click-Through**: Does not interfere with window interaction.
- **Ignored Processes/Windows**: Excludes specific processes and window classes from showing borders.

### Configuration:
- `BorderWidth`: Thickness of the border in pixels. Default is `2px`.
- `Offset`: Additional gap between the window and the border. Default is `6px`.
- `BorderColor`: Color of the border in hexadecimal format. Default is `#FF8C00` (orange).
- `TransparencyLevel`: Transparency level of the border (0 = fully transparent, 255 = fully opaque). Default is `255` (fully opaque).

### Ignored Processes and Window Classes:
- **Ignored Processes**: Windows or applications that should not display the border. This includes processes like `Flow.Launcher.exe` and `ApplicationFrameHost.exe` by default.
- **Ignored Window Classes**: Specific window classes that are excluded from the border, such as system elements like the **Taskbar**, **Start Menu**, and **System Tray**.

### Functions:
1. **`UpdateBorder()`**:
   Continuously checks for changes in the active window and updates the border accordingly. Excludes processes and windows from the update if they belong to the ignored lists.

2. **`GetProcessExeFromHwnd(hwnd)`**:
   Retrieves the executable name of the active window's process. Returns `"Access Denied"` if the process cannot be accessed due to elevated permissions.

3. **`IsProcessIgnored()` and `IsWindowClassIgnored()`**:
   Check if the active window belongs to the ignored processes or window classes.

4. **`CreateBorderWindow()`**:
   Creates a transparent, click-through window that serves as the border.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Adjust the configuration section to customize the border behavior, such as color, thickness, and transparency.
3. Add or modify the list of ignored processes or window classes if needed.
4. Run the script to apply a border to any active window that is not on the ignored list.

### Known Issues:
- Elevated windows (e.g., those running with administrative privileges) will return `"Access Denied"` when trying to retrieve the process name, causing the border to be skipped for those windows.

---

## close-active-window.ahk

**Description**:
This script provides a hotkey (`Ctrl+Q`) that prompts the user with a confirmation dialog before closing the active window. It retrieves the window's title and displays it in the confirmation dialog to ensure the user knows which window is about to be closed.

### Features:
- **Hotkey**: `Ctrl+Q` to trigger the window close confirmation.
- **Confirmation Dialog**: Ensures the user doesn't accidentally close the window by asking for confirmation.
- **Displays Active Window Title**: Shows the title of the window in the confirmation dialog.

### Functions:
1. **`^q::`**:
   This hotkey function is triggered by `Ctrl+Q`:
   - Retrieves the active window's title using `WinGetTitle`.
   - Displays a confirmation dialog using `MsgBox` with Yes and No buttons.
   - If the user selects **Yes**, the window is closed via `WinClose`.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Assign this script to a hotkey (`Ctrl+Q` is used by default).
3. Press `Ctrl+Q` to trigger a confirmation prompt before closing the active window.

### Known Issues:
- If the active window doesn't have a valid title, the confirmation message might not display the window's name correctly.

---

## monitor-padding.ahk

**Description**:
This script creates 36px black padding on all sides (top, bottom, left, and right) of Monitor 1 and Monitor 2. It reserves 36px on all sides of each monitor separately, so maximized windows don’t overlap the padding. The script restores the original work areas upon exit and includes error handling.

### Features:
- **Monitor Padding**: Creates black padding around the edges of multiple monitors.
- **Work Area Management**: Adjusts the reserved work area so maximized windows don’t overlap the padding.
- **Restoration**: Automatically restores the original work area when the script exits.
- **Supports Multi-Monitor Setup**: Allows configuring multiple monitors by manually specifying the size and position.

### Configuration:
- `BAR_SIZE`: Thickness of the padding in pixels. Default is `36px`.
- **Monitor Configuration**: Manually define the position and size of each monitor by updating the `monitor1` and `monitor2` variables.

### Functions:
1. **`CreateBarsForMonitor()`**:
   Creates black padding for all sides (top, bottom, left, and right) for a given monitor.

2. **`ReserveWorkAreaForMonitor()`**:
   Adjusts the work area to reserve space for the black padding.

3. **`ExitFunc()`**:
   When the script exits, this function restores the original work area and removes the black padding.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Adjust the monitor configuration according to your setup (position, width, height).
3. Run the script to apply 36px black padding around all sides of your monitors.
4. The original work area will be restored when the script exits.

### Known Issues:
- The script needs to be updated manually to reflect changes in monitor configurations if they differ from the pre-set values.

---

## restore-work-area.ahk

**Description**:
This script restores the work area to encompass the full screen on all monitors by removing any reserved space (e.g., after padding or bars have been added). It automatically detects all monitors and restores their full-screen work area.

### Features:
- **Full-Screen Restoration**: Restores the work area of all monitors to the full screen by removing any padding or reserved space.
- **Automatic Detection**: Automatically enumerates all connected monitors and applies the restoration.

### Functions:
1. **`RestoreWorkAreaForMonitor(hMonitor)`**:
   Restores the work area for an individual monitor by retrieving its full screen dimensions and applying them.

2. **`RestoreWorkArea()`**:
   Detects all monitors connected to the system and restores the work area for each one.

3. **`EnumMonitors(hMonitor, hdcMonitor, lprcMonitor, dwData)`**:
   Callback function used to enumerate all monitors and call `RestoreWorkAreaForMonitor()` for each.

### Usage:
1. Ensure AutoHotkey v2.0 is installed.
2. Run the script to automatically restore the full-screen work area for all monitors.

### Known Issues:
- None identified at this time.
