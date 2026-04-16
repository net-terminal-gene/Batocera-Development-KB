# Debug 12 — Bootstrap Version: Live CRT Boot (Working)

## Date: 2026-04-13

## Script Version

**v43.sh WITH bootstrap changes (Insert A + B)** — fresh install, new transcoder power cable.

## Critical Finding: Stage 11 Black Screen Was Hardware

The stage 11 black screen was caused by a broken power cable on the VGA-to-Component transcoder — NOT by `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz`. After replacing the power cable, ES appears correctly on the CRT with the same bootstrap changes in place. The software was correct the entire time.

---

## Observed State

### batocera.conf
```
global.videomode   = Boot_480i 1.0:0:0 15KHz 60Hz   ← written by bootstrap Insert B
global.videooutput = DP-1                             ← written by bootstrap Insert B
es.resolution      = 641x480.60.00000                ← written by normal installer
```

### Current Display Mode
```
batocera-resolution currentMode = 641x480.60.00
```
Progressive 60Hz active on DP-1. CRT displaying correctly. ES visible.

### mode_backups (pre-seeded by bootstrap Insert A + B)
```
crt_mode/video_settings/video_mode.txt   = global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz
crt_mode/video_settings/video_output.txt = DP-1
hd_mode/video_settings/video_mode.txt    = global.videomode=default
hd_mode/video_settings/video_output.txt  = eDP-1
```
Both HD and CRT backups pre-seeded correctly at install time.

### batocera-resolution listModes (Boot_480i entry)
```
641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz
```

---

## Key Finding: global.videomode Format Mismatch → ES Shows "AUTO"

ES System Settings > Video Mode shows **"AUTO"** even though `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz` is in batocera.conf.

**Root cause:** ES matches `global.videomode` against the KEY column of `batocera-resolution listModes`, not the display name column.

| Column | Format | Example |
|--------|--------|---------|
| Key (what ES reads/writes) | `WxH.rate.NNNNN` | `641x480.60.00059` |
| Display name | `Boot_...` human label | `Boot_480i 1.0:0:0 15KHz 60Hz` |

The bootstrap's Step 3 extracts the display name (everything after `:` in `videomodes.conf`):
```bash
_crt_boot_line="641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz"
_crt_boot_mode="${_crt_boot_line#*:}"   # → "Boot_480i 1.0:0:0 15KHz 60Hz"
```

It should extract the key (everything before `:`):
```bash
_crt_boot_mode="${_crt_boot_line%%:*}"  # → "641x480.60.00059"
```

With `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz`, ES cannot find a matching key in listModes and falls back to showing "AUTO". With `global.videomode=641x480.60.00059`, ES would find the match and show "Boot_480i 1.0:0:0 15KHz 60Hz" in the Video Mode dropdown.

---

## What Works vs What Needs Fixing

| Item | Status |
|------|--------|
| CRT display on boot | WORKS |
| `global.videooutput=DP-1` written correctly | WORKS |
| HD backup pre-seeded (`eDP-1`) | WORKS |
| CRT backup pre-seeded | WORKS |
| ES Video Mode shows correct Boot_ entry (not AUTO) | BROKEN — wrong format written |
| `crt_mode/video_output.txt` format (`DP-1` not `global.videooutput=DP-1`) | CHECK — mode switcher reads this |

---

## Fix Required in Bootstrap Step 3

Change the extraction from the display name to the key:

```bash
# WRONG (current) — extracts display name, ES shows AUTO
_crt_boot_mode="${_crt_boot_line#*:}"

# CORRECT — extracts resolution key, ES shows Boot_ label in UI
_crt_boot_mode="${_crt_boot_line%%:*}"
```

This change is needed in both v42.sh and v43.sh.

---

## Next Stage

→ Test mode switcher (CRT→HD→CRT) with bootstrap version to verify backups restore correctly.
