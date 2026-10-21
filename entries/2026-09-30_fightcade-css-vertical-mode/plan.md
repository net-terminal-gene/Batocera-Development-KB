# Fightcade Flatpak — CSS Vertical (TATE) Lobby Mode

## Agent/Model Scope

Cursor agent + `~/bin/ssh-batocera.sh` / `~/bin/rsync-batocera.sh` against `batocera.local`. Deploy loop: rsync source into `/userdata/system/fightcade-flatpak/`, run `fightcade-lobby-vertical apply` to install into the nativefier app's `inject/` dir, then relaunch. `inject.css` is cached at app startup (needs full relaunch); `inject.js` is re-required each page load.

## Problem

Vertical/TATE mode rotates the lobby 90° with a CSS transform on `<html>`. That transform is a paint-space rotation, so:

1. Native `title` tooltips face the wrong way (OS-painted in screen space).
2. The mouse cursor is not rotated (OS-painted).
3. The pad-driven cursor moves along landscape axes (pad-right = screen-up on the rotated CRT).
4. Room layout: stock `.channelContent` is a row with a fixed-width users panel, squeezing chat into a narrow column on a portrait screen.
5. Search Games: filter (3-bar) button clipped/squished on the narrow width.
6. Native `<select>` filter dropdowns (Genre/System/Ranked/Year) open sideways (OS-painted popups).
7. webFrame zoom scales the whole rotated layout past the CRT and pushes the menu off screen (user got stranded, could not close the app).
8. Zoom did not persist across relaunch in vertical mode.
9. (Adjacent, found while testing vertical games) FBNeo `Video > Rotate vertically aligned games` did not persist across game relaunch.

## Root Cause

- 1,2,6,7: Chromium/OS paints tooltips, the cursor, `<select>` popups, and applies webFrame zoom in screen space, independent of the page CSS transform.
- 3: `fightcade-pad-mouse` moves the X cursor in landscape coordinates; the lobby is rotated but X is not.
- 4: `.usersListWrapper { position:fixed; top:60px; bottom:0; width:320px }` plus the row flexbox.
- 5: `input.text-filter { min-width:400px; width:50% }` + `.inputWrapper { padding-left:40px }` overflow the portrait width. (User later asked to keep padding; only the filter button sizing was changed.)
- 8: Chromium flushes `Preferences` (per-host zoom) on a debounced timer, so a zoom set right before ES kills the app is lost; `fightcade-lobby-zoom save` read the stale value.
- 9: `crt/fightcade-crt-switchres` `restore_ini` does a full-file `mv` of the pre-game backup over the live `fcadefbneo.ini` on exit, wiping in-game video-menu changes including `nVidRotationAdjust`.

## Solution

- Custom rotated overlays that live inside the rotated document: `#fc-tate-tip` (tooltip), `#fc-tate-select` (dropdown), pre-rotated CSS cursor. Positioned via `screenToLayout()` using the fit vars.
- Pad axis remap in `fightcade-pad-mouse`: when vertical, `dx,dy = -dy,dx`.
- Room layout: `.channelContent` → column; Looking to Play upper **40%**, Chat lower **60%**, independent scroll; override `usersListWrapper` to `position:static; width:100%`.
- Zoom-aware `applyFit`: fold zoom factor `z` into layout size (`winH/(s·z)`) and translate (`winW/z`) so the rotated content always re-fits at any zoom; keyboard/wheel/menu routed through it; watchdog re-fits on external (native-menu) zoom; clamp 0.6–2.2.
- Zoom persistence: `inject.js` writes the vertical zoom factor to `/userdata/system/fightcade-flatpak/lobby-zoom-vertical` the instant it changes and reads it on load; `fightcade-lobby-zoom` skips vertical (landscape keeps the Preferences flow), and its mode key now folds in `fcvertical` (`zoom_*_vertical` buckets) so the two orientations are independent.
- FBNeo rotation: `restore_ini` carries `nVidRotationAdjust` from the live ini across the backup restore.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-fightcade-flatpak | `lobby/inject.js` | Tooltip strip+overlay, `screenToLayout`, `setupSelects` rotated dropdown (fit-to-list sizing), zoom-aware `applyFit`, `installZoomControls` + watchdog, file-based vertical zoom persistence |
| batocera-fightcade-flatpak | `lobby/inject.css` | Rotated cursor, tooltip style, room 40/60 layout, Search filter button sizing, `#fc-tate-select` style |
| batocera-fightcade-flatpak | `input/fightcade-pad-mouse` | `lobby_vertical_enabled()`, `vertical_mode` in run_loop, `dx,dy=-dy,dx` remap |
| batocera-fightcade-flatpak | `fightcade-lobby-zoom` | Skip apply/save in vertical; `vertical_suffix()`/`detect_base_mode`/`detect_mode`; `zoom_*_vertical` buckets; status shows 4 buckets |
| batocera-fightcade-flatpak | `crt/fightcade-crt-switchres` | `restore_ini` preserves `nVidRotationAdjust` across the switchres backup/restore |

## Validation

- [x] Tooltip faces correct way (screenshot, upright).
- [x] Room 40/60 (Looking to Play / Chat) + independent scroll (CSS on device).
- [x] Cursor image rotated (screenshot).
- [ ] Cursor movement direction correct (needs physical pad press).
- [x] Search filter 3-bar icon renders (screenshot).
- [x] Filter `System` dropdown faces correct way and shows full list without scroll (user-confirmed).
- [x] Zoom works and stays constrained to the CRT at any level (user-confirmed).
- [x] Vertical zoom persists across exit/relaunch (file verified live + after exit; user-confirmed working).
- [ ] Landscape zoom still saves (user about to test; note: still on Chromium Preferences flush path).
- [ ] FBNeo rotation persists across a real game exit/relaunch (function verified on real config copies; needs physical in-menu toggle cycle).
- [ ] Full pass on HD panel as well as CRT.
