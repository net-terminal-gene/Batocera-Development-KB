# VERDICT — Fightcade Switchres CRT Integration

## Status: TBD

## Summary

Proof of concept validated on 2026-05-04. Switchres can generate and apply native arcade modelines for Fightcade games on CRT, with Wine + FBNeo rendering correctly into the switched resolution via borderless windowed fullscreen. MAME database provides per-ROM resolution+refresh data in 29ms. Integration into the BUA fightcade.sh xdg-open shim is the next step.

## Plan vs reality

PoC required two iterations: v1 failed because FBNeo's `-a` flag conflicts with Wine's display mode switching. v2 succeeded by pre-patching FBNeo config for borderless windowed fullscreen instead.

## Root Causes

1. Fightcade bypasses Batocera's emulator launch pipeline entirely (no configgen, no batocera-resolution)
2. FBNeo's `-a` flag uses Wine ChangeDisplaySettings which fails for non-standard resolutions
3. FBNeo config stores HD display settings (3440x1440) that need patching for CRT mode

## Changes Applied

| File | Change |
|------|--------|
| test-switchres-fightcade.sh | PoC script: MAME lookup + switchres + FBNeo config patch + Wine launch |
