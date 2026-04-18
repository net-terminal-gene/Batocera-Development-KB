# v43 EDID Wrong Matrix on AMD Re-Install

## Agent/Model Scope

Composer + ssh-batocera for log retrieval. Investigation only until logs arrive — fix scope TBD.

## Problem

Tester (AMD RX6400 XT) reports that on a v43 install re-run after an HD↔CRT round trip, the regenerated `/lib/firmware/edid/generic_15.bin` contains the wrong modeset.

| | Expected (AMD branch) | Observed |
|---|---|---|
| Preferred mode | `768x576@25` | `1280x240 59.68 +` |
| Active mode | `768x576@25` | `769x576 50.00*` (NVIDIA `+1` width bump) |
| Matrix used | native (`320x240@60 640x480@30 768x576@25`) | superres (`1280x240@60 1280x480@30 1280x576@25`) |
| EDID physical size | 485mm × 364mm (boot 1) | 400mm × 300mm (boot 3) |

The HD↔CRT mode switcher itself is fine. EDID changed because the install script was re-run, and on that re-run it took the Intel/NVIDIA-NOUV branch instead of the AMD/ATI branch.

## Root Cause

TBD. Confirmed not the mode switcher (no `switchres -e` in `mode_switcher_modules/*`). Three candidates:

1. `TYPE_OF_CARD` detection failed → `else` branch fired (line 3542 of v43)
2. `TYPE_OF_CARD == "AMD/ATI"` but matrix lookup or switchres call wrote 1280x… anyway
3. EDID file is stale (file mtime predates the "switch back to CRT" reboot)

## Solution

Pending logs. Fix path depends on which root cause is confirmed.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | TBD (lines 3509–3552 if detection bug; lines 3554–3658 if lookup bug) |

## Validation

- [ ] Confirm `TYPE_OF_CARD` detected as `AMD/ATI` for RX6400 on a clean install
- [ ] Confirm `EDID build:` log line uses chosen menu res (e.g. `switchres 768 576 25 ...`), not 1280x…
- [ ] Confirm `generic_15.bin` after install has `768x576@25` as preferred mode (`edid-decode`)
- [ ] Confirm xrandr in CRT mode shows the chosen mode preferred, not a superres
