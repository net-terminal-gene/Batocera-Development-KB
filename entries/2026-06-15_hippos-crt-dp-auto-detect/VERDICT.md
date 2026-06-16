# VERDICT — HippOS CRT DP auto-detect

## Status: IN PROGRESS

Implementer: Mikey (`net-terminal-gene` forks). Phase 1 validated; Phases 2–3 coded, hardware acceptance pending.

## Summary

[To be written when development concludes]

## Plan vs reality

[How far shipped code deviated from original plan]

## Root Causes

[Numbered list — populate on close from research/]

## Changes Applied

| File | Change |
|------|--------|
| hippos-xorg-setup | Pre-X `hippos-crt-setup` when CRT enabled |
| hippos-xserver.service | Skip `xrandr --auto` when CRT active |
| hippos-display-setup | Remove auto-detect; manual `crt.enabled=true` only |
| hippos-crt-setup | DCN detection fallback for Navi/RDNA |
| hippos-defaults.conf | `crt.enabled=false` |
| hippos-resolution | `listCrtBootModes` |
| GuiMenu.cpp | CRT output + boot resolution pickers |
| docs/dev-sync-crt.sh | Rsync deploy helper |

Hardware validated Phase 2 on hippos.local (2026-06-16). switchres segfault and ES-only UX test remain open.
