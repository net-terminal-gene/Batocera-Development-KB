# CRT Mode Switcher: CRT Boot Resolution Does Not Persist After HD-to-CRT Switch

## Agent/Model Scope

Composer + ssh-batocera.

## Problem

After using the mode switcher to go from HD Mode back to CRT Mode, the CRT boot resolution does not persist. ES shows "Auto" instead of the correct Boot_576i entry. The user believed this was addressed by `2026-04-11_crt-installer-videomode-bootstrap` (FIXED), but that fix covers the INSTALL path. This bug is on the MODE SWITCH backup/restore path.

## Root Cause

`restore_video_settings` derives `es.resolution` from `video_mode.txt`, which stores `global.videomode`. But `batocera-resolution currentMode` returns empty in CRT/X11 mode, so the backup falls back to grepping `batocera.conf` for `global.videomode`, which has a truncated value (`769x576.50.00` instead of the full-precision `769x576.50.00060`).

The restore sequence:
1. Full `batocera.conf` is restored from CRT backup (has correct `es.resolution=769x576.50.00060`)
2. `restore_video_settings` runs AFTER, reads `video_mode.txt` (truncated `769x576.50.00`)
3. Derives `es.resolution` from the truncated value, overwriting the correct full-precision value

ES compares `es.resolution` against `batocera-resolution listModes` full IDs. Truncated value doesn't match, so ES shows "Auto."

Same truncation root cause as `2026-04-08_crt-mode-switcher-truncated-videomode`, manifesting in the restore path.

## Solution

1. **`backup_video_settings`:** Also save `es.resolution` separately to `es_resolution.txt` so the full-precision value is preserved independently of `global.videomode`
2. **`restore_video_settings`:** When writing `es.resolution`, prefer the backed-up `es_resolution.txt` value over deriving it from `video_mode.txt`. Falls back to `video_mode.txt` derivation if `es_resolution.txt` doesn't exist.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `mode_switcher_modules/03_backup_restore.sh` | `backup_video_settings`: save `es.resolution` to `es_resolution.txt`; `restore_video_settings`: prefer `es_resolution.txt` over `video_mode.txt` derivation |

## Validation

- [ ] Configure CRT boot resolution (e.g., Boot_576i) in CRT mode
- [ ] Switch to HD mode via mode switcher
- [ ] Switch back to CRT mode via mode switcher
- [ ] Verify CRT boot resolution is preserved (not reset to Auto)
- [ ] Check `es.resolution` in batocera.conf has full precision after restore
- [ ] Check `es.resolution` in batocera-boot.conf has full precision after restore

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

