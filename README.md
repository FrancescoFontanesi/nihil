# Quickshell HUD Layout (nihil)

Custom Quickshell configuration that builds a layered HUD for Hyprland. It renders edge overlays, a right-hand control shelf, and a sliding ChatGPT panel that shells out to an external helper script. The project is written entirely in QML with Quickshell helpers.

## Requirements
- Quickshell with Wayland and Hyprland modules available
- Hyprland (for layer shell integration and `hyprctl` commands)
- PipeWire wireplumber (`wpctl`) for volume polling
- Helper scripts in `scripts/` (battery JSON emitter and brightness writers); keep them executable and adjust device names as needed.
- External ChatGPT wrapper that can be found on my profile

## Runtime Behavior
- Edge overlays reserve space and draw PNG borders on every screen edge while still allowing windows to slide underneath.
- Two overlay `PanelWindow`s expose sliding HUD rectangles: one launches the ChatGPT helper, the other exposes lock/reboot/power controls.
- Brightness, volume, battery, and workspace widgets poll system data on a short loop and redraw minimalist HUD visuals.
- Global shortcuts (Quickshell `GlobalShortcut`) toggle the HUD widgets and collapse them automatically on workspace switches.

## File Overview
- `shell.qml` — Root Quickshell entry point; wires edge overlays and registers both HUD panel windows.
- `modules/layout/EdgeOverlayLayout.qml` — Creates top/bottom/left/right `PanelWindow`s, applies PNG borders, and drops in clock/workspace/status widgets.
- `modules/layout/EdgeStrip.qml` — Lightweight helper that renders a PNG strip per edge with optional reveal offset.
- `modules/widgets/ChatGPTHud.qml` — Sliding ChatGPT HUD; handles open/close animations, exclusive zone updates, and invokes the external wrapper with `--toggle`.
- `modules/widgets/LockHud.qml` — Right-side lock control HUD with mirrored slide/expand animation and exclusive-zone management.
- `modules/widgets/HudLockButton.qml` — Column of icon buttons (reboot, shutdown, lock) that exec system commands when clicked.
- `modules/widgets/HudClock.qml` — Centered time/date plaque with animated corner nodes and outline canvas.
- `modules/widgets/HudWorkSpaces.qml` — Hyprland workspace overview; polls `hyprctl` JSON, marks active/occupied workspaces, and animates an indicator frame.
- `modules/widgets/HudVolumeBar.qml` — Volume status widget; polls pipewire via `wpctl`, draws a horizontal fill bar, and shows the volume icon.
- `modules/widgets/HudbrightnessBar.qml` — Brightness widget; tails `tmp/brightness_percent`, animates fill width, and shows the brightness icon.
- `modules/widgets/HudBattery.qml` — Segmented battery meter that consumes JSON from `battery.sh`, colors low charge in red, and shows charge state text.
- `modules/layout` — Shared layout helpers for edge overlays (see files above).
- `modules/widgets` — Widget library for the HUD (see files above).
- `assets/top.png`, `assets/bottom.png`, `assets/left.png`, `assets/right.png` — Edge overlay textures used by `EdgeOverlayLayout`.
- `assets/lock.png`, `assets/reboot.png`, `assets/shutdown.png` — Control icons displayed inside `HudLockButton`.
- `assets/volume.png`, `assets/brightness.png` — HUD status icons for the volume and brightness panels.
- `tmp/brightness_percent` — Plain-text percentage file tailed by `HudbrightnessBar`; populated by the brightness helper scripts.
- `.gitignore` — Ignores a top-level `tmp` directory and local `.qmlls.ini` language server config.

## Helper Scripts
- `scripts/battery.sh` — Reads `/sys/class/power_supply/BAT*/` to emit compact JSON with percent and charging state using `jq`. Adjust the `bat` variable if your battery name differs.
- `scripts/increment_brightness.sh` — Bumps the `brightnessctl` `backlight` device by +10%, computes the percentage, and writes it to `tmp/brightness_percent` for `HudbrightnessBar.qml`.
- `scripts/decrement_brightness.sh` — Drops brightness by 10% with `brightnessctl` and refreshes `tmp/brightness_percent`; stays silent on failure so the HUD does not flicker.

## Customization Tips
- Adjust panel sizes/margins in `shell.qml`, `ChatGPTHud.qml`, and `LockHud.qml` for different monitor geometries.
- Swap command arrays in `HudLockButton.qml` to point at alternative scripts or prompts.
- Tweak polling intervals (`pollInterval`, `pollMs`, timers) to balance responsiveness versus CPU usage.
- Replace the PNG assets with matching dimensions to reskin borders and icons.

## Troubleshooting
- If widgets stop updating, ensure their helper commands (`hyprctl`, `wpctl`, battery script, brightness writer) are on the PATH and executable.
- The ChatGPT HUD expects the wrapper command to accept `--toggle`; update `command` in `shell.qml` if you relocate or rename the helper.

