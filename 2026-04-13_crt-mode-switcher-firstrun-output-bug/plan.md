# CRT Mode Switcher: First-Run Pre-Selects eDP-1 as CRT Output

## Agent/Model Scope

Composer + ssh-batocera for live system verification. Relates to `2026-04-11_crt-installer-videomode-bootstrap`.

## Problem

When the Mode Switcher runs for the first time after a CRT Script install, it pre-selects **eDP-1** as the CRT output. This is wrong — eDP-1 is the laptop's internal display, not the CRT. The CRT is connected on DP-1.

The user sees this on first launch of the Mode Switcher menu in CRT mode: the CRT output field is already populated with eDP-1.

## Root Cause

**Confirmed (2026-04-13):**

`mode_metadata.txt` is written using `batocera-settings-get global.videooutput` as the `VIDEO_OUTPUT=` value. Since the installer leaves `global.videooutput=eDP-1` in batocera.conf (the Wayland/HD value, never updated), `mode_metadata.txt` records `VIDEO_OUTPUT=eDP-1`. This metadata is what the Mode Switcher displays to the user as the current CRT output.

The actual restore file (`crt_mode/video_settings/video_output.txt`) correctly contains `global.videooutput=DP-1` (sourced from xrandr). So the restore works correctly — but the display is wrong.

The Mode Switcher saves the CRT output to two places from two different sources:

| File | Source | First-run value |
|------|--------|-----------------|
| `video_output.txt` | xrandr active output | `DP-1` (correct) |
| `mode_metadata.txt VIDEO_OUTPUT=` | `batocera-settings-get global.videooutput` | `eDP-1` (wrong) |

## Relationship to videomode-bootstrap

The `2026-04-11_crt-installer-videomode-bootstrap` session planned to pre-populate the CRT mode backup with the correct `DP-1` output, which would prevent this bug. However, that session is still in testing. This entry tracks the first-run output pre-selection bug specifically, regardless of how bootstrap proceeds.

## Solution

Two viable fixes (not mutually exclusive):

1. **Fix the metadata source in 03_backup_restore.sh:** Change the `VIDEO_OUTPUT=` line in `mode_metadata.txt` to read from xrandr (same source as `video_output.txt`) instead of `batocera-settings-get global.videooutput`. Targeted fix, no installer change needed.

2. **Bootstrap writes `global.videooutput=DP-1` to batocera.conf (installer fix):** Phase 2 writes the CRT output to batocera.conf. Then `batocera-settings-get global.videooutput` returns `DP-1` and `mode_metadata.txt` records the correct value automatically. Also makes the standalone display script skip the invalid-output fallback path. Broader fix, aligns with bootstrap plan.

Option 2 is preferred — it fixes the root data inconsistency. Option 1 is a fallback if writing `global.videooutput` to batocera.conf proves problematic.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | First-run output detection logic |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Bootstrap pre-populate (if chosen) |

## Validation

- [ ] After install: Mode Switcher first run does NOT pre-select eDP-1 as CRT output
- [ ] After install: Mode Switcher first run shows DP-1 (or correct CRT output) pre-selected
- [ ] Mode Switcher CRT→HD switch: correctly restores HD output (eDP-1), not CRT output
- [ ] Mode Switcher HD→CRT switch: correctly restores CRT output (DP-1), not HD output

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

