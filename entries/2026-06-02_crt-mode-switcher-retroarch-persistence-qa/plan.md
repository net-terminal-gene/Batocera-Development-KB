# Mode Switcher RetroArch Persistence QA

## Agent/Model Scope

Composer + ssh-batocera. Follow-up to `2026-06-01_crt-mode-switcher-retroarch-remaps` / PR #438.

## Problem

PR #438 fixes remaps lost due to nested `retroarch/retroarch/` backups. Two open questions remain:

1. **Regression matrix:** Besides controller remaps (`.rmp`), which other RetroArch userdata files should round-trip across CRT→HD→CRT under the current “swap whole `configs/retroarch` tree” design?
2. **Future design:** Should `config/remaps/` (and possibly other user-pref paths) be **excluded** from per-mode swap so the same bindings exist in CRT and HD?

## Root Cause

TBD for any failures found during QA. Known context:

- Mode switcher backs up/restores `${MODE_BACKUP_DIR}/{crt,hd}_mode/emulator_configs/retroarch` in full.
- Batocera sets `config_save_on_exit = false` in `retroarchcustom.cfg` (configgen), so many in-menu global saves do not persist; **file-based** changes under `configs/retroarch/` are what the swap actually moves.
- Per-game launch regenerates `retroarchcustom.cfg` from configgen; durable tests should target paths configgen also uses: `config/`, `config/remaps/`, `cores/retroarch-core-options.cfg`, per-system `.cfg`, overlays.

## Solution

### Phase A — QA matrix (current behavior, post-#438)

Run the checklist in `debug/README.md` on hardware with #438 `03_backup_restore.sh` deployed. Record pass/fail per artifact.

### Phase B — Shared remaps (optional follow-up PR)

If product goal is **one remap set for both modes**:

- Do not delete/restore `config/remaps/` during mode switch.
- Continue swapping CRT-specific subtrees (`overlays/`, CRT overlay `config/*`, etc.).

Defer implementation until Phase A defines what must stay mode-specific.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| TBD | `03_backup_restore.sh` | Phase B only: selective backup/restore |
| — | This KB session | QA procedure only |

## Validation

See `debug/README.md` — all Phase A steps.
