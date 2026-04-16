# PR Status — CRT Mode Switcher: Wayland Blank Screen + X11 Follow-Ons

## PR #395 (primary delivery path)

| Field | Value |
|-------|-------|
| Repo | ZFEbHVUE/Batocera-CRT-Script |
| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
| Branch | `crt-hd-mode-switcher-v43` |
| Title | v43 Wayland/X11 Dual-Boot (and mode switcher fixes) |
| Status | **OPEN Draft** |
| Ship note | Commit `64b9a16` (2026-04-16): shim (labwc + X11 HideWindow notes), unconditional `crt-launcher.sh` videomode sync, `03_backup_restore.sh` HideWindow per mode + **removed HD `killall emulationstation`**, `02_hd_output_selection.sh` boot / `es.resolution` persistence |

## Scope recap

| Area | KB / fix |
|------|----------|
| Wayland wrong display | **FIXED** — labwc window rule in `crt/mode_switcher.sh` (`VERDICT.md`) |
| X11 xterm behind ES DRM | **FIXED** — `HideWindow=true` on CRT restore (`03_backup_restore.sh`) |
| CRT OSD flash on script launch | **FIXED** — unconditional videomode sync in `crt-launcher.sh` (`research/02-videomode-precision-mismatch.md`) |
| Second CRT→HD no reboot / mixed state | **FIXED** — remove `killall emulationstation` during HD restore (`debug/x11/04-hd-restore-killall-es-regression.md`) |

PR #390 (v42-oriented) may overlap; v43 work tracks on #395 / `crt-hd-mode-switcher-v43`.
