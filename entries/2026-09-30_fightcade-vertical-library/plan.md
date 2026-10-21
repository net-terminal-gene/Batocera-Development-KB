# Fightcade Vertical Library Genre Filter

## Agent/Model Scope

Cursor agent + `~/bin/ssh-batocera.sh` / `~/bin/rsync-batocera.sh` against `batocera.local`.
Deploy loop: rsync lobby files → `fightcade-lobby-vertical apply` → full Fightcade relaunch.

## Problem

The Fightcade lobby Search → Genre dropdown has no Vertical category. The user has a curated
list of Fightcade game ids that correspond to vertical-orientation ROMs (built from
cross-referencing `/Volumes/Batocera/SETUP/fightcade/roms` and `/Volumes/Batocera/vertical/roms`).
They want a Vertical genre that fetches Fightcade's real game list and shows only those games
that have a working preview (593 after the 404 strip).

A prior agent attempted this ~100 times and failed each time, leaving orphaned files on the
device (`vertical-ws.js`, `vertical-hook-min.js`). Those files were never committed.

## Root Cause (of prior failures)

The prior approach answered the Vertical search from a local cache (`allChannelsCache`) that was
built by intercepting WebSocket messages. The cache was almost always empty because:
1. The login `listAllChannels` message arrived before the WS hook was installed.
2. The hook re-used a flag that prevented re-wrapping, so the cache never filled.
3. When empty-cache was detected, the agent sent a real `all: true` request but then answered
   from the (still-empty) cache before the response arrived — empty list every time.

## Solution

Original approach (superseded 2026-10-01): page `{ req:"channels", all:true }` until the
whole library arrived, then filter to the allowlist. That is what other genres do not do.
Shooter and the rest are one paginated page. The full dump tripped `too many requests`
and Join on that same socket was refused. See `debug/2026-10-01-join-rate-limit.md`.

Shipped behavior (`719990f`):

1. `lobby/vertical-allowlist.js` — window-global `__FC_VERTICAL_IDS`, 593 game ids.
   Generated from the KB markdown by `scripts/gen-vertical-allowlist.py`.
2. `lobby/vertical-search.js` — page-world module (injected via `<script>` by `inject.js`):
   - Inserts "Vertical" into Vue's `genres` array in sort order (before the first genre
     that sorts after it, so it sits before W).
   - On genre=Vertical, delivers the local allowlist immediately. No catalog download.
   - On Join, one `channels` lookup for that gameid (then the allowlist title if needed).
     Join is sent with the server channel name. Later joins of the same game reuse the
     cached name.
3. `lobby/inject.js` — `setupVerticalSearch()` from `applyFit()`, plus a CTA file log at
   `/userdata/system/fightcade-flatpak/lobby/fc-cta.log` (vertical click timestamp).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-fightcade-flatpak | `lobby/vertical-allowlist.js` | New: 732-id window-global allowlist |
| batocera-fightcade-flatpak | `lobby/vertical-search.js` | New: page-world genre+WS filter module |
| batocera-fightcade-flatpak | `lobby/inject.js` | Added `setupVerticalSearch()` + call in `applyFit` |
| batocera-fightcade-flatpak | `fightcade-lobby-vertical` | Updated comment; new files stay in lobby/ |
| batocera-fightcade-flatpak | `install.sh` | Added `vertical-allowlist.js` + `vertical-search.js` to FILES |
| batocera-fightcade-flatpak | `scripts/gen-vertical-allowlist.py` | New: generator from KB markdown |

## Validation

- [x] Genre dropdown includes **Vertical**, in alphabetical order (before W). Code landed 2026-10-01; menu position needs a relaunch to confirm on screen.
- [x] Selecting Vertical shows the allowlist immediately (`vertical-list` count 593, same millisecond as the click). 2026-10-01 on batocera.local.
- [x] List is the allowlist, not the full library.
- [x] Join opens the real channel. 1945k III, 1943 Kai, and Zzyzzyxx each `result: 200` in about 0.4s. Zzyzzyxx `join-room true`.
- [ ] Leaving Vertical and picking another genre restores normal results
- [ ] TATE lobby (tooltips, selects, zoom) still works after this change
