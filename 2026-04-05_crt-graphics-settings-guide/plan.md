# CRT Graphics Settings Guide for Modern PC Games

## Agent/Model Scope

Composer (research + web search for CRT physics, game settings databases, BC-250 specs)

## Problem

Modern PC games have dozens of graphics settings designed for HD/4K LCD/OLED displays. When outputting to a 15 kHz CRT television at 480i via HDMI-to-component, many of these settings produce no visible improvement while consuming significant GPU resources. No consolidated reference existed for which settings matter on CRT and which are wasted.

## Root Cause

CRT phosphor physics (bloom, persistence, beam profile, analog bandwidth limiting, interlace field blending) naturally replicate what many post-processing effects simulate digitally. At 480i (~240 visible lines per field), per-pixel refinement beyond ~77,000 effective pixels is unresolvable.

## Solution

Created a universal CRT graphics settings guide covering:
- CRT physics vs post-processing equivalence table
- Universal base settings for any modern game on CRT
- Complete per-setting Cyberpunk 2077 configuration
- Per-genre quick reference (open world, competitive, cinematic)
- Per-engine common settings (Source, Unity, Unreal)
- Hardware-specific notes for Philips 20PT6341/37 and Sony KV-9PT40

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-Development-KB | `2026-04-05_crt-graphics-settings-guide/research/CRT-Graphics-Settings-Guide.md` | Main guide document |
| Batocera-Development-KB | `2026-04-05_crt-graphics-settings-guide/research/README.md` | Sources and methodology |

## Validation

- [x] Covers all Cyberpunk 2077 graphics settings (Update 2.1+)
- [x] Each recommendation has CRT-physics rationale
- [x] Hardware context matches actual setup (BC-250, Philips 20PT6341, Sony KV-9PT40)
- [x] HD Mode behavior matches CRT-Script codebase (verified from 02_hd_output_selection.sh, 03_backup_restore.sh)
- [ ] Settings tested on actual Batocera system with CRT output
