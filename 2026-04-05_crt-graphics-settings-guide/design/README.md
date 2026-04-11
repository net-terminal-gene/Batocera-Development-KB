# Design — CRT Graphics Settings Guide

## Architecture

This is a reference document, not a code change. The guide follows a layered structure:

```
CRT Physics Rationale (why settings behave differently on CRT)
  └─ Universal Base Settings (apply to any game)
       └─ Per-Game Overrides (Cyberpunk 2077 complete)
            └─ Per-Genre Quick Reference (open world, competitive, cinematic)
                 └─ Per-Engine Defaults (Source, Unity, Unreal)
```

Each setting recommendation traces back to a specific CRT property (phosphor bloom, beam profile, bandwidth limiting, etc.) rather than subjective preference.

## Hardware-Specific Branches

The guide accounts for two CRT displays with different characteristics:

| Display | Mask | Input | HD Gaming Suitability |
|---------|------|-------|----------------------|
| Philips 20PT6341/37 | Slot mask | Component (YPbPr) | Primary — sharpest available input |
| Sony KV-9PT40 | Aperture grille | Composite only | Secondary — better for CRT Mode retro |

## Resolution Pipeline

```
Game Render (720p/1080p) → FSR Upscale (optional) → GPU Output (1080p) → Converter → CRT (480i @ 15kHz)
```

The CRT is always the bottleneck. Settings that refine detail beyond 480i resolving power are wasted GPU cycles.
