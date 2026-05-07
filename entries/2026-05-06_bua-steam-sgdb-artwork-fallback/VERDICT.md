# VERDICT — BUA Steam: SteamGridDB Artwork Fallback

## Status: TBD

## Summary

[One paragraph when development concludes]

## Plan vs reality

[How far shipped code deviated from original plan]

## Root Causes

1. `sgdb_get_image()` hardcodes `dimensions=460x215` with no fallback

## Changes Applied

| File | Change |
|------|--------|
