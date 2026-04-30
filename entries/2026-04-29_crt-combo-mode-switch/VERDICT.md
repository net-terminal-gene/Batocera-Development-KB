# VERDICT — CRT Combo Mode Switch

## Status: TBD

## Summary

Design and research complete. Implementation not yet started.

**Primary approach:** Triggerhappy (`multimedia_keys.conf`) + shell combo handler. Follows existing CRT Script patterns. No Python, no new daemons.

**Backup approach:** Python `evdev` combo listener daemon. Kept in reserve for controllers where L2/R2 are analog-only axes (triggerhappy can't detect `EV_ABS`).

## Decision rationale

- CRT Script is pure shell; adding Python breaks convention
- `multimedia_keys.conf` is an established CRT Script pattern (RIGHTALT+F1/F2/F3 already ship this way)
- Triggerhappy is already running; no boot-custom.sh changes needed
- Python backup retained because it handles analog triggers and per-device hold timing

## Plan vs reality

N/A (pre-implementation)

## Root Causes

N/A

## Changes Applied

| File | Change |
|------|--------|
| (none yet) | |
