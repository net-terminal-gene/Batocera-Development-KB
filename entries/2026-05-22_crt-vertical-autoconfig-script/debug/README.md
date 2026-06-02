# Debug - CRT vertical autoconfig script

## Verification

```bash
# Before / after diff (on Batocera)
cp -a /userdata/system/batocera.conf /tmp/batocera.conf.before
# run script --dry-run or apply
diff -u /tmp/batocera.conf.before /userdata/system/batocera.conf || true

grep -E '^pcengine|^pcenginecd|^fbneo|^neogeo|^vectrex|^snes' /userdata/system/batocera.conf
ls -la '/userdata/system/configs/retroarch/config/FinalBurn Neo/' | head
ls -la '/userdata/system/configs/retroarch/config/Beetle PCE Fast/' | head
ls -la '/userdata/system/configs/retroarch/config/vectrex/' 2>/dev/null | head
```

## Failure Signs

| Symptom | Likely Cause |
|---------|----------------|
| Black screen after script | `videomode` string not in `listModes` for this GPU |
| FBNeo correct, PCE wrong | Wrong core subdir name or stale per-ROM override |
| Vectrex rolling / unstable | Global CRT SwitchRes still on; need **`vectrex.retroarch.crt_switch_resolution = 0`** |
| Vectrex landscape on TATE | Missing **`vectrex.retroarch.video_rotation`** (usually **3** for `display.rotate=1`) |
| Rotation double-applied | `video_allow_rotate` conflicts with `display.rotate`; revisit `fbneo.*` merge rules |
| SNES huge bar / wrong half of picture | **`256x448` + `ratio=full`** failed on this cab; use **`256x256`** (or **`256x240`**) per [SNES vertical portable](../../2026-05-20_crt-vanilla-vertical-portable/research/snes-vertical-vanilla-v43.md) |
| SNES bottom clipped with `ratio=full` | **`snes9x_gfx_clip`** on or **`crop_overscan`** on; taller **`videomode`** may still be needed |
