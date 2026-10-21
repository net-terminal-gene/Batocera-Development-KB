# VERDICT — Fightcade Flatpak HD Video Settings

## Status: TBD

## Summary

_To be written when the session closes (after the hardware end-to-end remap-persistence test and a fresh reinstall on Deck + PC)._

## Root Causes (so far)

1. `hd/patch-hd-video.sh` forced snes9x `[Config] Lock = TRUE`, making the config read-only while running, so controller remaps were never saved and reverted on next launch.

## Changes Applied (so far)

| File | Change |
|------|--------|
| `hd/patch-hd-video.sh` | Set snes9x `Lock=FALSE` (was TRUE); trimmed fbneo/snes9x patch functions to panel-specific values only (resolution + fullscreen + vsync) since presets ship the rest |
| `hd/presets/fcadesnes9x.conf` | `[Config] Lock` TRUE → FALSE with explanatory comment |
