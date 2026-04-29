# VERDICT — mergerFS Merge Move Safe Masking Fix

## Status: FIXED

## Summary

The mergerFS masking issue where overlapping paths between `.roms_base` and external drives would cause silent masking has been resolved via batocera.linux merge. The safe merge move logic that operates only on `.roms_base` paths (never on the merged view) is now deployed.

## Root Causes Fixed

1. Redesigned merge move logic to enumerate paths in `/userdata/.roms_base` before unmount, preventing accidental deletion from external drives
2. Preserved mount guard (skip move when pool still mounted) as safety net
3. Safe implementation never operates on merged view in a way that could touch external-drive-only paths

## Changes Applied

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Safe merge move logic deployed |
