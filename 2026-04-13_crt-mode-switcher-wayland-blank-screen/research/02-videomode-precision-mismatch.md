# Research: Videomode Precision Mismatch — Root Cause of CRT OSD Flash

**Date:** 2026-04-14
**Relates to:** `debug/x11/03-hidewindow-fallback-complete-state.md`

**Shipped (2026-04-16):** `crt-launcher.sh` now syncs `global.videomode` / `CRT.videomode` to `batocera-resolution currentMode` **unconditionally** (dual-boot gate removed). Together with `HideWindow=true` on CRT restore (`03_backup_restore.sh`), removes spurious `emulatorlauncher` `changeMode()` / CRT OSD flash on script launches. Branch `crt-hd-mode-switcher-v43`, commit `64b9a16`.

---

## Discovery

While investigating the OSD flash caused by HideWindow=true, live device inspection revealed a videomode precision mismatch:

| Source | Value |
|--------|-------|
| `batocera.conf` (`global.videomode=`) | `769x576.50.00060` |
| `batocera-resolution currentMode` | `769x576.50.00` |

These represent the same resolution but with different decimal precision. `videomodes.conf` stores mode IDs at higher precision (6 decimal places). `batocera-resolution currentMode` reports a truncated form (2 decimal places).

---

## How This Causes the Flash

### emulatorlauncher's videomode management

`emulatorlauncher` (Python, `/usr/bin/emulatorlauncher`) reads `global.videomode` from `batocera.conf` and compares it against `batocera-resolution currentMode`. If the strings differ, it calls `changeMode()` to switch to the configured mode.

The comparison is a string match, not a numeric comparison. `769x576.50.00060` != `769x576.50.00`, so emulatorlauncher treats this as a mode change, even though they refer to the same physical resolution.

### The flash sequence

1. User launches Mode Switcher from ES
2. ES calls `system(command)` where command = `crt-launcher.sh ... emulatorlauncher ...`
3. emulatorlauncher reads `global.videomode=769x576.50.00060`
4. emulatorlauncher calls `batocera-resolution currentMode` → gets `769x576.50.00`
5. String mismatch → `changeMode("769x576.50.00060")` → **real resolution switch → CRT OSD flash**
6. Script runs (xterm with mode_switcher.sh)
7. Script exits → emulatorlauncher restores mode → **second resolution switch → second OSD flash**

### Evidence confirming this

When `emulatorlauncher` was bypassed entirely (changing `es_systems_crt.cfg` to `/bin/bash %ROM%`), the flash disappeared completely. HideWindow=true still released the DRM plane, xterm appeared smoothly, and the CRT showed zero sync disruption. The only change was removing emulatorlauncher from the launch chain.

---

## Why crt-launcher.sh Doesn't Fix This

`crt-launcher.sh` was specifically created to fix this precision mismatch. It syncs `global.videomode` in `batocera.conf` to match `batocera-resolution currentMode` before calling `emulatorlauncher`.

However, the sync is gated behind a dual-boot detection check:

```bash
if [ -f "/boot/crt/linux" ] && [ -f "/boot/crt/initrd-crt.gz" ]; then
    # ... sync logic ...
fi
```

These files (`/boot/crt/linux` and `/boot/crt/initrd-crt.gz`) only exist on dual-boot systems that have a separate CRT kernel. On single-boot CRT systems (like the current test device), these files do not exist, so the sync is skipped entirely.

Verified on device:
```
ls /boot/crt/linux → No such file or directory
ls /boot/crt/initrd-crt.gz → No such file or directory
```

The comment in `crt-launcher.sh` says: "Single-boot X11 systems skip the sync — zero behavior change." This was written under the assumption that single-boot systems would not have a precision mismatch. That assumption is wrong: the mismatch exists regardless of boot configuration because it originates from how `videomodes.conf` stores mode identifiers vs how `batocera-resolution` reports them.

---

## Proposed Fix

Remove the dual-boot gate from `crt-launcher.sh`. The videomode sync should run unconditionally for any CRT/X11 system.

