# VERDICT — batocera-storage-manager mergerFS =NC Fix

## Status: FIXED

## Summary

The mergerFS ROM duplication issue where the NVMe base directory would silently accumulate duplicate game files (when full or lacking free space compared to external drives) has been resolved. The `=NC` (No Create) policy is now applied to `BASE_DIR` in the mergerFS branch string, ensuring new ROM writes always go to external drives first.

## Root Causes Fixed

1. `batocera-storage-manager` was not applying `=NC` to the base directory in mergerFS branch strings (unlike the manual `S12mergerfs` init script which already had it)
2. Steam launcher conflict resolved: Steam launchers remain on NVMe for portability; ROM files correctly route to external drives

## Changes Applied

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Add `=NC` to BASE_DIR in mergerFS branch strings (3 locations) |
