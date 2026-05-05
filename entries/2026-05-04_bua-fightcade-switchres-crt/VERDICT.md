# VERDICT — Fightcade Switchres CRT Integration

## Status: PR #156 OPEN Draft — full test matrix pass, ready for team review

## Summary

Switchres CRT wrapper for BUA Fightcade. Intercepts all `fcade://` URLs via `xdg-open` shim, resolves native ROM dimensions (MAME `-listxml` for arcade, hardcoded fallbacks for FBNeo console platforms), applies Switchres modelines, patches emulator configs, monitors emulator lifecycle, restores menu timing on exit. On HD displays the wrapper passes through to `fcade.sh` transparently.

## Test Matrix

### Part 1: Emulators
| Emulator | Game | Status |
|----------|------|--------|
| FBNeo (arcade) | SFIII 3rd Strike | PASS |
| snes9x | Super Street Fighter II | PASS |
| flycast | MvC2 / Power Stone | PASS |
| ggpofba (FC1) | N/A | SKIP (FC1 bypasses xdg-open) |

### Part 2: FBNeo Console Platforms
| Platform | Game | Resolution | Status |
|----------|------|-----------|--------|
| Mega Drive | Contra Hard Corps | 320x224 | PASS |
| NES | Contra | 256x240 | PASS |
| PC Engine | Adventure Island | 320x240 | PASS |
| TurboGrafx-16 | Bonk's Adventure | 320x240 | PASS |
| Master System | Alex Kidd | 320x192 | PASS |
| Game Gear | Sonic | 320x144 | PASS |
| ColecoVision | Zaxxon | 320x192 | PASS |
| SG-1000 | — | — | SKIP (same VDP as SMS) |
| MSX | — | — | SKIP (same VDP as SMS) |

### Fightcade Modes
| Mode | URL scheme | Status |
|------|-----------|--------|
| Test Game | `fcade://play/` | PASS |
| Online match | `fcade://served/` | PASS |
| Training | `fcade://training/` | PASS |
| Replay / spectating | `fcade://stream/` | PASS |

### Display Modes
| Mode | Resolution | Switchres | Status |
|------|-----------|-----------|--------|
| CRT 240p (NTSC) | 641x480i menu | Engages | PASS |
| CRT 576i (PAL) | 769x576 menu | Engages | PASS |
| HD 1080p | 1920x1080 | Bypassed | PASS |

## Plan vs Reality

PoC required two iterations: v1 failed because FBNeo's `-a` flag conflicts with Wine's display mode switching. v2 succeeded by pre-patching FBNeo config for borderless windowed fullscreen instead.

URL dispatch needed three iterations: initial `fcade://play/` only, then added `served` and `training`, then replaced whitelist with wildcard `fcade://[^/]+/` to future-proof.

PAL CRT gate threshold (720) was too restrictive for 769x576 menus; raised to 1024.

ES round-trip black screen resolved through accumulated process management fixes: stale wrapper killing, pgrep precision, wait deadline reduction, grace period for GGPO reconnects.

## Root Causes (resolved)

1. Fightcade bypasses Batocera's emulator launch pipeline (no configgen, no batocera-resolution)
2. FBNeo `-a` flag uses Wine ChangeDisplaySettings which fails for non-standard resolutions
3. FBNeo config stores HD display settings that need patching for CRT mode
4. Stale `SR-*` xrandr modes from prior launches caused duplicate add_mode / black screen
5. Multiple Fightcade URL schemes (`served`, `training`, `stream`) not documented, discovered through testing

## Changes Applied

| File | Change |
|------|--------|
| `fightcade/switchres_fightcade_wrap.template.sh` | New (491 lines): full CRT wrapper |
| `fightcade/fightcade.sh` | +16/-2: template install + xdg-open shim routing |
