# VERDICT — Non-Steam Games via Auto-Scraper

## Status: TBD

## Summary

[To be written when development concludes]

## Plan vs reality

[To be written when development concludes]

## Root Causes

1. Production `create-steam-launchers2.sh` only scans `appmanifest_*.acf` — non-Steam games in `shortcuts.vdf` are invisible
2. Steam CLI does not reliably launch non-Steam shortcut IDs — Proton direct launch is the only working method
3. A standalone app was built (`2026-03-07`) but may be unnecessary if the auto-scraper extension is sufficient

## Changes Applied

| File | Change |
|------|--------|
| (pending) | `create-steam-launchers2.sh` — add shortcuts.vdf scan + Proton direct launchers |
