# Research — HD/CRT Mode Switcher

## Findings

- Overlay file at `/boot/boot/overlay` controls system-level changes; removing it restores vanilla Batocera
- DRM sysfs (`/sys/class/drm/card*-*/status`) is the reliable way to detect connected outputs in CRT mode (xrandr may not list CRT-timing outputs correctly)
- `batocera-save-overlay` persists changes from `/etc/X11/xorg.conf.d/` into the overlay
- `batocera-resolution setOutput` provides immediate display switching without reboot
- MAME ini hierarchy (`mame.ini`, `ini/vertical.ini`, `ini/horizont.ini`) must be swapped as a complete folder to preserve TATE/YOKO
- Boot resolutions in `videomodes.conf` are prefixed with `Boot_`; hardened parsing needed for user-edited files (empty lines, comments, short mode IDs)

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

