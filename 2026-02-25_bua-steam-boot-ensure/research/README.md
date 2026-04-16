# Research — BUA Steam Boot-Time Ensure

## Findings

- BUA Steam uses sh emulator for .sh launchers; configgen supports per-game videomode.
- batocera.conf steam.* keys: `steam.emulator=sh`, `steam.core=sh`, `steam["rom.sh"].videomode=...`
- System updates (e.g. v42 → v43) and other batocera.conf overwrites can drop steam.* entries.
- custom.sh runs at boot; BUA Steam already registers restore_desktop_entry.sh there — same pattern for ensure script.
- ensure script runs at boot; next boot after config loss re-adds steam.* when missing.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

