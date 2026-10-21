# VERDICT — Fightcade Vertical Library Genre Filter

## Status: MERGED

PR [#4](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/4) merged 2026-10-09 (`fa05fd5`). Join path changed 2026-10-01 and was checked on batocera.local before merge.

## Progress 2026-10-01

Commit `719990f` on `vertical-build`. Vertical list is the local 593-id allowlist (no all-games dump). Join looks up one game, then uses the server channel name. Three joins returned `200` in about 0.4s (`1945kiii`, `1943kai`, `zzyzzyxx`). Genre menu insert is alphabetical (before W); on-screen confirm still needs a relaunch. Detail: `debug/2026-10-01-join-rate-limit.md`.

## Summary

(To fill on close.)

## Plan vs reality

(To fill on close.)

## Root Causes

1. Prior attempts answered from an empty channel cache before the All Games response arrived.
2. WS hook install-order problem: login socket created before hook, so login `all:true` payload
   never reached the cache.

## Changes Applied

| File | Change |
|------|--------|
| `lobby/vertical-allowlist.js` | New: 732-id window-global allowlist |
| `lobby/vertical-search.js` | New: page-world genre+WS filter module |
| `lobby/inject.js` | `setupVerticalSearch()` + call in `applyFit` |
| `install.sh` | Added vertical files to FILES list |
| `scripts/gen-vertical-allowlist.py` | Generator from KB markdown |
