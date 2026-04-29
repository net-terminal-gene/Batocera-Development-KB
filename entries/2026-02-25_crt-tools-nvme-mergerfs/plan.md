# CRT Tools on Boot Drive (mergerFS Conflict)

## Agent/Model Scope

Composer + ssh-batocera. Depends on 2026-02-24_bsm-mergerfs-nc-fix (applied and verified).

## Problem

With the mergerFS `=NC` fix applied, new file writes to `/userdata/roms/` go to external drives, not the boot drive. The Batocera-CRT-Script mode switcher **requires** CRT Tools (`/userdata/roms/crt/`) to be on the **Batocera boot drive** (NVMe, SATA, or microSD) during HD/CRT mode switches because:

1. Mode switches run on boot or live — external drives may not be mounted yet
2. The switcher reads `GunCon2_Calibration.sh` from `/userdata/roms/crt/` to get video output
3. The switcher **writes** all CRT tools to `/userdata/roms/crt/` on every mode switch (`rm -rf` + `cp`)
4. With `=NC`, those writes would land on an external drive (BATO-PARROT, etc.) — tools disappear if the drive is disconnected during a switch

Currently crt is on BATO-PARROT; it needs to be on the boot drive.

## Root Cause

- mergerFS `=NC` fix correctly blocks new files on the boot-drive base for retro ROMs
- CRT Tools live under `/userdata/roms/crt/` — the mergerFS pool
- No exception exists for the `crt` subdirectory; mergerFS has no per-path policies
- Mode switcher (`03_backup_restore.sh`) hardcodes `/userdata/roms/crt` for reads and writes

## Solution

**Option A — Bind mount (recommended)**

Overlay `/userdata/roms/crt` with the boot-drive physical path so all access goes to the boot drive:

```bash
mkdir -p /userdata/.roms_base/crt
mount --bind /userdata/.roms_base/crt /userdata/roms/crt
```

Must run **after** mergerFS mounts `/userdata/roms`, **before** mode switcher or EmulationStation. Add to Batocera boot sequence (e.g. `custom.sh`, or a new init script that runs after `S11share`/storage manager).

One-time migration: copy current CRT content from BATO-PARROT to `/userdata/.roms_base/crt/` (boot drive) before enabling bind mount.

**Option B — Script change**

Modify `03_backup_restore.sh` to use `/userdata/.roms_base/crt` when the mergerFS pool is active (`.roms_base` exists). Update `es_systems_crt.cfg` to point the CRT system at that path. More invasive; ES may expect `/userdata/roms/crt`.

**Option C — Separate path**

Use `/userdata/roms_crt/` (outside the mergerFS pool). Update mode switcher and `es_systems_crt.cfg`. Diverges from standard roms layout.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | TBD (boot script or mode switcher) | Add bind mount or CRT path logic |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | If Option B: use `CRT_ROMS_PATH` variable |
| Batocera-CRT-Script | `Geometry_modeline/es_systems_crt.cfg` | If Option B/C: change path |

## Validation

- [ ] CRT Tools visible in EmulationStation after boot (with and without external drives)
- [ ] HD→CRT mode switch succeeds with only boot drive connected
- [ ] CRT→HD mode switch succeeds
- [ ] GunCon2_Calibration.sh readable by mode switcher
- [ ] No new files created on external drives under `crt/` after mode switch

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

