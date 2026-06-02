# VERDICT — mergerFS Write Routing and S12populateshare Awareness

## Status: TBD

## Summary

Design session for proposing upstream changes to Batocera's storage manager and boot initialization to give users control over write routing in multi-drive mergerFS setups and prevent stock content from shadowing external drive content.

## Plan vs reality

[To be written when development concludes]

## Root Causes

1. `S12populateshare` has no awareness of mergerFS configuration or external drive branches
2. `batocera-storage-manager` hardcodes a single global `category.create=eplfs` policy with no per-system overrides
3. Silent `mv` failures during `.roms_base` migration leave stock content in place, causing gamelist shadowing

## Changes Applied

| File | Change |
|------|--------|
| (none yet) | |
