# BUA Steam Per-Game VIDEO MODE Fix

## Problem

When using BUA (Batocera Unofficial Addons) Steam with per-game VIDEO MODE settings (e.g. 854x480 for Crystal Breaker on CRT), the selected mode was not applied at launch. The display remained at boot resolution (e.g. 769x576).

- **Symptom:** `batocera-resolution currentResolution` reports boot resolution instead of the per-game videomode
- **Config:** `batocera.conf` correctly stores `steam["2772080_Crystal_Breaker.sh"].videomode=854x480.60.00045`
- **Cause:** Configgen was reading per-game settings under `ports["..."]` instead of `steam["..."]`, and using the wrong emulator

## Root Cause

1. **`es_systems_steam.cfg`** used `-system ports -systemname ports`, so configgen looked up `ports["game.sh"]` in batocera.conf. Per-game videomode is stored as `steam["game.sh"]` → never loaded.

2. **Emulator mismatch:** BUA Steam used `emulator name="steam"` (Flatpak/batocera-steam path). That runs `batocera-steam` which expects Flatpak Steam, not BUA. Without `steam.emulator=sh` in batocera.conf, configgen falls back to steam generator → failure when Flatpak Steam is not installed.

3. **Duplicate VIDEO MODE:** `es_features_steam.cfg` had explicit `videomode` in emulator features; steam emulator already gets it from `shared_features` → duplicate entry in UI.

## Solution

### 1. es_systems_steam.cfg

| Change | Before | After |
|--------|--------|-------|
| Command | `-system ports -systemname ports` | `-system steam -systemname steam` |
| Emulator | `name="steam"` | `name="sh"` |
| Core | `steam` | `sh` |

### 2. es_features_steam.cfg

Remove duplicate `videomode` from emulator features list.

### 3. steam.sh (installer)

Add to batocera.conf on install:

```
steam.emulator=sh
steam.core=sh
```

Remove any existing `steam.emulator` / `steam.core` lines first, then append.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/es_systems_steam.cfg` | -system steam, sh emulator |
| batocera-unofficial-addons | `steam/extra/es_features_steam.cfg` | Remove videomode from features |
| batocera-unofficial-addons | `steam/steam.sh` | Add steam.emulator=sh, steam.core=sh on install |

## Validation

- [ ] Fresh BUA Steam install → steam.emulator=sh and steam.core=sh present in batocera.conf
- [ ] Per-game VIDEO MODE (e.g. 854x480) applied at game launch
- [ ] `batocera-resolution currentResolution` matches selected mode during game run

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

