# Debug — HippOS CRT DP auto-detect

## Logs

| File | Summary |
|------|---------|
| [01-workaround-validated.md](01-workaround-validated.md) | **Phase 1 ✅** — `crt.enabled=true` + reboot; CRT PASS |

## Verification

```bash
# HippOS — CRT state
ssh root@hippos.local "grep crt /userdata/system/hippos.conf"
ssh root@hippos.local "DISPLAY=:0 xrandr --verbose | grep -A6 'current'"
ssh root@hippos.local "cat /proc/cmdline"
ssh root@hippos.local "ls /etc/X11/xorg.conf.d/*crt* /etc/switchres.ini 2>&1"
ssh root@hippos.local "wc -c /sys/class/drm/card*-DP-1/edid"

# switchres apply test (expect segfault on HippOS until fixed)
ssh root@hippos.local "DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini; echo exit=\$?"

# Batocera reference (working)
ssh root@batocera.local "DISPLAY=:0 xrandr --verbose | grep -A6 '641x480'"
ssh root@batocera.local "grep video= /proc/cmdline"
```

## Workaround test sequence

```bash
ssh root@hippos.local "hippos-settings set crt.enabled true && hippos-crt-setup"
# reboot required for kernel video= and Xorg CRT conf
ssh root@hippos.local "reboot"
# after reboot, re-run verification commands above
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Rolling / squashed / unreadable ES on CRT | 31 kHz DoubleScan mode, not 15 kHz interlaced |
| No `*crt*` files in xorg.conf.d | `crt.enabled=auto` skipped DP-1; setup never ran |
| No `video=` in cmdline | CRT setup did not run before last boot |
| switchres exit 139 | switchres apply segfault — runtime mode switch broken |
| `interlace_force_even=0` on Navi/RDNA | DCN detection failed; interlaced lines may be wrong |
| Batocera OK, HippOS bad, same CRT | Software pipeline gap, not hardware |
