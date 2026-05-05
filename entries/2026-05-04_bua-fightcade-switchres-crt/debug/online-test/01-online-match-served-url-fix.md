# Online match — `fcade://served/` URL fix

**Date:** 2026-05-04  
**Game:** Street Fighter III: 3rd Strike (`sfiii3nr1`)  
**Match type:** Online (incoming challenge)

---

## Issue

Switchres did not activate for online matches. The game launched at menu resolution (641x480i) instead of the correct 384x224.

## Root cause

Fightcade uses two URL schemes:
- `fcade://play/fbneo/romname` — TEST GAME and outgoing challenges
- `fcade://served/fbneo/romname/session,port,flags` — incoming challenges (you're being served)

The wrapper's regex only matched `play`:
```bash
if [[ "$URL" =~ fcade://play/([^/]+)/([^/]+) ]]; then
```

When receiving `fcade://served/...`, the wrapper fell through to `exec "$FCADE_SH" "$URL"`, bypassing all Switchres logic.

## Fix 1: URL regex (primary fix)

Updated regex to match both URL schemes:
```bash
if [[ "$URL" =~ fcade://(play|served)/([^/]+)/([^/]+) ]]; then
    emu="${BASH_REMATCH[2]}"
    rom="${BASH_REMATCH[3]}"
```

Capture groups shifted: group 1 = `play|served`, group 2 = emulator, group 3 = ROM.

## Fix 2: wait_for_emulators grace period (defensive)

Added 3-second re-check after emulator process disappears, to handle potential process restarts during online match GGPO connection setup:

```bash
while true; do
    while pgrep -f "$EMU_Pgrep_RE" >/dev/null 2>&1; do
        sleep 0.4
    done
    sleep 3
    pgrep -f "$EMU_Pgrep_RE" >/dev/null 2>&1 || break
done
```

## Verification

```
=== XRANDR (during online match) ===
SR-1_384x224@59.60 *current
  h: width 384 start 415 end 452 total 506 clock 15.50KHz
  v: height 224 start 234 end 237 total 260 clock 59.60Hz

=== WRAPPER ===
27428 /bin/bash .../switchres_fightcade_wrap.sh fcade://served/fbneo/sfiii3nr1/1777954220872-1172.1,7000,0,null
```

Wrapper correctly parsed `fcade://served/` URL, set Switchres mode, and remained running to monitor emulator lifecycle.

## Fightcade URL scheme reference (complete)

| URL | Trigger | Example |
|-----|---------|---------|
| `fcade://play/emu/rom` | TEST GAME, outgoing challenge | `fcade://play/fbneo/sfiii3nr1` |
| `fcade://served/emu/rom/session,port,flags` | Incoming challenge | `fcade://served/fbneo/sfiii3nr1/...` |
| `fcade://training/emu/rom` | Training mode | `fcade://training/fbneo/sfiii3nr1` |
| `fcade://stream/emu/rom/session,port` | Replay / spectating | `fcade://stream/fbneo/sfiii3nr1/...` |

All dispatched via Fightcade's Electron UI → `xdg-open` shim → wrapper.

**Final regex:** `fcade://[^/]+/([^/]+)/([^/]+)` — matches any action, captures emulator and ROM. Avoids whitelisting individual URL schemes as Fightcade may add more in the future.