### Current code

```bash
if [ -f "/boot/crt/linux" ] && [ -f "/boot/crt/initrd-crt.gz" ]; then
    export DISPLAY="${DISPLAY:-:0.0}"
    CURRENT=$(batocera-resolution currentMode 2>/dev/null)
    if [ -n "$CURRENT" ]; then
        CONF=/userdata/system/batocera.conf
        if grep -q "^global.videomode=" "$CONF" 2>/dev/null; then
            sed -i "s|^global.videomode=.*|global.videomode=$CURRENT|" "$CONF"
        fi
        if grep -q "^CRT.videomode=" "$CONF" 2>/dev/null; then
            sed -i "s|^CRT.videomode=.*|CRT.videomode=$CURRENT|" "$CONF"
        fi
    fi
fi
```

### Proposed code

Remove the outer `if` and its `fi`. The sync runs unconditionally:

```bash
export DISPLAY="${DISPLAY:-:0.0}"
CURRENT=$(batocera-resolution currentMode 2>/dev/null)
if [ -n "$CURRENT" ]; then
    CONF=/userdata/system/batocera.conf
    if grep -q "^global.videomode=" "$CONF" 2>/dev/null; then
        sed -i "s|^global.videomode=.*|global.videomode=$CURRENT|" "$CONF"
    fi
    if grep -q "^CRT.videomode=" "$CONF" 2>/dev/null; then
        sed -i "s|^CRT.videomode=.*|CRT.videomode=$CURRENT|" "$CONF"
    fi
fi
```

### Safety analysis

The sync overwrites `global.videomode` (and `CRT.videomode` if present) in `batocera.conf` with the current active mode string. This is safe because:

1. If the mode is already correct (strings match), `sed` writes the same value. No-op.
2. If there's a precision mismatch, `sed` fixes the string to match the live state. This prevents `emulatorlauncher` from calling `changeMode()`.
3. The sync does NOT change the actual display resolution. It only aligns the config string with what is already active.
4. On HD/Wayland systems, `batocera-resolution currentMode` returns the current Wayland mode. Syncing this is also correct because it prevents emulatorlauncher from attempting a spurious mode change there too.
5. If `batocera-resolution` fails or returns empty, the inner `if [ -n "$CURRENT" ]` guard prevents any writes.

### What this achieves

With both fixes in place:
- **HideWindow=true** releases ES's DRM plane so xterm can appear
- **crt-launcher.sh videomode sync** prevents emulatorlauncher from triggering a mode change

Net result: xterm appears immediately after launch with zero OSD flash and zero blanking.

---

## Scope of Impact

### What uses crt-launcher.sh

Only CRT system scripts (mode_switcher.sh, geometry tools, etc.) launched from ES via `es_systems_crt.cfg`. The CRT system `<command>` tag invokes:

```
crt-launcher.sh ... emulatorlauncher ... -system crt -rom %ROM%
```

### What does NOT use crt-launcher.sh

- Emulator launches (PS1, PS3, SNES, etc.) use `emulatorlauncher` directly. Those have their own videomode management and are not affected by this change.
- Steam and other BUA add-ons have their own launch paths.
- The mode switcher itself (once xterm is open) does not go through emulatorlauncher.

### Effect on dual-boot systems

No regression. The sync was already running on dual-boot systems. Removing the gate makes it run on single-boot too. Same behavior, wider coverage.

---

## Remaining Questions

1. Does the precision mismatch also affect the `crt.videomode` per-system key? (Checked: the sync already covers `CRT.videomode` if present)
2. Should other wrapper scripts that call `emulatorlauncher` also perform this sync? (Currently only `crt-launcher.sh` wraps `emulatorlauncher` for the CRT system)
3. Is the mismatch re-introduced after a mode switch? (The mode switcher writes videomode values from `videomodes.conf`, which stores high-precision strings. After a HD-to-CRT switch, the mismatch reappears until the next `crt-launcher.sh` invocation syncs it.)
