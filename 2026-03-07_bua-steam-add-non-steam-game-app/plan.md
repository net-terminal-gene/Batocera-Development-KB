# BUA Steam — Add Non-Steam Game to ES App

## Agent/Model Scope

Composer + ssh-batocera for live validation and deployment.

## Problem

Adding a non-Steam game to EmulationStation currently requires multiple manual steps: copying files to the right directory, entering Steam Desktop Mode, adding the game via "Add a Non-Steam Game", setting Proton, launching once from Big Picture to create the Wine/Proton prefix, then waiting for the launcher generator to pick it up.

Users need a single script that takes a game exe and does everything automatically — no Steam Desktop Mode, no Big Picture interaction.

## Root Cause

Proton direct launch (validated in `2026-03-06_bua-steam-non-steam-game-launchers`) bypasses Steam entirely — no `shortcuts.vdf`, no `config.vdf`, no `CompatToolMapping` needed. The only requirements are:
1. Game files in a location Proton can access
2. A `compatdata/` prefix (created by `proton run wineboot -u`)
3. A `.sh` launcher script in `/userdata/roms/steam/`

None of these require Steam to be running or any Steam UI interaction.

## Prior Art

- `2026-03-06_bua-steam-non-steam-game-launchers` — Proved Proton direct launch works, documented all failed Steam CLI approaches, built `shortcuts.vdf` parser, extended `create-steam-launchers2.sh`

## Solution

### Intended User Flow (Target UX)

1. **Open app** — User launches Add Non-Steam Games from ES > Steam.

2. **Initial screen** — Cancel button available immediately. No OK yet. Cancel → exit back to ES anytime.

3. **Scan results** — App scans `non-steam-games/` and lists all directories with potential `.exe` files. **OK button appears here** to proceed. Cancel → exit to ES.

4. **Exe picker (per directory)** — For each directory, show which `.exe` to use. **Even if only 1 exe in folder, show the choice.** Cancel & OK. Cancel → exit to ES. OK → proceed to next directory. Repeat for each directory.

5. **Final confirmation** — "Are you sure you want to add the games to your ES Steam library?" Cancel → exit to ES. OK → add games, update gamelist, **automatically return to ES**.

### Implementation Note

**Cancel and OK must work at every step.** yad + evmapy has proven unreliable (ES keeps X11 focus; controller keys never reach dialogs). Options: (a) Pygame-based UI (like BUA) that reads controller directly; (b) fix xdotool focus; (c) xterm wrapper. Current script uses auto-pick heuristic as workaround; does not match intended flow.

### Script: `add-non-steam-game.sh`

**Input directory:** `/userdata/system/add-ons/steam/non-steam-games/`

**Proton auto-detection:** Scan `steamapps/common/Proton*/proton` — pick newest versioned, fallback to Experimental.

**Prefix creation:** On first game launch (not at add time). Launcher runs `proton run wineboot -u` if prefix missing.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/add-non-steam-game.sh` | New — dialog-based app that scans, creates launchers, updates gamelist, exe picker for multi-exe folders |
| batocera-unofficial-addons | `steam/steam2.sh` | Downloads add-non-steam-game.sh, creates ES launcher (xterm wrapper for controller/keyboard) + gamelist entry, creates non-steam-games dir |
| batocera-unofficial-addons | `steam/extra/Add_Non-Steam_Games.sh.keys` | New — mode_switcher-style controller mappings (d-pad, start/b, a/select) |
| batocera-unofficial-addons | `steam/extra/deploy-add-non-steam-games.sh` | Manual deploy; removed CRT duplication; uses shared .keys file |

## Validation (Target UX — see design/UX-FLOW.md)

- [ ] **Step 1:** Open app from ES > Steam
- [ ] **Step 2:** Initial screen — Cancel available, no OK yet; Cancel → ES
- [ ] **Step 3:** Scan results list — Cancel & OK; OK proceeds; Cancel → ES
- [ ] **Step 4:** Exe picker per directory (even if 1 exe) — Cancel & OK; OK → next; Cancel → ES
- [ ] **Step 5:** Final confirmation — Cancel & OK; OK → add games, auto-return to ES
- [ ] Proton prefix created on first game launch
- [ ] Hotkey+Start exits game and returns to ES

## Deployed State (Remote Batocera)

- **Launcher:** `/userdata/roms/steam/Add_Non-Steam_Games.sh` — xterm wrapper, correct quoting
- **Main script:** `/userdata/system/add-ons/steam/extra/add-non-steam-game.sh`
- **Test games:** `non-steam-games/Infinos2/` (KeyConfig.exe + infinos_2.EXE for exe picker), `TestTwoExes/` (Game.exe + Launcher.exe)
- **Source:** Infinos 2 from BATO-PARROT `/userdata/roms/windows/Infinos 2.wsquashfs` — copy, unsquash to `non-steam-games/Infinos2/`
