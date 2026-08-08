# Debug — CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

## Verification

```bash
# CRT boot only
cat /proc/cmdline
# expect: module_blacklist=nvidia,... and drm.edid_firmware=DP-N:edid/... matching live CRT

lsmod | grep nvidia || echo NVIDIA_MODULES_NONE

# DRM map
for c in /sys/class/drm/card*-*-*/status; do echo "$c=$(cat $c)"; done

DISPLAY=:0 xrandr
# CRT should be primary; preferred/current should be 15 kHz interlaced when using ms929-style EDID

pgrep -af emulationstation
grep -E 'modeset\(G0\)|Failed to create pixmap|Fatal server error' /var/log/Xorg.0.log || echo no-dual-gpu-x-fatal

grep -E '^(global\.videooutput|es\.resolution|global\.videomode)=' /userdata/system/batocera.conf
tail -30 /userdata/system/logs/display.log
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| "Symlink creation pass completed" looping, no ES | X dead; check `modeset(G0)` / pixmap fatal |
| `modprobe.blacklist` in cmdline but `lsmod` shows nvidia | Need hard `module_blacklist`; Batocera force-loads NVIDIA |
| ES running, CRT black, ultrawide weird | Connector renumber; `global.videooutput` stale (e.g. DP-5 vs DP-2) |
| CRT has progressive `641x480` not `641x480i` | Mode pick wrong for 15 kHz CRT; force interlaced |
| HD boot lost NVIDIA | Blacklist accidentally applied to `LABEL batocera` — must be CRT-only |

## Lab recovery log (2026-07-22)

1. Soft blacklist → still crashed.
2. Hard `module_blacklist` + `05-amd-only.conf` → ES up, CRT black (drove ultrawide `DP-1`).
3. Retarget EDID/video/`global.videooutput` to `DP-2`, Ignore `DP-1`, force `641x480i` → ES on CRT.
