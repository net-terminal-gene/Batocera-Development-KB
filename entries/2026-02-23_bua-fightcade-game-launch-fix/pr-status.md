# PR Status — BUA Fightcade Game Launch Fix

## PR

| Field | Value |
|-------|-------|
| Repo | batocera-unofficial-addons/batocera-unofficial-addons |
| PR | [#143](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/143) |
| Branch | `fix-fightcade` |
| Title | fix(fightcade): enable game launch on Batocera |
| Status | **MERGED** |
| Created | 2026-02-23 |
| Merged | 2026-02-25 |

## Review / Comments

Merged to upstream batocera-unofficial-addons.

## Changes Included

| File | Change |
|------|--------|
| `fightcade/fightcade.sh` | Added `Resources/wine.sh` generation, `xdg-open` shim in port launcher, wineboot timing fix, quoted-to-unquoted EOF with proper escaping |
| `fightcade/fightcade_uninstall.sh` | Added wine symlink cleanup on uninstall |

## Testing

- Tested on batocera/x86_64 v43 butterfly (Steam Deck)
- Clean install via `scp` + `bash /tmp/fightcade.sh`
- Verified: login, join room, Test Game → FBNeo launched KOF '98 and SF3 3rd Strike via Wine
- Two test iterations: v1 (fcade-quark + .desktop approach — failed), v2 (xdg-open shim — succeeded)
- Final variable-based version re-tested and confirmed working
