# Design — Pad-mouse architecture

## Components

```text
EmulationStation (per-game options)
        │
        ▼ gameStart
fightcade-game-hook ── sync_cursor_speed ──► /tmp/fightcade-cursor-speed.conf
        │              sync_lobby_chat
        ▼
fightcade-pad-mouse (daemon)
        ├─ resolve_cursor_speeds(hd/crt, lobby/menu/drag)
        ├─ SessionState.refresh() ──► PC vs Deck HD branch
        ├─ move pointer: xdotool (X11) | uinput (Wayland HD)
        └─ combos: pause/resume, Alt+F4, Alt+Tab, lobby chat

X11 only: fightcade-cursor (unclutter) — hide OS cursor when pad drives pointer
CRT gameplay: fightcade-crt-switchres + hostd (separate from lobby cursor speeds)
```

## Session refresh split (Deck fix)

**Problem:** On Deck HD, calling heavy refresh every frame (pgrep ×3, xdotool geometry, compositor hide) starved the loop → perceived “slow” cursor and move-stop-move stutter.

**Fix:** `SessionState.refresh()` dispatches:

- `_refresh_deck_hd()` when `wayland_hd_session()`
- `_refresh_pc_legacy()` otherwise (preserves pre-fix PC/CRT X11 behavior)

Deck-specific behaviors behind the same gate include: skip compositor cursor toggle, one-shot pointer placement for windowed FBNeo test mode, fractional stick accumulation, cached `fbneo/snes/flycast` flags instead of pgrep every poll in lobby.

## Speed resolution order

1. Built-in Python `DEFAULTS`
2. Shipped template conf
3. User `/userdata/system/configs/fightcade-pad-mouse.conf`
4. Overlay `/tmp/fightcade-cursor-speed.conf` (ES sliders at launch)

Context flags in the main loop pick among: default, **lobby**, **menu** (emulator menu open), **lobby_drag** (SOUTH held).

## Pointer visibility

`set_cursor_visible()` is a no-op on `wayland_hd_session()` so labwc does not warp the pointer when hiding the compositor cursor. X11 still uses `fightcade-cursor show|hide` when appropriate.
