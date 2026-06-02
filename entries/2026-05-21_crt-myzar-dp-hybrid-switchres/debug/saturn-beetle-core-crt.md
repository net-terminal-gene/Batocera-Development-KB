# Saturn — Beetle core CRT defaults

**Status:** PASS (Batsugun validated 2026-05-22; **core-wide** deploy per user)  
**Core:** Beetle Saturn (`beetle-saturn`) · **Do not** reuse FBNeo Sai `xrandr right` path on Saturn

## Symptom → fix

| Symptom | Cause | Fix |
|---------|--------|-----|
| Correct rotation, **black bars left/right** | `Beetle Saturn.cfg` had **640×480** viewport; `aspect_ratio_index` **22** (core) overrode `ratio=full` | Core: **aspect 24**, viewport **0**, `force_aspect` false |
| Wrong super-res (pillarbox on wide line) | SR picker used **widest** 240-line mode (**2048×240** vs **1280×240**) | `batocera-resolution-myzar.sh`: pick **WIDTH×4** |
| Picture **flipped** (brief regression) | Applied Sai path: **`xrandr right`** on all `320×240` | **Reverted** — Saturn stays **`xrandr normal`**; rotation OK without it |
| `global.retroarch.video_force_aspect=true` | Configgen wrote pillarbox into `retroarchcustom.cfg` every launch | `global` + `saturn.retroarch.video_force_aspect=false` |

## Final stack (core-wide)

### `batocera.conf`

```ini
saturn.ratio=full
saturn.videomode=320x240.60.00
saturn.retroarch.video_force_aspect=false
```

Per-ROM timing override (VGA / 640×480 titles):

```ini
saturn["SomeGame.chd"].videomode=640x480.60.00
```

### `Beetle Saturn.cfg`

Path: `/userdata/system/configs/retroarch/config/Beetle Saturn/Beetle Saturn.cfg`  
Mac source: `~/.cursor/skills/myzar-dp/config/saturn/Beetle Saturn.cfg`

```ini
aspect_ratio_index = "24"
custom_viewport_width = "0"
custom_viewport_height = "0"
video_force_aspect = "false"
video_scale_integer = "false"
```

Batocera sets `video_fullscreen_x/y` from active resolution each launch.

### Switchres / X

- Mode lookup: `320x240.60.00` (e.g. Batsugun; MAME `-listxml` when used from `batocera-get-game-mode.sh`)
- Super-res: **1280×240** (`xrandr` **normal** — not Sai `right`)
- `batocera-resolution` SR line: minimum width **≥ WIDTH×4** at matching line count

## Per-game `.cfg` (optional)

Existing cabinet cfgs (Guardian Force, Layer Section II, …) may set **`video_rotation = 3`** only. They **override rotation**, not core stretch.

**Do not** add per-game stretch unless a title fights core defaults.

## Removed (Batsugun-only experiment)

| File | Why removed |
|------|-------------|
| `Beetle Saturn/Batsugun.cfg` | Superseded by core cfg |
| `zzz-saturn-ra-fix.sh` | Patched `retroarchcustom` after configgen; no longer needed |
| `global.retroarch["Batsugun"].*` viewport keys | Redundant |

## Verify

```bash
grep -E "^saturn\.|Beetle Saturn" /userdata/system/batocera.conf
head -8 "/userdata/system/configs/retroarch/config/Beetle Saturn/Beetle Saturn.cfg"
export DISPLAY=:0
xrandr --query | grep -E "current|1280x240|2048x240"
tail -5 /userdata/system/logs/display.log   # gameStart saturn -> 320x240.60.00
```

Launch any Saturn title; expect fill width at correct rotation. **640×480** games need explicit `videomode` override.

## Related

- [04-mame-fbneo-rotation-coexistence-pass.md](04-mame-fbneo-rotation-coexistence-pass.md) — Sai uses **fbneo-only** `myzar-cabinet-rotate`; MAME must stay **normal**
- [ddpsdoj-saidaioujou-known-good.md](ddpsdoj-saidaioujou-known-good.md) — FBNeo Sai (different path)
