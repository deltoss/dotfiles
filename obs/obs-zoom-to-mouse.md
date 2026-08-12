# Installing obs-zoom-to-mouse

Lua script for OBS Studio that zooms a Display Capture source in on the mouse cursor.

## 1. Fit the source

Select the Display Capture source and press `Ctrl + F` (Fit to Screen).
The script expects a bounding-box transform.

## 2. Load it in OBS

Tools → Scripts → `+` → select `obs-zoom-to-mouse.lua`.

## 3. Set the Zoom Source

In the script's settings panel on the right, set *Zoom Source* to the Display Capture source.

## 4. Bind the hotkey

File → Settings → Hotkeys, then search for `Toggle zoom to mouse` and set it to:

`Alt + Shift + Z`

`Toggle follow mouse during zoom` sits just below it if you want cursor tracking while
zoomed — bind it to a second combo. Both entries only appear once the script is loaded.
