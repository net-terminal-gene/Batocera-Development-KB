# Fightcade Switchres CRT Integration

## Agent/Model Scope

Cursor Agent + ssh-batocera, rsync-batocera skills. Opus for research/design, shell subagents for live system probing.

## Problem

Fightcade on Batocera runs arcade games (FBNeo, GGPO FBA, Snes9x, Flycast) through Wine at whatever the desktop resolution is. On a CRT system with the Batocera-CRT-Script, games should switch to native arcade modelines via Switchres for pixel-perfect output, but Fightcade bypasses the entire Batocera emulator launch pipeline (EmulationStation, configgen, batocera-resolution). Games launch through `fcade://` URL scheme handled by an xdg-open shim, not through the normal resolution-switching path.

## Root Cause

Fightcade's game launch chain (`fc2-electron` -> `xdg-open fcade://` -> `fcade.sh` -> `fcade` binary -> Wine + emulator.exe) is entirely self-contained. It never calls `batocera-resolution setMode`, never reads `videomodes.conf`, and never triggers Switchres. The `fcade` orchestrator binary is closed-source and expects specific Windows executables.

## Solution

Wrap the game launch at the xdg-open shim level (PR #143):

1. Parse `fcade://play/<emulator>/<romname>` URL to get emulator + ROM
2. Query `/usr/bin/mame/mame -listxml <rom>` for native width/height/refresh (29ms per lookup)
3. Patch FBNeo config for borderless windowed fullscreen (`bVidDX9WinFullscreen 1`, `bVidAutoSwitchFull 1`)
4. Call `switchres <w> <h> <refresh> -s -k` to switch display and keep mode on exit
5. Call `fcade.sh "$URL"` (returns immediately; fcade binary backgrounds itself)
6. Poll with `pgrep -f "<emulator_binary>"` until emulator exits (handles both TEST GAME manual exit and ONLINE MATCH auto-exit)
7. Restore FBNeo config from backup
8. Restore display resolution (xrandr back to ES/desktop mode)

**Key design constraint:** `fcade.sh` backgrounds the `fcade` binary with
`${FPY} ${PARAM} 2>&1 &`, so it returns to the caller immediately. Cannot use
`switchres -s -l "fcade.sh ..."` because switchres would restore resolution
the instant `fcade.sh` returns. Must use keep mode + active process monitoring.

**HD / CRT gating (defense in depth):** Do not use `videomodes.conf` alone. The
mode switcher removes it on HD switch, but dual-boot + shared userdata, interrupted
switches, or stale `batocera.conf` CRT markers can mislead. Gates: (1) Switchres
executable present; (2) userdata hints plus **runtime** check (e.g.
`batocera-resolution currentMode` CRT-shaped vs HD/default); (3) dual-boot: skip
Switchres when booted HD/Wayland path even if CRT files linger; (4) optional opt-in
flag under `/userdata/system/configs/` until auto-detection is proven. Default:
pass through to `fcade.sh` only.

**Session model:** User stays in Fightcade room between games. Each game launch
(TEST GAME or ONLINE MATCH) triggers a new `fcade://` URL. The shim blocks until
that specific game exits, restores resolution, then returns. Next game launch
repeats the cycle.

### Proof of Concept Results (2026-05-04)

**Confirmed working on live hardware:**
- Nanao MS929 (15kHz) via DP-1, AMD APU, Batocera v43
- Switchres generated `SR-1_384x224@59.60` modeline for SF3 Third Strike (CPS-3)
- Wine + FBNeo (`fcadefbneo.exe`) rendered fullscreen into the switched resolution
- Borderless windowed fullscreen (`bVidDX9WinFullscreen 1`) fills the CRT correctly
- Resolution auto-restored to 641x480@60 on process exit
- MAME database lookup provides exact per-ROM resolution+refresh

**Issues found:**
- FBNeo `-a` flag conflicts: tries Wine ChangeDisplaySettings to 512x224@0Hz, fails ("not a standard VGA resolution")
- ESC key toggles windowed mode instead of quitting; need Game > Exit or killall
- FBNeo config needs backup/restore around each game launch
- `fcade.sh` backgrounds `fcade` binary (`${FPY} ${PARAM} 2>&1 &`) so `switchres -s -l` cannot track lifecycle
- Must use `switchres -s -k` + `pgrep` polling + manual restore pattern

**Design clarification (Fightcade flow):**
- Both TEST GAME and ONLINE MATCH dispatch through the same `fcade://play/` URL
- xdg-open shim fires for every game launch within a Fightcade session
- TEST GAME ends when user does Game > Exit (manual)
- ONLINE MATCH ends when rounds complete (automatic)
- In both cases, the Wine/emulator process exits and `pgrep` polling detects it

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | fightcade/fightcade.sh | xdg-open shim modification (PoC testing) |
| (new) | test-switchres-fightcade.sh | PoC script (local to Batocera) |

## Deployment Path

Mikey does not own BUA or CRT-Script repos. Priority order:
1. **PoC in BUA** (current) — test in `batocera-unofficial-addons`, PR if validated
2. **CRT-Script extras** — curl post-install patch if BUA rejects
3. **Own repo** — standalone if both upstreams reject

See `design/README.md` § Deployment Strategy for full details.

## Validation

- [x] Switchres modeline generation for arcade ROM (384x224@59.60)
- [x] xrandr confirms SR-1_ modeline active during gameplay
- [x] Wine + FBNeo renders into switched resolution
- [x] Borderless windowed fullscreen fills CRT
- [x] Resolution restores on process exit
- [ ] Integration into xdg-open shim (automatic on game launch from Fightcade UI)
- [ ] Process exit detection via pgrep polling (replaces -l mode)
- [ ] Verify shim blocks correctly: resolution stays switched for full game duration
- [ ] Verify multi-game session: switch → game → restore → switch → game → restore
- [ ] Test with Neo Geo ROM (320x224@59.19)
- [ ] Test with Flycast (native Linux, Dreamcast)
- [ ] Test with GGPO FBA and Snes9x emulators
- [ ] FBNeo config backup/restore automation
- [ ] TEST GAME exit (manual Game > Exit)
- [ ] ONLINE MATCH exit (automatic after rounds)
- [ ] HD passthrough: no Switchres when gates fail (Switchres missing, runtime HD, dual-boot HD path, no opt-in)
- [ ] Dual-boot: Wayland/HD boot + stale CRT userdata does not trigger Switchres
- [ ] Opt-in path works when auto-detection is disabled or ambiguous
