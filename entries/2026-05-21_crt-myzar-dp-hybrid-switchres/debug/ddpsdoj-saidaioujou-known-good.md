# DoDonPachi SaiDaiOuJou (ddpsdoj) — known-good on Myzar hybrid

**Status:** PASS (user confirmed 2026-05-21)  
**ROM:** `fbneo/ddpsdoj.zip` (CV1000; not PGM `ddpdoj`)  
**Cabinet:** landscape CRT, `display.rotate=1`, `global.videooutput=DisplayPort-0`

## Do not confuse with PGM

| ROM | Game | Switchres input | Notes |
|-----|------|-----------------|-------|
| `ddpsdoj.zip` | **SaiDaiOuJou** (CV1000) | `320x240.60.00` | **1280×240** super-res; special FBNeo + xrandr path below |
| `ddpdoj.zip` | Dai-Ou-Jou (PGM) | `384x224.59.19` | **1536×224**; MAME `keepaspect=0` / `unevenstretchx=1` |

MAME 0.274 on device has **no** `ddpsdoj` driver — use **FBNeo** core in ES.

## Switchres / X11 (myzar wrapper)

| Layer | Value |
|-------|--------|
| `batocera-get-game-mode.sh` | ROM `ddpsdoj` → `320x240.60.00` (hardcoded; no MAME XML) |
| Switchres modeline | `1280x240_60` |
| `batocera-resolution currentResolution` | **`1280×240`** (mode name; correct) |
| During play | **`xrandr --rotate right`** when `display.rotate=1` — **only** `zzz-myzar-switchres.sh` sets `/var/run/myzar-cabinet-rotate` for **`fbneo` + `ddpsdoj.zip`**; `setMode` must **not** delete that flag; Sai uses **sync** `setMode` (not background) |
| RA effective surface | **~320×1280** (rotated; fill viewport to this, not 1280×240) |

**Wrong combos (failed):**

- `xrandr normal` + FBNeo **TATE** → wrong rotation, squished center
- `xrandr right` + viewport **1280×240** → correct rotation, left/right black bars
- `xrandr normal` + viewport **1280×240** → wrong rotation + pillarbox
- **`xrandr right` on MAME** (e.g. `dfkbl` also `320×240`) → upside down — MAME uses `-changeres`; never rotate X for MAME
- **`setMode` deletes `myzar-cabinet-rotate`** → FBNeo loses right rotate — fixed 2026-05-22; see `04-mame-fbneo-rotation-coexistence-pass.md`

## batocera.conf

```ini
fbneo["ddpsdoj.zip"].videomode=320x240.60.00
mame["ddpsdoj.zip"].videomode=320x240.60.00
fbneo["ddpsdoj.zip"].ratio=full
global.retroarch["DoDonPachi SaiDaiOuJou"].video_force_aspect=false
global.retroarch["DoDonPachi SaiDaiOuJou"].custom_viewport_width=320
global.retroarch["DoDonPachi SaiDaiOuJou"].custom_viewport_height=1280
```

## RetroArch — `config/FinalBurn Neo/`

**DoDonPachi SaiDaiOuJou.cfg** (Mac source: `~/.cursor/skills/myzar-dp/config/`):

```ini
aspect_ratio_index = "22"
custom_viewport_width = "320"
custom_viewport_height = "1280"
video_force_aspect = "false"
video_rotation = "0"
video_scale_integer = "false"
```

**DoDonPachi SaiDaiOuJou.opt:**

```ini
fbneo-vertical-mode = "disabled"
```

Keep **`fbneo.video_allow_rotate=true`** globally. Do **not** set RA `video_rotation` for this title (fights xrandr + breaks aspect).

Parent **`FinalBurn Neo.cfg`** has `custom_viewport_width=480` / `height=320` — per-game must override explicitly (not `0`).

## Verify

```bash
grep ddpsdoj /userdata/system/batocera.conf
cat "/userdata/system/configs/retroarch/config/FinalBurn Neo/DoDonPachi SaiDaiOuJou.cfg"
export DISPLAY=:0
xrandr --query | grep -E "current|1280x240|right"
tail -5 /userdata/system/logs/display.log   # expect gameStart -> 320x240.60.00
```

After launch: upright vertical shmup, full width, no left/right bars.
