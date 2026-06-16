# 02 — hippos-xorg-setup: CRT setup before X

**File:** `overlays/rootfs/usr/lib/hippos/hippos-xorg-setup`

## Current (CRT not configured before X starts)

```bash
#!/usr/bin/env bash
# hippos-xorg-setup — runs as ExecStartPre for hippos-xserver.service.
...
rm -f /etc/X11/xorg.conf.d/91-gpu-setup.conf \
      /etc/X11/xorg.conf.d/90-hippos-prime.conf

log() { printf '[hippos-xorg-setup] %s\n' "$*"; }
log "done (nvidia OutputClass handled by package)"
```

## Recommended

Run `hippos-crt-setup` when CRT is enabled **before** Xorg starts, so `90-crt-gpu.conf` and friends exist on first boot after user enables CRT:

```bash
#!/usr/bin/env bash
# hippos-xorg-setup — runs as ExecStartPre for hippos-xserver.service.

rm -f /etc/X11/xorg.conf.d/91-gpu-setup.conf \
      /etc/X11/xorg.conf.d/90-hippos-prime.conf

log() { printf '[hippos-xorg-setup] %s\n' "$*"; }

_crt_wanted() {
    local v
    v="$(hippos-settings get crt.enabled 2>/dev/null || true)"
    [[ "${v}" == "true" ]]
}

if _crt_wanted; then
    log "CRT enabled — running hippos-crt-setup before X"
    /usr/lib/hippos/hippos-crt-setup || log "hippos-crt-setup failed"
elif [[ -f /etc/X11/xorg.conf.d/90-crt-gpu.conf ]]; then
    log "CRT disabled — running hippos-crt-teardown"
    /usr/lib/hippos/hippos-crt-teardown || true
fi

log "done"
```

**Note:** `hippos-display-setup` can still call crt-setup idempotently at session start for switchres apply; pre-X run fixes first-reboot Xorg config.

GRUB `video=` still requires reboot after first crt-setup (unchanged); pre-X fixes X reading CRT snippets on same boot after prior session wrote `/etc`.
