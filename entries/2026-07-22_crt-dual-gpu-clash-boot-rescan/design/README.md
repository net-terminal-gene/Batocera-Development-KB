# Design — CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

## Architecture

```text
Installer (Wayland or X11 HD session)
        │
        ├─ Detect GPUs (lspci VGA/3D)
        ├─ User picks CRT output (current DRM names)
        │
        ▼
Dual-GPU clash? ──no──► existing single-GPU path (unchanged)
        │
       yes
        │
        ▼
Phase 1 — CRT isolation only
  • LABEL crt APPEND: module_blacklist=nvidia,...
  • Optional: 05-amd-only.conf (BusID + AutoAddGPU false)
  • Do NOT finalize drm.edid_firmware / video= / global.videooutput yet
    (or write provisional + flag for rescan)
  • Save overlay; require power cycle into CRT kernel
        │
        ▼
Phase 2 — first CRT boot / script resume
  • Confirm nvidia modules absent
  • Rescan DRM on CRT card only
  • Map CRT by: connected + EDID/firmware target + user confirmation if ambiguous
  • Write: drm.edid_firmware=NEWN:edid/... video=NEWN:e
           global.videooutput=NEWN
           10-monitor.conf (Ignore others)
  • Ensure 15 kHz interlaced boot mode when profile needs it
        │
        ▼
Stable CRT ES boot
```

## Key components

| Piece | Role |
|-------|------|
| Clash detector | Count PCI GPUs; CRT card ≠ NVIDIA; proprietary NVIDIA present/enabled |
| CRT APPEND editor | Only `LABEL crt` in `/boot/boot/syslinux.cfg`, `syslinux/syslinux.cfg`, EFI copy |
| Connector rescan | Post-blacklist names; never trust pre-blacklist `DP-N` after isolation |
| Xorg AMD-only | Prevents `modeset(G0)` even if modules leak |
| HD LABEL | Untouched so NVIDIA remains available for Wayland HD / Steam |

## Design constraints

- **CRT boot only** — never BIOS, never Windows drive, never HD LABEL blacklist.
- **Renumber is expected** — treat connector string as unstable across isolation transitions.
- **Prefer rescan over prediction** when installer can resume after reboot (matches user ask).
- **Single-GPU** — zero extra prompts/phases.
