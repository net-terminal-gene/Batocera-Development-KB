# Training mode — `fcade://training/` URL fix

**Date:** 2026-05-04  
**Game:** Street Fighter III: 3rd Strike (`sfiii3nr1`)  
**Mode:** Training

---

## Issue

Switchres did not activate for training mode. The game launched at menu resolution.

## Root cause

Fightcade training mode uses a third URL scheme:
- `fcade://play/fbneo/romname` — TEST GAME, outgoing challenges
- `fcade://served/fbneo/romname/session,port,flags` — incoming challenges
- `fcade://training/fbneo/romname` — training mode

The wrapper's regex only matched `play` and `served`:
```bash
if [[ "$URL" =~ fcade://(play|served)/([^/]+)/([^/]+) ]]; then
```

## Fix

Added `training` to the URL regex:
```bash
if [[ "$URL" =~ fcade://(play|served|training)/([^/]+)/([^/]+) ]]; then
```

## Discovery source

Fightcade log (`fcade.log`):
```
2026-05-04 23:34:50,186:INFO:Training: fcade://training/fbneo/sfiii3nr1
```

## Verification

Training mode launched with Switchres active after fix.

## Fightcade URL scheme reference (updated)

| URL | Trigger | Example |
|-----|---------|---------|
| `fcade://play/emu/rom` | TEST GAME, outgoing challenge | `fcade://play/fbneo/sfiii3nr1` |
| `fcade://served/emu/rom/session,port,flags` | Incoming challenge | `fcade://served/fbneo/sfiii3nr1/...` |
| `fcade://training/emu/rom` | Training mode | `fcade://training/fbneo/sfiii3nr1` |

Replay/spectating uses `fcade://stream/` — confirmed working.

**Final approach:** Replaced per-scheme whitelist (`play|served|training`) with wildcard regex `fcade://[^/]+/([^/]+)/([^/]+)` to catch all current and future URL schemes.
