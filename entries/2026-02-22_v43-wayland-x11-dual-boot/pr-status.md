# PR Status - v43 Wayland/X11 Dual-Boot Support

## PR #395 (MERGED 2026-04-23)

### Main PR

|| Field | Value |
||-------|-------|
|| Repo | ZFEbHVUE/Batocera-CRT-Script |
|| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
|| Branch | `crt-hd-mode-switcher-v43` → `main` |
|| Title | Add Wayland/X11 dual-boot support with HD↔CRT mode switching |
|| Status | **MERGED** (2026-04-23) |
|| Created | 2026-02-22 |

---

## Predecessor: PR #390 (v42 mode switcher)

PR #390 (`crt-hd-mode-switcher` → v42) merged into v42. PR #395 built on top with v43 Wayland/X11 dual-boot support.

See: [`2026-01-26_hd-crt-mode-switcher/`](../2026-01-26_hd-crt-mode-switcher/)

---

## Merged Scope

### Main Changes
- Wayland/X11 dual-kernel boot via Syslinux multi-entry
- HD ↔ CRT mode switching with full state preservation (batocera.conf, emulator configs)
- Installer integration into `Batocera-CRT-Script-v43.sh`
- CRT launcher wrapper (`crt-launcher.sh`) for videomode precision sync
- ES theme updates, CRT Tools menu integration
- New images/artwork for CRT Tools

### Files Modified
- `Batocera-CRT-Script-v43.sh` (+1250 lines of dual-boot install logic)
- `mode_switcher.sh` and modules (detection, output selection, backup/restore, UI)
- `crt/mode_switcher.sh`, `crt/mode_switcher.sh.keys` (CRT Tools launcher)
- `crt/gamelist.xml` (ES carousel)
- `crt/images/*` (logos, thumbnails, screenshots)
- `Geometry_modeline/` layout updates
- `boot-custom.sh` (mode-aware display config)

---

## Testing & Validation (from VERDICT)

- [x] Wayland ↔ X11 roundtrip (Full HD → CRT → HD → CRT)
- [x] Emulator config preservation (MAME, RetroArch)
- [x] Video mode precision sync (crt-launcher.sh wrapper)
- [x] AMD GPU testing (dev device)
- [x] Steam Deck testing
- [ ] NVIDIA GPU testing (future session)

---

## Outstanding Items

- [ ] Steam preservation module (implemented but not extensively tested in field)
- [ ] Steam videomode on CRT "Auto" mode (user workaround exists; root fix TBD)
- [ ] NVIDIA testing on v43 hardware
- [ ] Community feedback post-launch
