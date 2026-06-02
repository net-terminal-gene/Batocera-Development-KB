# VERDICT — Mode Switcher RetroArch Remaps Loss

## Status: TBD

## Summary

Pending implementation and hardware validation. Root cause identified in code review: `backup_mode_files()` nests RetroArch (and MAME) snapshots on second+ backup via `cp -ra` into existing destination, placing remaps under `retroarch/retroarch/` where RetroArch does not load them after restore.

## Plan vs reality

TBD

## Root Causes

1. **cp into existing backup dir** — no `rm -rf` before emulator config backup in `03_backup_restore.sh`
2. **[Design]** Full RetroArch tree swap treats remaps as mode-specific when they are user preferences

## Changes Applied

| File | Change |
|------|--------|
| — | None yet |
