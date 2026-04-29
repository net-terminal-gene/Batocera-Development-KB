# PR Status - Mode Switcher Truncated global.videomode

## PR #395 (MERGED 2026-04-23)

|| Field | Value |
||-------|-------|
|| Repo | ZFEbHVUE/Batocera-CRT-Script |
|| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
|| Branch | `crt-hd-mode-switcher-v43` → `main` |
|| Status | **MERGED** (2026-04-23) |

**Shipped in:** Commit `64b9a16` (2026-04-16) and final merge. See `VERDICT.md`.

Fixes:
- Always write resolved `$boot_mode_id` (never truncated)
- Back up `es_resolution.txt` independently
- `03_backup_restore.sh` prefers `es_resolution.txt` on restore
- `crt-launcher.sh` syncs videomode strings before emulatorlauncher
