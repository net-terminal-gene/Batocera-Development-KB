# Research — BUA Fightcade libcups Fix

## Findings

- **libcups.so.2** — CUPS (Common Unix Printing System) library. Electron apps link against it for printing support. Batocera does not ship it.
- **BUA .dep** — `/userdata/system/add-ons/.dep/` holds shared libraries (libcups.so.2, xmlstarlet, etc.) downloaded by the BUA installer or other add-ons (e.g. Chrome).
- **Other add-ons** — Greenlight and Amazon Luna set `LD_LIBRARY_PATH="/userdata/system/add-ons/.dep:${LD_LIBRARY_PATH}"` in their launchers. Fightcade did not.
- **Failure mode** — Without LD_LIBRARY_PATH, the dynamic linker searches system paths only; libcups is not found; fc2-electron exits immediately with the shared-library error.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

