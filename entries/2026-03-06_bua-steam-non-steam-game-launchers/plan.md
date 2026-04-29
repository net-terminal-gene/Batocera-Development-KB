# BUA Steam — Non-Steam Game Launchers for ES

## Agent/Model Scope

Composer + ssh-batocera for live validation. Research phase only — no code changes yet.

## Problem

Non-Steam games added to Steam via "Add a Non-Steam Game" do not appear in EmulationStation's Steam game list. They are only accessible through Steam Big Picture Mode.

BUA's `create-steam-launchers.sh` generates `.sh` launcher files in `/userdata/roms/steam/` for installed Steam games using the format `APPID_Name.sh`. Non-Steam games do not have real Steam App IDs — they are assigned locally-generated shortcut IDs — so `create-steam-launchers.sh` skips them entirely.

Users want to browse and launch all their Steam-managed games (including non-Steam titles running under Proton) directly from EmulationStation without entering Big Picture Mode.

## Root Cause

`create-steam-launchers.sh` only enumerates games with real Steam App IDs (from `appmanifest_*.acf` files in `steamapps/`). Non-Steam games are stored in `shortcuts.vdf` (a separate binary file) with synthetic shortcut IDs. The script never reads `shortcuts.vdf`.

Confirmed via live system inspection: the script loops every 5 seconds scanning only `$STEAM_APPS/appmanifest_*.acf`.

## Solution

TBD — three candidate approaches identified, refined after live system inspection.

### Approach A: `.steam` files (simplest — preferred)

The live system already has `.steam` files alongside `.sh` files. Each `.steam` file is just:
```
steam://rungameid/APPID
```

For non-Steam games, the approach would be:
1. Parse `shortcuts.vdf` to get game names and shortcut IDs
2. Create `GameName.steam` containing `steam://rungameid/SHORTCUTID`
3. ES picks it up via `.steam` extension (matches `es_systems.cfg`)

**Advantages:** No bash template needed. Single-line file. Uses Batocera's native steam system path.

**Unknowns:** Does `steam://rungameid/` work with non-Steam shortcut IDs (high bits set)? Does `.steam` work when `steam.emulator=sh` is set in `batocera.conf`?

### Approach B: `.sh` launchers (matching BUA format)

Extend `create-steam-launchers.sh` (or add companion script) to also scan `shortcuts.vdf` and generate `.sh` launchers using the same template but with `steam://rungameid/SHORTCUTID` instead of `-applaunch APPID`.

**Advantages:** Consistent with existing `.sh` infrastructure. Works with `steam.emulator=sh` override.

**Unknowns:** Can `-applaunch` be used with shortcut IDs, or must `steam://rungameid/` be used?

### Approach C: Manual creation (no automation)

Document how users can manually create a `.steam` or `.sh` file for each non-Steam game. User must find the shortcut ID themselves (from `shortcuts.vdf` via `strings` or Big Picture Mode).

**Advantages:** Zero code changes. Works today.

**Disadvantages:** Requires technical knowledge. Error-prone.

## User Journey by Approach

### Approach A: `.steam` files (automated)

1. User opens Steam Big Picture from ES (selects `Steam_Big_Picture.sh`)
2. Exits Big Picture to desktop mode inside Steam
3. Clicks "Add a Game" → "Add a Non-Steam Game" → browses to the `.exe`
4. Re-enters Big Picture, finds the game, sets Proton version in properties
5. Exits Steam (returns to ES)
6. **Next time Steam Big Picture is launched**, companion script detects entries in `shortcuts.vdf` and auto-generates `.steam` files
7. On Steam exit, Launcher calls `curl http://127.0.0.1:1234/reloadgames` — game appears in ES
8. User selects the game directly from ES like any other Steam game

**User effort beyond current flow:** None. Steps 1-5 are already required to play the game at all. Steps 6-8 are automatic.

**Limitations:** No padtokey hotkey, no game image in ES (unless scraped), no `gamelist.xml` entry.

### Approach B: `.sh` launchers (automated, matching BUA format)

1. Same steps 1-5 as Approach A
2. Exit Steam → returns to ES
3. Script parses `shortcuts.vdf`, creates `SHORTCUTID_GameName.sh` + `.sh.keys` + `gamelist.xml` entry + downloads image
4. ES reloads → game appears with name and header image

**User effort beyond current flow:** None. Fully automatic.

**Advantages over A:** Padtokey hotkey (hotkey+start kills Steam), header image, proper `gamelist.xml` metadata.

### Approach C: Manual creation (no automation)

1. Same steps 1-5 as Approach A
2. Exit Steam → returns to ES
3. User SSHs into Batocera
4. Finds the shortcut ID by running `strings` on `shortcuts.vdf` and correlating to game name
5. Creates file manually: `echo "steam://rungameid/SHORTCUTID" > /userdata/roms/steam/MyGame.steam`
6. Reloads ES: `curl http://127.0.0.1:1234/reloadgames`
7. Game appears in ES

**User effort beyond current flow:** Significant — SSH access, command-line comfort, binary file inspection. Not realistic for most users.

### Comparison

| | A: `.steam` auto | B: `.sh` auto | C: Manual |
|---|---|---|---|
| User adds game in Steam | Yes | Yes | Yes |
| User does anything extra | No | No | Yes (SSH, find ID, create file) |
| Script needed | Yes | Yes | No |
| Padtokey hotkey | No | Yes | No |
| Game image in ES | No | Yes | No |
| gamelist.xml entry | No | Yes | No |
| Works with `steam.emulator=sh` | Unknown | Yes | Unknown |
| Complexity to build | Low | Medium | None |

[Inference] Approach B is likely the most robust — it matches the existing BUA infrastructure and is guaranteed to work with the `steam.emulator=sh` override. Approach A is simpler but has an untested interaction with that override. Both require the same core work: parsing `shortcuts.vdf`.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| TBD  | TBD  | TBD    |

## Validation

- [x] Identify where `shortcuts.vdf` lives → per-user: `Steam/userdata/1080337349/config/shortcuts.vdf`
- [x] Read full `create-steam-launchers.sh` source → confirmed: only scans `appmanifest_*.acf`
- [x] Read full Launcher source → starts create-steam-launchers.sh in background, monitors Steam via wmctrl
- [x] Read `.sh` launcher template → `steam -gamepadui -silent -applaunch APPID`
- [x] Read `.steam` file format → single line: `steam://rungameid/APPID`
- [x] Read `.sh.keys` format → padtokey JSON (hotkey+start → pkill steam)
- [x] Confirm ES system config → extension is `.steam`, overridden to `.sh` via batocera.conf
- [x] Add a non-Steam game to Steam → Maldita Castilla (from windows wsquashfs)
- [x] Parse `shortcuts.vdf` → shortcut ID 3755861458, AppName "Maldita Castilla.exe"
- [x] Create manual `.steam` file → does NOT appear in ES (steam.emulator=sh ignores .steam)
- [x] Create manual `.sh` launcher → DOES appear in ES
- [ ] Launch non-Steam game from ES → Steam opens; game does not launch (both steam:// and -applaunch tried)
- [ ] Resolve launch failure → cause unknown; launcher also blocks on `wait` until pkill

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

