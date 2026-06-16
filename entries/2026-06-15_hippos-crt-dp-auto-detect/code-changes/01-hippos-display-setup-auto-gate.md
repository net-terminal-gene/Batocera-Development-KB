# 01b — hippos-display-setup: auto gate (optional legacy)

**File:** `overlays/rootfs/usr/lib/hippos/hippos-display-setup`

Only needed if keeping `crt.enabled=auto`. **Phase 3 manual UX can skip this** and remove auto entirely.

## Current (broken for DP + DAC)

```bash
_crt_auto_detect() {
    # Return the first connected VGA or DVI-I output with no EDID, or empty string.
    local p name edid_size
    for p in /sys/class/drm/card[0-9]*-*; do
        [[ -f "${p}/status" ]] || continue
        [[ "$(< "${p}/status")" == "connected" ]] || continue
        name="${p##*/}"; name="${name#card*-}"
        case "${name}" in VGA-*|DVI-I-*) ;; *) continue ;; esac   # ← skips DP-*
        edid_size=0
        [[ -f "${p}/edid" ]] && edid_size="$(wc -c < "${p}/edid")"
        [[ "${edid_size}" -eq 0 ]] && echo "${name}" && return
    done
}
```

## Recommended: shared helper (match crt-setup intent)

Extract to a shared snippet or duplicate logic — **any connected port with 0-byte EDID**, not VGA-only:

```bash
_crt_connector_edid_size() {
    local conn="${1}"
    local p edid_size=0
    for p in /sys/class/drm/card[0-9]*-*; do
        [[ -f "${p}/status" ]] || continue
        [[ "$(< "${p}/status")" == "connected" ]] || continue
        [[ "${p##*/}" == *"${conn}"* ]] || continue
        [[ -f "${p}/edid" ]] && edid_size="$(wc -c < "${p}/edid")"
        echo "${edid_size}"
        return
    done
    echo 0
}

_crt_auto_detect() {
    local p name edid_size
    for p in /sys/class/drm/card[0-9]*-*; do
        [[ -f "${p}/status" ]] || continue
        [[ "$(< "${p}/status")" == "connected" ]] || continue
        name="${p##*/}"; name="${name#card*-}"
        edid_size=0
        [[ -f "${p}/edid" ]] && edid_size="$(wc -c < "${p}/edid")"
        # Skip firmware-injected Switchres EDID (128 bytes, manufacturer SWR) if detecting teardown
        [[ "${edid_size}" -eq 0 ]] && echo "${name}" && return
    done
}
```

**Do not** use `hippos-crt-setup`'s `_connected_outputs | head -1` for auto-enable — that picks HD monitors with EDID.

## CRT enable gate (lines 25–36)

When `crt.enabled=true`, setup already runs. Ensure `true` is set only via ES / user, not auto on DP.
