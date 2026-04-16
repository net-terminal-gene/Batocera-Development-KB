# Debug 13 — Bootstrap Version: CRT Live, ES Video Mode Confirmed

## Date: 2026-04-13

## Script Version

**v43.sh WITH full bootstrap (Insert A + B + C)** — fresh install, fixed scripts transferred via FileZilla.

## Fixes Applied in This Run

| Fix | Change |
|-----|--------|
| `_crt_boot_mode` extraction | `%%:*` extracts key (`641x480.60.00059`) not display name |
| `video_output.txt` format | `global.videooutput=DP-1` (with prefix, matches mode switcher format) |
| `es.resolution` override (Insert C) | Replaces installer's `641x480.60.00000` with `641x480.60.00059` |

## Result

- ES appeared on CRT correctly
- **System Settings > Video Mode showed "Boot_480i 1.0:0:0 15KHz 60Hz"** — not AUTO
- User confirmed visual detection was correct

## Root Cause of AUTO (now resolved)

The installer writes `es.resolution=641x480.60.00000` (hardcoded `00000` suffix). The `batocera-resolution listModes` key for Boot_480i is `641x480.60.00059`. These do not match, so ES showed AUTO. Insert C overwrites `es.resolution` with the correct videomodes.conf key after the installer writes it.

## Next Stage

→ `14-bootstrap-crt-to-hd-mode-switcher.md` — Mode Switcher CRT→HD switch state capture.
