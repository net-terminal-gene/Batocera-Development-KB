# VERDICT — BUA Fightcade libcups Fix

## Status: FIXED

## Summary

fc2-electron (Fightcade 2 UI) requires libcups.so.2, which Batocera does not provide. BUA stores it in `/userdata/system/add-ons/.dep/`, but the Fightcade launcher did not set LD_LIBRARY_PATH. Added the export to the port launcher template in fightcade.sh so fc2-electron finds libcups regardless of launch context.

## Plan vs Reality

No deviation. Single-line change in the port launcher template.

## Root Causes

1. fc2-electron links against libcups (Electron printing support)
2. Batocera base system lacks libcups
3. Fightcade launcher did not set LD_LIBRARY_PATH to include .dep

## Changes Applied

| File | Change |
|------|--------|
| fightcade/fightcade.sh | Add `export LD_LIBRARY_PATH="$ADDONS_DIR/.dep:${LD_LIBRARY_PATH}"` after DISPLAY in port launcher template |
