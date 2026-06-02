# MAME + FBNeo rotation coexistence — PASS (user confirmed)

**Date:** 2026-05-22  
**Status:** PASS — user confirmed both paths working after final flag fix.

## Requirement

- **MAME** (`mame.switchres=1`, `-changeres`): `xrandr **normal**` during play for all titles, including `320×240` (e.g. `dfkbl`, `ddpdoj`).
- **FBNeo Sai only** (`fbneo/ddpsdoj.zip`): `xrandr **right**` when `display.rotate=1` + RA viewport **320×1280** + `ratio=full` + `fbneo-vertical-mode` disabled.

## Regressions fixed (2026-05-22)

| Bug | Symptom | Fix |
|-----|---------|-----|
| `is_tate_arcade_mode` on all `320×240` | MAME upside down (e.g. `dfkbl`) | Cabinet rotate **only** when `zzz-myzar-switchres.sh` sets flag for `fbneo` + `ddpsdoj.zip` |
| `setMode` did `rm -f myzar-cabinet-rotate` | FBNeo Sai lost `xrandr right` after MAME fix | **Remove** rm in `setMode`; only `gameStop` clears flag |
| Background `setMode` race | Sai sometimes launched before rotate applied | **Sync** `setMode` when `/var/run/myzar-cabinet-rotate` exists |

## Final logic (do not broaden)

```text
gameStart:
  rm cabinet-rotate
  if system=fbneo AND rom=ddpsdoj.zip AND display.rotate=1 → write right to cabinet-rotate
  if cabinet-rotate exists → setMode sync
  else → setMode background

setMode (arcade):
  NEVER rm cabinet-rotate
  XROT = cat cabinet-rotate || normal

gameStop:
  rm cabinet-rotate + sr-mode + arcade-mode
```

## Validated (user)

| Emulator | Title | ROM | X during play |
|----------|-------|-----|----------------|
| MAME | Dai-Ou-Jou / Cave horiz | `ddpdoj.zip` | normal, ~1536×224 class |
| MAME | Deathsmiles | `dfkbl.zip` | normal, 1280×240 timing |
| FBNeo | SaiDaiOuJou | `ddpsdoj.zip` | right + RA 320×1280 fill |

## Do not

- Apply `xrandr right` from `320×240` mode string alone.
- Re-enable FBNeo TATE for Sai while using xrandr right.
- Delete `myzar-cabinet-rotate` inside `setMode`.
