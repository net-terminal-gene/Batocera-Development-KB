# VERDICT — BUA Fightcade Game Launch Fix

## Status: COMPLETE — VERIFIED WORKING

## Summary

Root cause identified through step-by-step observation comparing BUA and Flatpak Fightcade on the same Batocera system. The BUA game launch chain was completely broken because Batocera lacks `xdg-open` and `xdg-mime`, which are required for `fc2-electron` to dispatch `fcade://` URLs to the game coordinator. Fix applied to `fightcade.sh`, tested via clean reinstall on hardware. Game launched successfully (Street Fighter III: 3rd Strike via FBNeo through Wine).

## Deviation from Plan

The original plan anticipated root cause could be Wine prefix, writable directories, environment variables, or Wine discovery. It listed `sym_wine.sh` as a file to change. Actual outcome:

- **`sym_wine.sh` was NOT changed** — the original script works correctly; the timing issue was in the port launcher ordering, not in sym_wine.sh itself.
- **`fightcade_uninstall.sh` was NOT changed** — the existing `rm -rf` of the install directory covers all new files.
- **Plan did not anticipate** the need for an `xdg-open` shim, `Resources/wine.sh`, or Wine prefix initialization — all were added.
- **Two fix iterations were needed:**
  - v1: Used `fcade-quark` dispatcher + `.desktop`/`mimeapps.list` registration — failed because Batocera also lacks `xdg-open` (not just `xdg-mime`), so the `.desktop` file registration was inert.
  - v2 (working): Replaced with an `xdg-open` shim that routes directly to upstream `fcade.sh`. Simpler, zero custom dispatch code, uses the native Fightcade URL handling chain.

## Root Causes

1. **`xdg-open` missing** — `fc2-electron` calls `shell.openExternal("fcade://...")` which invokes `xdg-open` on Linux. Batocera has no `xdg-open`. Result: clicking Test Game sends a `fcade://` URL into the void — silent failure.
2. **`xdg-mime` missing** — `Fightcade2.sh` and `fcade.sh` gate URL handler registration behind `if [ -x /usr/bin/xdg-mime ]`. Since `xdg-mime` doesn't exist on Batocera, registration is skipped entirely.
3. **No `Resources/wine.sh` wrapper** — the `fcade` binary invokes `../../Resources/wine.sh` relative to the emulator directory to call Wine with a proper WINEPREFIX. This file did not exist in BUA.
4. **Wineboot timing race** — the port launcher ran `wineboot -u` (blocking) AFTER starting `sym_wine.sh` in background. `sym_wine.sh` waits 10 seconds then checks for `fc2-electron` — but `wineboot` blocked `Fightcade2.sh` from starting, so `fc2-electron` wasn't running yet. Result: `sym_wine.sh` removed the wine symlink and exited prematurely.

## Fix — Single File Change

Only `fightcade/fightcade.sh` was modified. All fixes are embedded in the generated port launcher script or installer logic.

### Changes to `fightcade.sh`

| Section | Change |
|---------|--------|
| Installer (line ~122) | **Added**: Generate `Resources/wine.sh` — Wine wrapper that sets `WINEPREFIX` and calls the Wine AppImage |
| Port launcher (line ~199) | **Added**: Create `$HOME/bin/xdg-open` shim at launch — routes `fcade://` URLs to upstream `emulator/fcade.sh`, export `PATH` so fc2-electron inherits it |
| Port launcher (line ~216) | **Reordered**: `wineboot -u` runs BEFORE `sym_wine.sh &` — fixes timing race |
| Installer (removed) | **Removed**: `fcade-quark` dispatcher generation (v1 approach) — upstream `fcade.sh` handles dispatch natively |

### Files Created on Batocera by Installer

| Path | Purpose |
|------|---------|
| `/userdata/system/add-ons/fightcade/Resources/wine.sh` | Wine wrapper — sets WINEPREFIX, calls Wine AppImage. Invoked by `fcade` binary at `../../Resources/wine.sh` |

### Files Created on Batocera at Launch Time (by port launcher)

| Path | Purpose |
|------|---------|
| `$HOME/bin/xdg-open` | Shim that routes `fcade://` URLs to `Fightcade/emulator/fcade.sh` |
| `$HOME/.wine/` | Wine prefix (created by `wineboot -u` on first launch only) |

### Working URL Dispatch Chain

```
fc2-electron (Test Game click)
  → shell.openExternal("fcade://play/fbneo/sfiii3nr1")
  → $HOME/bin/xdg-open "fcade://play/fbneo/sfiii3nr1"     [our shim]
  → Fightcade/emulator/fcade.sh "fcade://play/fbneo/..."   [upstream script]
  → fcade binary                                            [game coordinator]
  → ../../Resources/wine.sh fcadefbneo.exe sfiii3nr1        [our wine wrapper]
  → Wine AppImage → fcadefbneo.exe sfiii3nr1                [FBNeo via Wine]
```

## Validation

- [x] BUA Fightcade launches successfully
- [x] Login works
- [x] Joining a game room works
- [x] Game loads and emulator starts (FBNeo running sfiii3nr1 at 110% CPU)
- [x] `sym_wine.sh` stays alive monitoring fc2-electron (timing fix confirmed)
- [x] Wine symlink at `/usr/bin/wine` persists throughout session
- [x] Fix is 100% contained in `fightcade.sh` — no manual Batocera modifications

## Models Used

claude-4.6-opus-high-thinking — research, diagnosis, fix design, implementation, testing
