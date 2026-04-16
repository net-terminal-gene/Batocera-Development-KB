# CRT Mode Switcher: eDP-1 Blank When Launched from Wayland HD Mode

## Agent/Model Scope

Composer + ssh-batocera. Observed during live testing 2026-04-13. Related to `2026-04-13_crt-mode-switcher-firstrun-output-bug`.

## Problem

When the Mode Switcher is launched from Wayland/HD mode (as a "game" from EmulationStation), the Steam Deck's eDP-1 display goes blank. The mode switcher has no visible UI on any screen. The system is stuck with a blank eDP-1 and no way to interact with the mode switcher.

Additionally, having DP-1 (the CRT DAC) plugged in during this session worsens the situation: the Wayland standalone script detects DP-1 as a second monitor, extends the desktop to it at 640x480, and launches a backglass window on it. The user cannot see the mode switcher UI on either display.

## Root Cause

**Confirmed (2026-04-13):**

The mode switcher DOES launch an xterm window (`xterm -fs 15 -maximized -fg white -bg black -fa DejaVuSansMono -en UTF-8 -e bash -c DISPLAY=:0.0 /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh`). The xterm is visible and functional -- **but only when DP-1 is not connected.**

When DP-1 is plugged in during Wayland/HD mode:

1. Batocera standalone detects DP-1 as a second monitor and enables extended desktop: `wlr-randr --output eDP-1 --on --output DP-1 --on`
2. DP-1 is positioned at x=1280,y=0 (to the right of eDP-1 which is 1280px wide)
3. `batocera-backglass-window` launches on DP-1 at that position
4. When the mode switcher's xterm opens with `--maximized`, the Wayland/XWayland window manager places it on the extended desktop -- onto DP-1 at x=1280, off the Steam Deck screen
5. eDP-1 appears blank; the xterm is physically on the CRT DAC (which cannot display it at Wayland's 640x480 resolution without the EDID firmware)

**Verified:** Unplugging DP-1 collapses to single-display mode. Mode switcher xterm appears correctly on eDP-1. Mode Switcher UI is fully visible and functional.

## System State During Bug

From live SSH capture (2026-04-13):

```
/proc/cmdline: BOOT_IMAGE=/boot/linux (Wayland/HD boot)
wlr-randr: eDP-1 ON (800x1280), DP-1 ON (640x480) at +1280,0
labwc PID: 2201 (running)
emulatorlauncher PID: 3894 (running mode_switcher.sh)
backglass: python3 batocera-backglass-window --x 1280 --y 0 --width 640 --height 480
```

```
display.log sequence:
  setOutput: wlr-randr --output eDP-1 --on --output DP-1 --on
  Standalone: Launching backglass on 'DP-1' with OffsetX=1280
  Standalone: Launching EmulationStation
  Wayland compositor not ready. Exiting gracefully.   ← twice
  [mode switcher running but not visible]
```

## Solution

The xterm window placement on the wrong display is the core issue. Options:

1. **Force xterm to open on the primary display (eDP-1):** Pass `--geometry +0+0` or use `DISPLAY=:0.0` with explicit screen positioning so the xterm opens at x=0,y=0 (on eDP-1) rather than being maximized across the extended desktop. This is the minimal targeted fix.

2. **Suppress DP-1 from Wayland extended desktop when it's the CRT DAC:** In the standalone display configuration, when DP-1 is identified as the CRT output (e.g., by output name or EDID), keep it off in HD/Wayland mode rather than extending the desktop to it. This prevents the extended desktop that causes the placement issue and also stops the unnecessary backglass launch.

3. **Force eDP-1 as the primary before launching xterm:** In `mode_switcher.sh` or `crt-launcher.sh`, use `wlr-randr` to set eDP-1 as the only active output before launching the xterm. Restore DP-1 after the mode switcher exits.

Option 2 is the cleanest -- DP-1 in Wayland HD mode is the CRT DAC and should never be used as a desktop extension. Option 1 is the fastest targeted fix.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/crt-launcher.sh` | Wrap mode_switcher.sh in a terminal for Wayland |
| Batocera-CRT-Script | `roms/crt/mode_switcher.sh` | Detect Wayland; adjust display handling |

## Validation

- [x] Launch mode switcher from HD/Wayland mode: UI is visible on eDP-1
- [x] Launch mode switcher from HD/Wayland mode with DP-1 plugged in: UI still visible on eDP-1
- [x] Mode switcher completes HD→CRT switch: reboots into CRT mode correctly

## Supplement (2026-04-16)

Follow-on work on the same branch (`crt-hd-mode-switcher-v43`, commit `64b9a16`):

- **X11/CRT:** `HideWindow=true` injected on CRT restore so xterm is not hidden behind ES DRM scanout; removed on HD restore.
- **OSD flash:** Unconditional `crt-launcher.sh` videomode sync prevents spurious `emulatorlauncher` `changeMode()`.
- **HD restore:** Removed `killall emulationstation` during theme copy so the second CRT→HD round-trip still reaches `reboot`.

See `debug/x11/`, `research/02-videomode-precision-mismatch.md`, and `pr-status.md` in this session folder.

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

