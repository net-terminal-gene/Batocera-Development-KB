# 00 — v43 X11 first boot (local AMD lab)

**Date:** 2026-04-18  
**Host:** `batocera.local` (SSH)  
**Purpose:** Baseline before re-running `Batocera-CRT-Script-v43.sh` EDID path: Batocera version, GPU detection file, presence of `generic_15.bin`, xrandr layout.

## Context

Session investigates wrong EDID matrix on AMD after re-install. This snapshot is **before** a full CRT install run that would create `/lib/firmware/edid/generic_15.bin`.

**Test scope:** **X11 only** (xorg, xrandr). Not testing Wayland or PR #395 dual-boot (separate HD Wayland kernel vs CRT X11 kernel).

## Commands run

```bash
batocera-version
DISPLAY=:0.0 xrandr | head -40
stat /lib/firmware/edid/generic_15.bin
cat /userdata/system/logs/TYPE_OF_CARD_DRIVERS.info
grep -E 'EDID build|Parity decision|EDID PRE-bump|Amd_NvidiaND|Intel_Nvidia_NOUV' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -30
lspci | grep -iE 'vga|3d|display'
```

**Note:** Remote SSH via `ssh-batocera.sh` must not embed `$VAR` in the command string (Tcl/`expect` eats it). Use literals like `DISPLAY=:0.0` or escape dollars.

## Captured output

```
=== batocera-version ===
43 2026/04/07 09:23
=== xrandr ===
Screen 0: minimum 320 x 200, current 4080 x 1440, maximum 16384 x 16384
DP-1 connected primary 640x480+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
   640x480       60.00*   59.94
   ...
HDMI-2 connected 3440x1440+640+0 (normal left inverted right x axis y axis) 797mm x 334mm
   3440x1440     59.97*+  ...
=== edid stat ===
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
=== TYPE_OF_CARD_DRIVERS.info ===
AMD/ATI
=== BUILD EDID lines tail ===
(empty / no matches)
=== gpu lspci ===
03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 32 [Radeon RX 7700 XT / 7800 XT] (rev ff)
```

## Findings

| Item | Value |
|------|--------|
| Batocera | 43 (build 2026/04/07 09:23) |
| GPU | AMD Navi 32 (RX 7700 XT / 7800 XT) |
| `TYPE_OF_CARD_DRIVERS.info` | `AMD/ATI` (single line) |
| `generic_15.bin` | **Not present** yet |
| `BUILD_15KHz_Batocera.log` EDID grep | No lines (log empty or no EDID build yet) |
| X11 | DP-1 CRT 640x480 primary; HDMI-2 3440x1440 right-of; desktop span 4080x1440 |

## Next

1. Run v43 CRT install through EDID generation (or minimal path that creates `generic_15.bin`).
2. Add **`01-*.md`** with: `stat generic_15.bin`, full `EDID build:` line, `edid-decode`, and `xrandr` after EDID install.
3. Compare matrix branch logs to tester’s RX6400 capture.

## Cross-reference

- Installer branch split: `Batocera-CRT-Script-v43.sh` ~3509 (native vs superres matrix).
- `769` horizontal width on AMD can match **EDID pre-bump for AMD** in v43 (~3640), not only NVIDIA-only paths; use `edid-decode` + log lines to confirm matrix, not width alone.
