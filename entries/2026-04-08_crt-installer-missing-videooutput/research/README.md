# Research — CRT Installer Missing global.videooutput

## Codebase Search (2026-04-06)

Searched the entire CRT Script codebase for `global.videooutput`:

- `Batocera-CRT-Script-v43.sh` — **zero matches**
- `first_script.sh-generic-v42` — **zero matches**
- Only matches are in `mode_switcher_modules/` (02 and 03) and `emulationstation-standalone-v43_ZFEbHVUE-MultiScreen`

## Installer's Video Output Usage

The installer knows the CRT output as `$video_output` / `$video_output_xrandr` and writes it to:

```
syslinux.cfg          → kernel cmdline: video=DP-1:e, drm.edid_firmware=DP-1:edid/...
10-monitor.conf       → X11: Ignore eDP-1, enable DP-1
15-crt-monitor.conf   → X11: CRT sync ranges bound to Monitor-DP-1
first_script.sh       → xrandr --output DP-1 on gameStop
1_GunCon2.sh          → xrandr for light gun
GunCon2_Calibration.sh → xrandr for calibration
99-nvidia.conf        → Nvidia modeline (if applicable)
```

## What It Does NOT Write

```
batocera.conf → global.videooutput=DP-1    ← NEVER SET BY INSTALLER
batocera.conf → global.videomode=...       ← NEVER SET BY INSTALLER (only es.resolution)
```

## Impact on Wayland Dual-Boot

```
Factory batocera.conf (Wayland):
  global.videooutput=eDP-1     ← laptop internal screen

After CRT Script install:
  global.videooutput=eDP-1     ← UNCHANGED — still points to laptop

emulationstation-standalone reads global.videooutput
  → targets eDP-1
  → X11 has eDP-1 ignored (10-monitor.conf)
  → ES renders to invisible output
  → BLACK SCREEN on CRT
```

## emulationstation-standalone MultiScreen Wrapper

The wrapper script (`emulationstation-standalone-v43_ZFEbHVUE-MultiScreen`) at lines 66–77:
- Reads `global.videooutput` via `batocera-settings-get-master` or `batocera-settings-get`
- Validates against `batocera-resolution listOutputs` (lines 112–117)
- Clears invalid values, falling back to `currentOutput` or the first `listOutputs` entry (lines 147–161)

On CRT/X11 mode, `batocera-resolution listOutputs` returns **empty**, so the validation logic can't correct the wrong value.

## Live SSH Verification (2026-04-07)

### Black Screen State

| Check | Result |
|-------|--------|
| Batocera version | `43 2026/04/01 18:32` |
| Kernel cmdline | `BOOT_IMAGE=/crt/linux ... drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e` |
| Dual-boot | YES (`/boot/crt/linux` exists) |
| X11 running | YES (`xinit`, `xinitrc` active) |
| EmulationStation | **Running** (PID 2896, `--screensize 769 576`) |
| xrandr active output | `DP-1 connected primary 769x576+0+0` (769x576i @ 50Hz) |
| Xorg errors | **None** (clean startup) |
| `batocera.conf` `global.videooutput` | `eDP-1` — **WRONG** |

### X11 Configs Are Correct

`10-monitor.conf` correctly ignores `eDP-1` and enables `DP-1`. `15-crt-monitor.conf` correctly binds CRT sync ranges to `DP-1`. The EDID override is correct in syslinux (`drm.edid_firmware=DP-1:edid/ms929.bin`).

### After Manual Fix

Changing `global.videooutput=eDP-1` to `global.videooutput=DP-1` in `batocera.conf` and rebooting resolved the black screen — ES displayed correctly on the CRT.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

