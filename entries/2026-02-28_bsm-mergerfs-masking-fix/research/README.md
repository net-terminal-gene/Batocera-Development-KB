# Research — mergerFS Merge Move Safe Masking Fix

## Findings

- **Erasure fix:** Mount guard skips move when pool still mounted. Validated 2026-02-28.
- **Masking:** mergerFS shows one branch's content when multiple branches have the same path. Policy (existing, epmfs, lfs) determines which.
- **Move intent:** "Moving internal ROMs to base directory to prevent masking" — consolidate .roms_base content before adding new drive.
- **Constraint:** After full unmount, `$POOL_PATH` is empty; content is in branch dirs (.roms_base, BATO-ALL, etc.). The original move relied on lazy unmount leaving the merged view visible — that's when it was dangerous.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

