# BATO-ALL ROMs Erasure (mergerFS)

## Agent/Model Scope

Composer + ssh-batocera for remote verification. batocera.linux `batocera-storage-manager` analysis.

## Problem

**User-confirmed: ROM folders are being erased from BATO-ALL** when adding BATO-LG to the mergerFS pool. Occurred multiple times; user had to restore roms repeatedly.

**Affected systems (8):** bigfish, c64, gamehouse, model1, neogeo64, popcap, segacd, zinc (zxspectrum excluded from master list — not in ES)

**Evidence:** `roms-by-drive.md` (2026-02-27) documented systems on BATO-ALL. On 2026-02-28 those systems were gone. Master list: 50 systems; erasure reduced count to 42–48 depending on merge phase.

## Root Cause

**Identified:** Merge logic in `batocera-storage-manager` — see `debug/merge-mv-erasure-root-cause.md`.

The merge runs `mv "$POOL_PATH"/* "$BASE_DIR"/` after `umount -l`. Lazy unmount leaves the mergerFS view visible; the move operates on the merged view. For paths that exist only on BATO-ALL, mergerFS serves BATO-ALL content; the move deletes from BATO-ALL. The move can run 10+ minutes, so erasure is staggered (user restored 6, then segacd/zinc were erased later in same merge).

## Solution

1. **Correct grep pattern** — Upstream had `"fuse.mergerfs on $POOL_PATH"` which never matches. Use `" $POOL_PATH "` so the unmount block runs.
2. **Unmount retry loop** — `while mount | grep -q " $POOL_PATH "; do umount ...; done` before move.
3. **Deployment** — Patched build deployed to live Batocera via FileZilla + `batocera-save-overlay`. **batocera.linux fix merged by someone else** — no changes from this session.

## Files Touched

| Location | Change |
|----------|--------|
| **batocera.linux** | **No changes by us.** Someone else merged the fix (correct grep `" $POOL_PATH "` + unmount retry loop) upstream. |
| **Live Batocera** | Patched `batocera-storage-manager` deployed via FileZilla to `/usr/bin/`; `batocera-save-overlay` for persistence. |

## Validation

- [x] Root cause identified
- [x] Fix deployed locally (patched build via overlay)
- [x] Test merge with BATO-LG / BATO-PARROT; BATO-ALL intact
- [x] Fix merged upstream by others (no PR from this session)

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

