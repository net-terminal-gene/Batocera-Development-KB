# PR Status — BUA Steam Per-Game VIDEO MODE Fix

## PR #142

| Field | Value |
|-------|-------|
| Repo | batocera-unofficial-addons/batocera-unofficial-addons |
| PR | [#142](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/142) |
| Branch | `fix-steam-videomode` → `main` |
| Title | Fix Steam VIDEO MODE: use steam system + sh emulator for per-game videomode |
| Status | **MERGED** |
| Merged | 2026-02-23 |

**Changes:** es_systems_steam.cfg (-system steam, sh emulator), es_features_steam.cfg (remove duplicate videomode), steam.sh (add steam.emulator=sh, steam.core=sh on install)

## PR #144

| Field | Value |
|-------|-------|
| Repo | batocera-unofficial-addons/batocera-unofficial-addons |
| PR | [#144](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/144) |
| Branch | `fix-steam2-videomode` → `main` |
| Title | steam2.sh: add steam.emulator=sh, steam.core=sh on install |
| Status | **MERGED** |
| Merged | 2026-02-25 |

**Changes:** steam2.sh — add steam.emulator=sh, steam.core=sh to batocera.conf on install (same logic as steam.sh). Addresses steam2.sh (BUA UI installer path) gap from PR #142.

## Review / Comments

No review comments or change requests were posted for either PR. Both merged without modifications.

## Post-Merge Notes

- PR #142 + #144 cover steam.sh and steam2.sh install paths. Boot-time ensure script (mode-switcher compatibility) is in separate entry `2026-02-25_bua-steam-boot-ensure` (PR #145).
