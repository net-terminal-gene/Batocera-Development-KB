# BUA Steam Boot-Time Ensure

## Agent/Model Scope

Composer + stage-commit skill

## Problem

BUA (Batocera Unofficial Addons) Steam requires `steam.emulator=sh` and `steam.core=sh` in batocera.conf to run .sh launchers. When Batocera is updated (e.g. v42 → v43), batocera.conf can be overwritten or merged in a way that drops steam.* entries—games then fail with:

```
error: app/com.valvesoftware.Steam/x86_64/master not installed
```

Especially relevant on Steam Deck, where system updates are frequent.

## Root Cause

System updates and other batocera.conf overwrites can remove `steam.emulator` and `steam.core`. Without them, configgen falls back to the Flatpak steam generator, which fails when BUA Steam (non-Flatpak) is installed.

## Solution

A **boot-time ensure script** that re-adds `steam.emulator=sh` and `steam.core=sh` when they are missing:

- Script `ensure_steam_batocera_conf.sh` runs at boot via `custom.sh`
- Adds both keys **only when absent** (e.g. after a system update wiped them)
- Idempotent: if already present, does nothing

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/ensure_steam_batocera_conf.sh` | New: boot-time script |
| batocera-unofficial-addons | `steam/steam.sh` | Download script, register in custom.sh |
| batocera-unofficial-addons | `steam/steam2.sh` | Same |

## PR Status

**PR #145** (open): [batocera-unofficial-addons#145](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/145)

## Validation

- [x] Fresh BUA Steam install → steam.emulator=sh and steam.core=sh present; ensure script exits immediately on boot
- [x] Simulate config loss → remove steam.* from batocera.conf, reboot → ensure script re-adds them, Steam launches

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

