# mergerFS Merge Move — Safe Masking Fix

## Agent/Model Scope

Composer + ssh-batocera for validation on live Batocera.

## Problem

The erasure fix (mount guard) skips the merge move when the pool is still mounted. That prevents data loss but means the original move never runs. The move was intended to move "internal ROMs" to the base directory to prevent masking when adding a new drive. Masking can still occur: when .roms_base and an external drive (e.g. BATO-LG) both have the same path (e.g. megadrive), mergerFS shows one branch's content; the other is masked.

## Root Cause

The original move operated on the merged view (`$POOL_PATH`) after `umount -l`. For paths that exist only on external drives, the move deleted from those drives (erasure bug). A safe implementation must never operate on the merged view in a way that touches external-drive-only paths.

## Solution

Redesign the merge move logic to:

1. **Only operate on `.roms_base` paths** — Enumerate paths in `/userdata/.roms_base` before unmount. Never move from the merged view in a way that could delete from external drives.
2. **Avoid merged-view move** — The move from `$POOL_PATH` to `$BASE_DIR` is unsafe when the pool is mounted (lazy unmount) or when we can't distinguish branch ownership. Alternative: copy from `.roms_base` to a staging area before unmount, or iterate over `.roms_base` only and ensure no cross-branch operations.
3. **Preserve mount guard** — Keep the existing guard (skip move when pool still mounted) as the safety net. The safe-move logic would run only when the guard allows (pool fully unmounted) — but then `$POOL_PATH` may be empty. Design TBD.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Safe move logic (TBD) |

## Validation

- [ ] Add BATO-LG to pool; verify no erasure
- [ ] Verify masking behavior with overlapping paths (e.g. megadrive on both .roms_base and BATO-LG)
- [ ] Confirm mount guard still triggers when appropriate

## Related

- `2026-02-28_bsm-mergerfs-bato-all-erasure` — Erasure fix (mount guard); this entry builds on that.

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

