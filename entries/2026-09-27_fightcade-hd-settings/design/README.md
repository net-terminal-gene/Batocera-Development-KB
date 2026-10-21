# Design — Fightcade Flatpak HD Video Settings

## Responsibility split

```
hd/presets/*                 → complete, correct baseline config per emulator
                               (aspect, vsync, fullscreen-mode, menu, window pos)
hd/patch-hd-video.sh         → overlay ONLY panel-specific values on top:
                               detected resolution + fullscreen-enable + vsync
                               (+ snes9x Lock=FALSE repair)
crt/fightcade-crt-switchres  → runtime, CRT-only: rewrites the SAME conf live for
                               native low-res gameplay and menu pause, then restores
                               from its own .bak.switchres / .bak.menu copies
```

Key principle: the preset is the source of truth; the patcher is a thin, panel-aware overlay; the CRT wrapper is a temporary runtime mutator that always restores. None of them should depend on `[Config] Lock` — snes9x must remain free to persist user input changes.

## Flow (HD / Steam Deck, non-switchres)

1. `install.sh` (HD path) runs `hd/patch-hd-video.sh`.
2. `detect_display_resolution` reads the panel (e.g. Deck = 1280x800; falls back to 1920x1080).
3. `install_hd_presets` copies any missing preset into `data/config/<emu>/`.
4. Each `patch_*` overlays resolution + fullscreen + vsync (snes9x also forces `Lock=FALSE`).
5. At game launch, snes9x reads the (symlinked) conf; on exit it now writes back any in-emulator changes because the config is unlocked.

## Why not presets-only

Presets hardcode 1920x1080. The Steam Deck panel is 1280x800, so a per-panel resolution overlay is required. Dropping the patcher entirely would break non-1080p displays.
