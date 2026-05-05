# Replay / Spectating — `fcade://stream/` URL Fix

**Date:** 2026-05-04  
**Game:** Street Fighter III: 3rd Strike (`sfiii3nr1`)  
**Mode:** Replay (spectating a recorded match)

---

## Issue

Switchres did not activate when launching a replay from Fightcade. The game ran at menu resolution instead of CRT-native 384x224.

## Root Cause

Fightcade dispatches replay URLs as `fcade://stream/emu/rom/session,port`. The wrapper regex at that point was `fcade://(play|served|training)/` which did not include `stream`.

## Fix

Replaced the per-scheme whitelist with a wildcard regex that captures any action:

```bash
# Before
if [[ "$URL" =~ fcade://(play|served|training)/([^/]+)/([^/]+) ]]; then

# After
if [[ "$URL" =~ fcade://[^/]+/([^/]+)/([^/]+) ]]; then
```

`BASH_REMATCH` indices shifted accordingly:
- `emu="${BASH_REMATCH[1]}"` (was `[2]`)
- `rom="${BASH_REMATCH[2]}"` (was `[3]`)

The wildcard approach future-proofs against additional URL schemes Fightcade may introduce.

## Verification

```
=== XRANDR (during replay) ===
SR-1_384x224@59.60 *current
  h: width 384 start 415 end 452 total 506 clock 15.50KHz
  v: height 224 start 234 end 237 total 260 clock 59.60Hz

=== WRAPPER ===
PID active with fcade://stream/fbneo/sfiii3nr1/...
```

Switchres engaged, CRT displayed at 384x224@59.60. Replay played back correctly.

## Complete Fightcade URL scheme reference

| URL | Trigger | Example |
|-----|---------|---------|
| `fcade://play/emu/rom` | TEST GAME, outgoing challenge | `fcade://play/fbneo/sfiii3nr1` |
| `fcade://served/emu/rom/session,port,flags` | Incoming challenge | `fcade://served/fbneo/sfiii3nr1/...` |
| `fcade://training/emu/rom` | Training mode | `fcade://training/fbneo/sfiii3nr1` |
| `fcade://stream/emu/rom/session,port` | Replay / spectating | `fcade://stream/fbneo/sfiii3nr1/...` |

All handled by wildcard regex `fcade://[^/]+/([^/]+)/([^/]+)`.
