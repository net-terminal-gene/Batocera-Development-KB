# 03 — hippos-xserver.service: skip xrandr --auto for CRT

**File:** `overlays/rootfs/usr/lib/systemd/system/hippos-xserver.service`

## Current (fights CRT timings)

```ini
ExecStartPost=/bin/sh -c 'for i in $(seq 1 40); do [ -S /tmp/.X11-unix/X0 ] && break; sleep 0.25; done; DISPLAY=:0 xrandr --auto 2>/dev/null || true'
```

## Recommended

Guard with CRT active check (same signal as `hippos-display-setup`: crt enabled or crt xorg snippet present):

```ini
ExecStartPost=/bin/sh -c 'for i in $(seq 1 40); do [ -S /tmp/.X11-unix/X0 ] && break; sleep 0.25; done; \
  if hippos-settings get crt.enabled 2>/dev/null | grep -qx true || \
     test -f /etc/X11/xorg.conf.d/90-crt-gpu.conf; then \
    exit 0; \
  fi; \
  DISPLAY=:0 xrandr --auto 2>/dev/null || true'
```

Alternatively add `/usr/lib/hippos/hippos-xserver-post.sh` for readability and unit-test the logic.

`hippos-display-setup` already skips `--preferred`/`--auto` when CRT active (lines 64–67); xserver post must match.
