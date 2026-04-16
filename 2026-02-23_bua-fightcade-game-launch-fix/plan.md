# BUA Fightcade Game Launch Fix

## Agent/Model Scope

Composer + ssh-batocera skill for live diagnostics on Batocera hardware.

## Problem

BUA (batocera-unofficial-addons) Fightcade installs and launches correctly — login works — but loading a game fails. The Flatpak version of Fightcade works end-to-end on the same system, including game launch.

## Root Cause

TBD — to be determined via step-by-step observation comparing BUA vs Flatpak behavior.

## Solution

TBD — pending root cause identification.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | fightcade/fightcade.sh | BUA installer |
| batocera-unofficial-addons | fightcade/sym_wine.sh | Wine symlink manager |
| (on Batocera) | /userdata/roms/ports/Fightcade.sh | Generated port launcher |

## Validation

- [ ] BUA Fightcade launches successfully
- [ ] Login works
- [ ] Joining a game room works
- [ ] Game loads and emulator starts
- [ ] Compare behavior matches Flatpak version

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

