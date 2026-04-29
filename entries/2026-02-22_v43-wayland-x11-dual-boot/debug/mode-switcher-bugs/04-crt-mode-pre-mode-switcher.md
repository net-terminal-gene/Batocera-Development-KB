# CRT Mode Pre-Mode-Switcher — 2026-02-22 00:22 UTC

**Purpose:** State snapshot after rebooting into CRT mode (first CRT boot after Phase 2), before launching Mode Switcher.

## System State

| Item | Value |
|------|-------|
| Uptime | <1 minute (fresh boot) |
| Kernel | 6.18.9 (X11 CRT) |
| Boot image | `BOOT_IMAGE=/crt/linux` |
| CMDLINE extras | `drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e` (CRT EDID forcing active) |
| Current mode | `769x576.50.00` |

## batocera.conf Video Entries

```
es.resolution=769x576.50.00000
global.videooutput2=none
```

- `global.videomode` is still **NOT set**
- `es.resolution=769x576.50.00000` (5 trailing zeros — different precision than `currentMode` returns `769x576.50.00`)
- No `CRT.videomode`

**Implication:** Since `global.videomode` is not set, emulatorlauncher will use `default` -> `minTomaxResolution()` instead of `changeMode()`. CRT tools should display correctly on this boot.

## 15-crt-monitor.conf

Present and correct (loaded from CRT overlay):
```
Section "Monitor"
    Identifier  "CRT"
    HorizSync   15-16.5
    VertRefresh 49-65
    Option      "DPMS" "False"
    Option      "DefaultModes" "False"
EndSection

Section "Device"
    Identifier "modesetting-amd-crt-bind"
    Driver "modesetting"
    Option "Monitor-DP-1" "CRT"
EndSection
```

## File State

| File | Status |
|------|--------|
| `crt-launcher.sh` | Executable (`-rwxr-xr-x`) |
| `es_systems_crt.cfg` | Points to `crt-launcher.sh` |
| `15-crt-monitor.conf` | Present (from overlay) |
| `boot-custom.sh` | NOT FOUND |
| Launch log | No entries yet (no CRT tool launched) |

## Assessment

CRT mode booted successfully at `769x576.50.00`. EDID forcing active on DP-1. `15-crt-monitor.conf` loaded from overlay. `global.videomode` is NOT set, so CRT tools should work on this boot (no mismatch possible). The real test comes after the CRT->HD->CRT roundtrip.
