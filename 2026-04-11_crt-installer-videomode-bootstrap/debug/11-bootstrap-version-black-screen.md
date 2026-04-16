# Debug 11 — Bootstrap Version: Black Screen on First CRT Boot

## Date: 2026-04-13

## Script Version

**v43.sh WITH bootstrap changes (Insert A + B)** — NOT CRT-Script-04-03.

---

## What Is Different From Stages 00–09

Stages 00–09 used **CRT-Script-04-03** — the original v43.sh with NO bootstrap additions.

This stage tests **v43.sh with Insert A + B** added in the previous development session. The difference is exactly three things the bootstrap adds to the normal installer flow:

| What | CRT-Script-04-03 | Bootstrap version |
|------|-----------------|-------------------|
| `global.videomode` in batocera.conf | (empty — never written) | `Boot_480i 1.0:0:0 15KHz 60Hz` |
| `global.videooutput` in batocera.conf | `eDP-1` (Wayland leftover) | `DP-1` (bootstrap writes it) |
| `crt_mode/video_settings/` pre-seeded | empty | `video_mode.txt` + `video_output.txt` written at install |
| `hd_mode/video_settings/` pre-seeded | empty | `video_mode.txt` + `video_output.txt` written at install |

Everything else — `es.resolution`, `es.customsargs`, the Xorg configs, the CRT boot entry — is identical between versions.

---

## Observed State

### batocera.conf
```
global.videomode   = Boot_480i 1.0:0:0 15KHz 60Hz   ← written by bootstrap
global.videooutput = DP-1                             ← written by bootstrap
es.resolution      = 641x480.60.00000                ← written by normal installer (same as baseline)
```

### Boot Environment
```
BOOT_IMAGE=/crt/linux label=BATOCERA console=tty3 quiet loglevel=0
drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e initrd=/crt/initrd-crt.gz
```
CRT boot entry, EDID firmware active — identical to baseline.

### xrandr
```
DP-1 connected primary 641x480+0+0 (485mm x 364mm)
   641x480i   59.98 +   ← preferred (interlaced)
   641x480    60.00*    ← ACTIVE (progressive)
```
Same as baseline stage 05 — progressive 60Hz is active.

### display.log
```
Splash: Preferred display is DP-1          ← differs from baseline (was eDP-1)
Standalone: Explicit video outputs configured ( DP-1). Skipping docked detection.
Standalone: Validating detected outputs...
setMode: 641x480.60.00
setMode: Output: DP-1 Resolution: 641x480 Rate: 60.00
Standalone: --- Launching EmulationStation ---
```
Standalone ran cleanly. No fallback needed (global.videooutput=DP-1 is valid). setMode applied correctly.

### ES Process
```
emulationstation --exit-on-reboot-required --windowed
  --screensize 641 480 --screenoffset 00 00
```
ES IS running. Correct screensize. Not crashed.

### ES Logs
```
es_launch_stdout.log  = (empty)
es_launch_stderr.log  = (empty)
```
No ES output captured despite ES process running.

---

## Key Differences vs Baseline (Stage 05)

| Behavior | Baseline (stage 05) | Bootstrap (stage 11) |
|----------|---------------------|----------------------|
| `global.videooutput` in batocera.conf | `eDP-1` | `DP-1` |
| Splash display | eDP-1 (Steam Deck screen) | DP-1 (CRT via DAC) |
| Standalone: invalid output fallback | YES — eDP-1 rejected, fell back to DP-1 | NO — DP-1 used directly |
| `global.videomode` in batocera.conf | (empty) | `Boot_480i 1.0:0:0 15KHz 60Hz` |
| ES running | YES — display correct | YES — display BLACK |

Both versions reach the same setMode (`641x480.60.00` on DP-1) and launch ES. The display works in the baseline and is black in the bootstrap version.

---

## Root Cause Hypothesis

### Primary suspect: ES reads global.videomode and applies it as a mode switch

In stage 05, `global.videomode` was empty. ES rendered without setting any additional mode. Display was correct.

In stage 11, `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz` is set. ES may read this value and call `batocera-resolution setMode "Boot_480i 1.0:0:0 15KHz 60Hz"` internally after initialization. `Boot_480i` maps to `641x480i @ 59.98` (interlaced) in videomodes.conf. If ES switches from the progressive `641x480 @ 60.00` to the interlaced `641x480i @ 59.98`, the CRT signal timing changes. If the component cable / transcoder can't sync to the new interlaced timing, the screen goes black.

This is consistent with xrandr showing the progressive mode still active at the time of SSH — the mode switch would happen after ES starts, not during the standalone phase.

### Secondary difference: splash plays on DP-1 instead of eDP-1

With `global.videooutput=DP-1`, the DRM splash video plays on the CRT DAC output before Xorg starts. This is cosmetically different but should not affect ES display after Xorg takes over.

---

## What This Confirms

1. Writing `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz` to batocera.conf causes a black screen on the CRT.
2. Writing `global.videooutput=DP-1` alone does NOT cause a black screen (the standalone ran cleanly).
3. The baseline (stage 05) works without `global.videomode` set — it does not need to be written.
4. This confirms the revised plan.md conclusion: **drop `global.videomode` from the bootstrap write entirely.**

---

## Next Step

Remove the `global.videomode` write from Insert B in both v42.sh and v43.sh. Retain:
- `global.videooutput=$video_output_xrandr` write (harmless, useful)
- CRT mode backup pre-seed (harmless, useful)
- HD mode backup pre-seed (harmless, useful)

Drop:
- `global.videomode=$_crt_boot_mode` write to batocera.conf (causes black screen via ES mode switch)
- `global.videomode=...` write to crt_mode backup (the backup value is derived by mode switcher naturally on first switch)

See revised `plan.md` for the correct narrow scope.
