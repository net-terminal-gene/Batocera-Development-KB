# 04 — hippos-crt-setup: DCN interlace_force_even

**File:** `overlays/rootfs/usr/lib/hippos/hippos-crt-setup`

## Current

```bash
_detect_dcn() {
    local f
    for f in /sys/kernel/debug/dri/*/amdgpu_ip_info; do
        [[ -f "${f}" ]] || continue
        grep -qi "dcn" "${f}" 2>/dev/null && echo "dcn" && return
    done
    dmesg 2>/dev/null | grep -qi "amdgpu.*dcn\b\|dcn.*display" && echo "dcn" && return
    echo "dce"
}
```

On Navi 32 (RDNA3), debugfs often unavailable → returns `dce` → `interlace_force_even=0` (wrong).

## Recommended: add PCI / IP discovery fallback

After dmesg check, before returning `dce`:

```bash
_detect_dcn() {
    local f
    for f in /sys/kernel/debug/dri/*/amdgpu_ip_info; do
        [[ -f "${f}" ]] || continue
        grep -qi "dcn" "${f}" 2>/dev/null && echo "dcn" && return
    done
    dmesg 2>/dev/null | grep -qi "amdgpu.*dcn\b\|dcn.*display" && echo "dcn" && return
    # soc21 / Navi (GCN 11+) / RDNA — DCN display engine
    dmesg 2>/dev/null | grep -qi "soc21_common\|ip block.*dcn\|Navi" && echo "dcn" && return
    lspci -nn 2>/dev/null | grep -qi "1002:7[0-9a-f][0-9a-f][0-9a-f]" && echo "dcn" && return
    echo "dce"
}
```

Tune PCI ID ranges against your supported GPU matrix; goal is **Navi/RDNA APUs and dGPUs get IFE=1**.

Validated workaround on test box: manual `sed` to `interlace_force_even=1` before reboot; output OK even when setup resets to 0 on re-run.
