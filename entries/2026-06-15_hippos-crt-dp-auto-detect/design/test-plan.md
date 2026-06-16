# Test plan — HippOS CRT (self-hosted)

**Hardware:** `hippos.local` — DP-1 + DP-to-VGA DAC, AMD Navi/RDNA  
**Base OS:** HippOS 0.4.17+ (flash or existing install)

## Deploy dev changes (Mac)

```bash
cd ~/hippos-linux
./docs/dev-sync-crt.sh hippos.local
```

ES binary (after Docker build):

```bash
docker build -f docker/frontend/emulationstation.Dockerfile -t hippos-es-build .
docker run --rm --platform linux/amd64 -v "$PWD:/work" -w /work hippos-es-build \
  bash -c 'packages/frontend/emulationstation/build.sh'
rsync -av artifacts/frontend/emulationstation/usr/bin/emulationstation root@hippos.local:/usr/bin/
```

## Reset to fresh-user CRT state

```bash
ssh root@hippos.local 'hippos-crt-teardown; rm -f /userdata/system/hippos.conf; reboot'
```

## Phase 2 pass (pipeline, SSH settings OK)

```bash
ssh root@hippos.local 'hippos-settings set crt.enabled true crt.output DP-1 crt.monitor_profile generic_15 crt.boot_resolution 640x480i'
ssh root@hippos.local reboot
# After boot — NO manual hippos-crt-setup
ssh root@hippos.local 'DISPLAY=:0 xrandr --verbose | grep -A6 current; cat /proc/cmdline'
```

Pass: `641x480i` @ ~15 kHz; cmdline has `video=DP-1:` + `drm.edid_firmware`.

## Phase 3 pass (ES only)

1. Reset (above) or reflash
2. System Settings → CRT → Enable → DP-1 → profile → boot resolution → Reboot
3. ES readable on CRT on **first** reboot after save (no SSH during configure)

## switchres apply

```bash
ssh root@hippos.local 'DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini; echo exit=$?'
```

Pass: exit 0 (not 139).

## Failure signs

| Symptom | Likely cause |
|---------|----------------|
| DoubleScan / unreadable ES | `xrandr --auto` or CRT setup never ran |
| No `video=` in cmdline | crt-setup not run before reboot |
| switchres exit 139 | binary bug — rebuild switchres |
