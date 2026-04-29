# v43 Docked Detection Display Override

## Agent/Model Scope

- claude-4.6-sonnet-medium-thinking -- investigation session (March 28, read-only, SSH diagnostics via ssh-batocera skill)
- claude-4.6-opus-max -- fix implementation and KB update (April 2)

## Problem

On Batocera v43, plugging in a second display causes the primary configured display to go blank. The system switches output to the newly connected display, ignoring the user's explicitly saved `global.videooutput` setting. Observed on Steam Deck (eDP-1 + DP-1 CRT) and confirmed on plain PC (HDMI-2 + DP-1). No CRT script required to reproduce — stock v43 behavior.

## Root Cause

Two upstream commits in `batocera.linux` (March 13–14, 2026) added `_detect_docked_output()` to `batocera-switch-screen-checker`. The function was designed for handhelds like the RP5 that physically dock into an external display. However the logic ran unconditionally on all hardware with no platform guard:

- Read `global.videooutput` / `global.videooutput2` / `global.videooutput3` from settings
- Compare all physically connected outputs against those settings
- Any connected output NOT in settings → flagged as "external/docked" → written to `/var/run/batocera-docked`
- `emulationstation-standalone` reads the flag and overrides `global.videooutput` with the docked output

On a PC or Steam Deck in HD mode, the CRT (or any second display) is connected but not listed as output2 (set to "none"), so it gets flagged as a dock every time.

## Solution

dmanlfc issued a fix (shared via Google Drive before GitHub push) that inverts the logic in `_detect_docked_output()`:

**Before:** If outputs are configured, compare connected outputs and flag unknowns as docked.

**After:** If ANY explicit video output is configured (`global.videooutput` / `global.videooutput2` / `global.videooutput3` non-empty), skip docked detection entirely and remove the docked flag. Docked detection only runs when zero outputs are configured.

Fix not yet pushed to `batocera.linux` GitHub as of March 28, 2026.

## Secondary Issue Found

The CRT script (when writing HD output to `batocera.conf`) saved the DRM connector name (`HDMI-A-2`) instead of the xrandr/batocera-resolution name (`HDMI-2`). These differ on some AMD GPUs. ES validates against `batocera-resolution listOutputs` which uses xrandr naming, so `HDMI-A-2` is rejected as invalid and ES falls back to the CRT output. This is a separate CRT script bug.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-switch-screen-checker` | Broken: `d9b1d23bfc`, `aca5e9c751`. Fixed: dmanlfc (Google Drive only, not yet on GitHub) |
| batocera.linux | `package/batocera/emulationstation/batocera-emulationstation/emulationstation-standalone` | Same commits — added DOCKED_FLAG read and override |
| Batocera-CRT-Script | `UsrBin_configs/emulationstation-standalone-v43_ZFEbHVUE-MultiScreen` | PR #405 (`4fce0e9`, March 18) ported the same docked logic from upstream |
| Batocera-CRT-Script (main) | Merged via `cbdcc04` into `crt-hd-mode-switcher-v43` on March 28 |  |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` | `1c01262`: Added `drm_name_to_xrandr()` normalization to fix DRM vs xrandr name mismatch |

## Fix Applied: DRM-to-xrandr Output Name Normalization (April 2, 2026)

The secondary issue (root cause #5) was fixed by adding a `drm_name_to_xrandr()` normalization function to `02_hd_output_selection.sh`.

**Approach:** `scan_xrandr_outputs()` must use DRM sysfs for enumeration (xrandr may not list inactive outputs in CRT mode), but the DRM connector names (`HDMI-A-N`) differ from xrandr names (`HDMI-N`) on AMD GPUs. The fix normalizes names immediately after extraction from sysfs, before they enter the `ALL_OUTPUTS`/`CONNECTED_OUTPUTS` arrays. All downstream code (selection dialog, backup files, `batocera.conf`) then receives xrandr-format names.

**File changed:** `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh`
- Added `drm_name_to_xrandr()`: pattern `HDMI-[A-Z]-*` converts any HDMI subtype to `HDMI-N` (covers kernel types HDMI-A and HDMI-B per `drm_connector_enum_list` in `drm_connector.c`); all other names pass through unchanged
- Applied `name=$(drm_name_to_xrandr "$name")` in `scan_xrandr_outputs()` after sysfs name extraction

**Why not `batocera-resolution listOutputs`:** In CRT mode, X11 has only the CRT output active. `listOutputs` (which wraps `xrandr --listConnectedOutputs`) would not show HD outputs. DRM sysfs shows all physical connectors regardless of X11 state.

**Commit:** `1c01262` on branch `crt-hd-mode-switcher-v43`, pushed April 2, 2026.

## Validation

- [x] Reproduced on Steam Deck -- eDP-1 goes blank when DP-1 CRT connected
- [x] Reproduced on PC -- HDMI-2 goes blank when DP-1 plugged in
- [x] Confirmed docked flag written: `/var/run/batocera-docked` contains second output name
- [x] Confirmed fix works on dmanlfc's patched image -- docked flag never written when outputs configured
- [x] Confirmed secondary CRT script issue: `HDMI-A-2` vs `HDMI-2` name mismatch
- [x] CRT script fix applied: `drm_name_to_xrandr()` normalization in `02_hd_output_selection.sh`
- [x] Tested on Batocera hardware via SSH: HD backup `video_output.txt` confirmed `global.videooutput=HDMI-2`
- [x] Committed and pushed: `1c01262` on `crt-hd-mode-switcher-v43`
- [ ] Wait for dmanlfc docked detection fix to land on batocera.linux GitHub

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

