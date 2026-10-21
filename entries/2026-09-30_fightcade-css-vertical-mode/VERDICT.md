# VERDICT — Fightcade Flatpak CSS Vertical (TATE) Lobby Mode

## Status: MERGED

PR [#4](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/4) merged 2026-10-09 (`fa05fd5`) onto `main`. Hardware notes below were written while the branch was still open.

## Summary

(To fill on close.) Vertical/TATE lobby polish: rotated tooltip/cursor/`<select>` overlays,
50/50 room layout, pad cursor-axis remap, Search filter fix, zoom-aware fit with per-orientation zoom
persistence, and an FBNeo `nVidRotationAdjust` persistence fix in the CRT switchres restore.

## Plan vs reality

(To fill on close.) Notable in-flight change of direction: zoom was first *disabled/locked* to protect
the layout, then reworked into a proper zoom-aware fit after the user asked to keep zoom for smaller
TVs. Search filter scope was trimmed to just the filter button (user kept the field/padding).

## Root Causes

1. Chromium/OS paints tooltips, cursor, `<select>` popups, and applies webFrame zoom in screen space,
   ignoring the page CSS rotation.
2. `fightcade-pad-mouse` moves the cursor in landscape axes.
3. `.usersListWrapper` fixed-position + fixed width, inside a row flexbox.
4. Search input `min-width:400px` + `.inputWrapper` `padding-left:40px` overflow the portrait width.
5. Chromium `Preferences` per-host zoom flush is debounced, lost on kill-on-exit.
6. `crt/fightcade-crt-switchres` `restore_ini` full-file restore wipes in-game `fcadefbneo.ini`
   changes including `nVidRotationAdjust`.

## Changes Applied

| File | Change |
|------|--------|
| `lobby/inject.js` | Rotated tooltip + `<select>` overlays, `screenToLayout`, zoom-aware `applyFit`, zoom controls + watchdog, file-based vertical zoom persistence |
| `lobby/inject.css` | Rotated cursor, tooltip + `#fc-tate-select` styles, 50/50 room layout, Search filter button sizing |
| `input/fightcade-pad-mouse` | Vertical cursor-axis remap |
| `fightcade-lobby-zoom` | Skip vertical; orientation-split buckets |
| `crt/fightcade-crt-switchres` | Preserve `nVidRotationAdjust` across restore |

## Outstanding before close

- Physical pad confirmation of cursor movement direction.
- Full FBNeo rotation cycle (in-menu toggle → exit → relaunch).
- Landscape zoom save (still on Preferences path) and HD-panel pass.
- Commit on `feat/css-vertical-mode` and open PR (after user approval).
