# CRT→HD Pre-Reboot (Second Roundtrip) — 2026-02-22 00:42 UTC

**Context:** Mode Switcher completed CRT→HD switch (second roundtrip). System ready for power cycle into Wayland HD. User was asked to re-pick boot resolution again (bug #09).

## System State

| Field | Value |
|---|---|
| Uptime | 6 min |
| Kernel | 6.18.9 |
| BOOT_IMAGE | `/crt/linux` (still running X11 from current boot) |
| Syslinux DEFAULT | `batocera` (set for next boot — Wayland HD) |

## batocera.conf (restored to HD state)

```
global.videooutput=eDP-1
global.videooutput2=none
```

No `global.videomode` or `es.resolution` — cleared for HD auto mode. Correct.

## Backups

**CRT backup (preserved):**
```
video_mode.txt:   global.videomode=769x576.50.00  ← correct precision
video_output.txt: global.videooutput=DP-1
```

**HD backup:**
```
video_mode.txt:   (empty)
video_output.txt: global.videooutput=eDP-1
```

## Restore Log

```
[00:42:10]: Set DEFAULT=batocera in all 3 syslinux.cfg files
[00:42:10]: Restored batocera.conf from HD Mode backup
[00:42:10]: Removed 15-crt-monitor.conf (CRT-only)
[00:42:10]: HD Mode: Installing Mode Selector only
[00:42:13]: ERROR: es_systems_crt.cfg missing emulatorlauncher - RE-COPYING...
[00:42:13]: Restore completed for hd mode (userdata-only approach)
```

## es_systems_crt.cfg

Still points to `crt-launcher.sh` after re-copy (source has `crt-launcher.sh`). Correct.

## 15-crt-monitor.conf

Removed during HD restore. Correct.

## Bug #09 Reproduced

Boot resolution re-ask happened again — same root cause: `get_boot_display_name("769x576.50.00")` exact-match fails against `769x576.50.00060`.

## Status

System ready for power cycle into Wayland HD. CRT backup has correct precision. Third roundtrip leg.
