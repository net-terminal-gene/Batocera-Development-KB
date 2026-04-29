# CRT->HD Mode Switch Pre-Reboot — 2026-02-22 00:24 UTC

**Purpose:** State after Mode Switcher completed CRT->HD switch, before shutdown/power-on into Wayland HD.

## System State

| Item | Value |
|------|-------|
| Uptime | 3 minutes |
| Kernel | 6.18.9 (X11 CRT — still running) |
| Boot image | `BOOT_IMAGE=/crt/linux` |
| Current mode | `769x576.50.00` |

## Syslinux

- `DEFAULT batocera` with `MENU DEFAULT` on batocera label — flipped to Wayland for next boot

## batocera.conf Video Entries (After HD Restore)

```
global.videooutput=eDP-1        (HD output — restored for Wayland)
global.videooutput2=none
```

`es.resolution` and `global.videomode` have been CLEARED — correct behavior for HD mode ("Cleared es.resolution from both config files for HD auto mode").

## CRT Mode Backup — video_mode.txt

```
global.videomode=769x576.50.00
```

**THIS IS THE KEY VALUE.** The Layer 2 fix (`02_hd_output_selection.sh` using `batocera-resolution currentMode`) saved `769x576.50.00` — the exact string that `currentMode` returns. NOT `769x576.50.00060` from videomodes.conf. This means when HD->CRT restore writes this value back to batocera.conf, it will match what `currentMode` reports after reboot.

## CRT Mode Backup — Other Files

```
video_output.txt:   global.videooutput=DP-1
hd video_output:    global.videooutput=eDP-1
```

## boot-custom.sh

NOT FOUND — log says "Dual-boot: created unified boot-custom.sh" but it may have been created and then the overlay wasn't saved yet. Will verify on next CRT boot.

## Log Issue Found: False "ERROR" in Verification

```
[00:24:14]: ERROR: es_systems_crt.cfg missing emulatorlauncher - RE-COPYING...
```

This is at `03_backup_restore.sh` line 1532. The grep checks for literal "emulatorlauncher" in es_systems_crt.cfg. Since we now use `crt-launcher.sh` in the command tag, "emulatorlauncher" doesn't appear. The re-copy source is the repo file (which has the wrapper command), so the file stays correct. But the log is misleading.

Same issue exists at `mode_switcher.sh` line 196 — same grep check.

**Fix needed:** Update both verification greps to also accept `crt-launcher` (or just check for `launcher`).

## Assessment

CRT->HD switch completed. The critical `video_mode.txt` has `769x576.50.00` (correct precision from `batocera-resolution currentMode`). When HD->CRT restore runs, this value will be written to `global.videomode` in batocera.conf. Combined with the wrapper sync, the emulatorlauncher should see a matching mode. System about to shut down for Wayland boot.
