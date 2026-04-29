# 04 — OK Button Doesn't Work (Focus Fix)

## Symptom

User presses B or Start on controller to dismiss yad dialogs (exe picker, success message) but nothing happens. Dialog stays visible. Control+Tab shows only EmulationStation, not Add Non-Steam app as separate window.

## Root Cause

**ES keeps X11 focus** — When the app launches from emulatorlauncher, the yad dialog appears but EmulationStation remains the focused window. evmapy injects controller input as keyboard events to the **focused** window. So KEY_ENTER (from B/Start) goes to ES, not to the yad dialog. The OK button never receives the keypress.

## Fix Applied

**Phase 1–2 (insufficient):** xdotool windowactivate, --no-buttons, retry loop — focus still unreliable; exe picker blocked, only 1 game added.

**Phase 3 (yad workaround):** Auto-pick heuristic, --no-buttons, hotkey fix — did not match target UX.

**Phase 4 (Pygame UI):** Replaced yad with Pygame-based add-non-steam-game.py. Reads controller directly (BTN_A, BTN_B, BTN_BACK, BTN_START): Cancel = B/Back, OK = A/Start. No evmapy/focus dependency. Full 5-step flow: Scanning (Cancel only) → Scan results (Cancel+OK) → Exe picker per dir (Cancel+OK) → Final confirm (Cancel+OK). OK on final = add games, return to ES.

```bash
yad_focus_activate() {
  (sleep 0.5; id=$(DISPLAY="${DISPLAY:-:0.0}" xdotool search --name "$DIALOG_TITLE" 2>/dev/null | head -1); [ -n "$id" ] && DISPLAY="${DISPLAY:-:0.0}" xdotool windowactivate "$id" 2>/dev/null) &
}
```

## Contrast with BUA

BUA uses **Pygame** and reads controller input directly. It doesn't rely on evmapy or X11 focus. When user exits, it calls `sys.exit(0)` and returns to ES. Add Non-Steam Games uses **yad (GTK)** and evmapy; it requires the yad window to have focus for controller keys to reach it.
