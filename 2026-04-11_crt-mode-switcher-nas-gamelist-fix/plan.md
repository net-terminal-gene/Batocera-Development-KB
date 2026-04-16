# CRT Mode Switcher: NAS Gamelist Visibility Fix

## Agent/Model Scope

Composer + ssh-batocera for live system diagnosis and verification.

## Problem

After switching from CRT to HD mode, the `mode_switcher.sh` entry disappeared from the CRT system in EmulationStation. Users on NAS-backed ROM directories experienced this most severely. The issue was first surfaced during the `2026-04-06_crt-mode-switcher-empty-backups` session but the root cause was not identified at that time.

## Root Cause

`install_crt_tools()` in `03_backup_restore.sh` used `rm -rf $CRT_ROMS/crt/*` before copying files for both modes:

- **HD mode:** delete everything, then copy only `mode_switcher.sh` + its images + `gamelist.xml`
- **CRT mode:** delete everything, then copy all CRT tools

On NAS-backed ROM directories (CIFS/NFS mounts), the `rm -rf` write would be committed before reboot, but the subsequent `cp` for the new files would not flush in time — leaving the directory empty after reboot.

Even without a NAS, the selective HD-mode copy was fragile: if anything interrupted after the `rm -rf` but before the copies completed, all CRT tools were lost.

## Solution

Remove all `rm -rf` calls from `install_crt_tools()`. Always copy the full CRT tools suite to `$CRT_ROMS/crt/` in both modes. Use `gamelist.xml` `<hidden>` tags to control what EmulationStation shows per mode:

- **HD mode:** all entries hidden except `mode_switcher.sh`
- **CRT mode:** all `<hidden>` tags removed — everything visible

A new `set_crt_gamelist_visibility()` function handles the `gamelist.xml` manipulation via `awk` (to add hidden tags) and `sed` (to remove them).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | Remove `rm -rf`, unified `cp -a`, add `set_crt_gamelist_visibility()` |
| Batocera-CRT-Script | `Geometry_modeline/crt/gamelist.xml` | Source gamelist already correct — no change needed |

Applied to two branches:
- `crt-hd-mode-switcher` (v42) — PR #390 — pushed and tested ✓
- `crt-hd-mode-switcher-v43` (v43 Wayland/X11) — PR #395 — not yet tested (TBD)

## Validation

- [x] Switch CRT → HD: verify only mode_switcher.sh visible in ES CRT system
- [x] Switch HD → CRT: verify all CRT tools visible in ES CRT system
- [x] Confirm 0 `<hidden>` tags in gamelist.xml after CRT mode switch
- [x] Confirm other tools still present on disk in HD mode (not deleted)
- [ ] Repeat full test on v43 branch (PR #395) — not yet tested

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

