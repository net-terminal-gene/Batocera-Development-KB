# Mode Switcher RetroArch Remaps Loss

## Agent/Model Scope

Composer + ssh-batocera for validation on hardware. Primary file: `03_backup_restore.sh`.

**Branch:** `fix/crt-mode-switcher-retroarch-remaps` off `upstream/main` @ `60a13c4` (2026-06-01). Implementation in working tree; not committed until Batocera QA.

**Related WIP (separate branch):** Wayland `es.resolution` fix lives on `fix/crt-hd-wayland-es-resolution-restore` @ `ce2838c` — do not merge with this branch without careful conflict resolution in `03_backup_restore.sh`.

## Problem

User report (GitHub): after CRT/HD mode switch, RetroArch controller remaps (e.g. Genesis Plus GX core-level `.rmp` at `config/remaps/Genesis Plus GX/Genesis Plus GX.rmp`) are lost on return to CRT mode.

Observed in backup folder:
- `emulator_configs/retroarch/config/` present at top level (often empty remaps)
- Remap file only under `emulator_configs/retroarch/retroarch/config/remaps/...`

Empty remaps in HD mode after switch is expected (separate per-mode RetroArch trees). Failure to restore on CRT return is the bug.

Affects X11 and Wayland equally (same `03_backup_restore.sh` path).

## Root Cause

**Primary (confirmed in code review):** `backup_mode_files()` copies RetroArch (and MAME) with `cp -ra source dest` without removing `dest` first. When `${backup_dir}/emulator_configs/retroarch` already exists from a prior backup, `cp` nests live tree as `dest/retroarch/` instead of replacing `dest`. Second and later backups of the same mode corrupt the snapshot. Restore copies the mangled tree back to live; RetroArch reads canonical `config/remaps/` at top level (empty/stale).

**Secondary:** First CRT→HD switch deletes live RetroArch if `hd_mode/emulator_configs/retroarch` was never seeded (install only bootstraps `hd_mode/video_settings`). CRT snapshot should still hold remaps for return trip unless corrupted by primary bug.

**Design gap:** Remaps are user preferences, not CRT-vs-HD-specific settings, but entire `/userdata/system/configs/retroarch` is swapped per mode.

## Solution

1. **Minimal fix:** Before backup copy, `rm -rf "${backup_dir}/emulator_configs/retroarch"` (same for `mame`). Ensures clean replace each backup.
2. **Restore normalization (optional):** On restore, hoist `retroarch/retroarch/config/remaps/*` → `config/remaps/` if nested path detected (repairs existing corrupted backups).
3. **Longer term:** Exclude `config/remaps/` from mode swap, or merge remaps across modes instead of wholesale tree replace.
4. **Install bootstrap (optional):** Seed `hd_mode/emulator_configs/retroarch` at CRT install so first CRT→HD does not delete without replacement.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| ZFEbHVUE/Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | `rm -rf` before emulator config backup; optional restore normalize |
| ZFEbHVUE/Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Optional: seed HD retroarch snapshot at install |

## Validation

- [ ] Fresh CRT install; create Genesis Plus GX core remap in CRT mode
- [ ] CRT→HD→CRT round trip: remap loads in CRT after return
- [ ] Second CRT→HD→CRT round trip: remap still loads (regression for cp nesting)
- [ ] Inspect backup: no `emulator_configs/retroarch/retroarch/` nested dir after second backup
- [ ] MAME folder backup same pattern (no nested `mame/mame/`)
- [ ] Verify on X11-only and dual-boot Wayland if available
