# VERDICT — Mode Switcher RetroArch Remaps Loss

## Status: MERGED

PR [#438](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/438) merged 2026-06-02 (`e7119d1`). Reporter confirmed the fix on hardware before merge.

## Summary

Root cause: `backup_mode_files()` nests RetroArch (and MAME) snapshots on second+ backup via `cp -ra` into existing destination, placing remaps under `retroarch/retroarch/` where RetroArch does not load them after restore.

## Plan vs reality

TBD

## Root Causes

1. **cp into existing backup dir** — no `rm -rf` before emulator config backup in `03_backup_restore.sh`
2. **[Design]** Full RetroArch tree swap treats remaps as mode-specific when they are user preferences

## Changes Applied

| File | Change |
|------|--------|
| — | None yet |
