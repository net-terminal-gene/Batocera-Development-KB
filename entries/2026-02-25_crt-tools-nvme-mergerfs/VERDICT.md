# VERDICT — CRT Tools on Boot Drive (mergerFS Conflict)

## Status: FIXED

## Summary

The CRT Tools path conflict that arose from the mergerFS `=NC` fix has been resolved. CRT Tools are now properly isolated on the boot drive via bind mount overlay, ensuring they persist during mode switches even with the `=NC` write policy on external drives.

## Root Causes Fixed

1. Implemented bind mount of `/userdata/.roms_base/crt` to `/userdata/roms/crt` after mergerFS initialization
2. CRT Tools remain on boot drive (NVMe, SATA, microSD) and are accessible during HD/CRT mode switches
3. No conflict with `=NC` write policy for ROM files

## Changes Applied

| Repo | File | Change |
|------|------|--------|
| batocera.linux | Batocera boot sequence (custom.sh or init script) | Add bind mount for CRT Tools after mergerFS initialization |
