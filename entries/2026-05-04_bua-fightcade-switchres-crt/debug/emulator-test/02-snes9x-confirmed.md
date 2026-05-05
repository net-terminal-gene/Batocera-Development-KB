# 02 — snes9x: confirmed working (with fixes)

**Status:** PASS (first launch fullscreen, crisp image on CRT)

---

## Issues found and fixed

### 1. Wrong config path and format

The wrapper's `ini_path_for_emu` returned `snes9x/config/fcadesnes9x.ini` (FBNeo-style INI path). That file does not exist. snes9x uses `snes9x/fcadesnes9x.conf` with a completely different config format (INI sections like `[Display\Win]`, keys like `Fullscreen:Enabled`).

**Fix:** Added `snes9x_conf_path()` function returning the correct `.conf` path. Added `patch_snes9x_conf()` and `restore_snes9x_conf()` functions that patch snes9x-native config keys instead of FBNeo keys.

### 2. Windowed mode (not fullscreen)

snes9x defaulted to `Fullscreen:Enabled = FALSE`. The emulator launched as a tiny 512x448 window in the corner of a 256x224 display.

**Fix:** `patch_snes9x_conf` sets `Fullscreen:Enabled = TRUE`, `Fullscreen:EmulateFullscreen = TRUE`, `HideMenu = TRUE`.

### 3. Narrow CRT image (256x224 modeline)

The SNES native resolution is 256x224 but the original console output non-square pixels stretched to 4:3 by the TV. A 256-pixel-wide Switchres modeline produces a physically narrow image on the CRT tube.

**Fix:** Changed SNES fallback in `resolve_rom_dims` from `W=256` to `W=320`. The 320x224 Switchres modeline fills the CRT face properly. snes9x stretches 256-pixel content to fill the 320-wide display with `Stretch:MaintainAspectRatio = FALSE`.

### 4. Blurry image (bilinear filtering + Direct3D through Wine)

Compared side-by-side with RetroArch running the same ROM (sf2tua.zip) at SR-1_256x224@60.10, Fightcade snes9x was noticeably soft.

**Fix:** `patch_snes9x_conf` sets `Stretch:BilinearFilter = FALSE` (nearest-neighbor) and `OutputMethod = 0` (DirectDraw instead of Direct3D). Result: crisp image comparable to native RetroArch.

---

## Mandatory bundle

### xrandr during snes9x TEST GAME

```text
Screen 0: minimum 320 x 200, current 320 x 224, maximum 16384 x 16384
DP-1 connected primary 320x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_320x224@60.10  60.10*
```

### Modeline detail

```text
SR-1_320x224@60.10  6.543MHz -HSync -VSync
    h: width   320 start  346 end  377 total  422 skew    0 clock  15.51KHz
    v: height  224 start  233 end  236 total  258           clock  60.10Hz
```

### Processes

```text
3324 /bin/bash .../bin/xdg-open fcade://play/snes9x/snes_sf2tua
3326 /bin/bash .../extra/switchres_fightcade_wrap.sh fcade://play/snes9x/snes_sf2tua
3760 .../Resources/wine.sh .../snes9x/fcadesnes9x.exe sf2tua
3763 .../usr/bin/wine .../snes9x/fcadesnes9x.exe sf2tua
3790 .../snes9x/fcadesnes9x.exe sf2tua
```

### Config patched (confirmed via grep)

```text
Fullscreen:Enabled              = TRUE
Fullscreen:Width                = 320
Fullscreen:Height               = 224
Fullscreen:EmulateFullscreen    = TRUE
HideMenu                        = TRUE
Stretch:MaintainAspectRatio     = FALSE
Stretch:BilinearFilter          = FALSE
OutputMethod                    = 0
```

### Games tested

| Game | ROM | Switchres | Refresh | Result |
|------|-----|-----------|---------|--------|
| Street Fighter II Turbo (SNES) | `snes_sf2tua` | 320x224 | 60.10 Hz | PASS |

### Scenarios tested

| Scenario | Result |
|----------|--------|
| First TEST GAME | PASS (fullscreen, crisp) |
| FBNeo regression check after snes9x changes | PASS (SF3 at 384x224@59.60, unaffected) |

---

## Notes

- snes9x uses `.conf` format, not FBNeo `.ini` format. Completely separate patch/restore functions required.
- No MAME XML lookup for SNES ROMs; falls back to hardcoded 320x224@60.10.
- Top/bottom black bars are normal for 224-line content on this CRT (same as RetroArch).
- RetroArch comparison used SR-1_256x224@60.10 (native 1:1 pixels). Fightcade uses 320x224 with stretch because snes9x via Wine cannot render at exactly 256 pixels without the image appearing narrow on the CRT.
- Backup/restore of `fcadesnes9x.conf` works via `.bak.switchres` copy, same pattern as FBNeo INI.
