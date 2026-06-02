# Design - CRT vertical autoconfig script

## Architecture

TBD after `research/` stabilizes. Expected shape:

1. **Probe:** `DISPLAY=:0 batocera-resolution listModes` (or parse `videomodes.conf`) to resolve exact mode strings.
2. **Preset tables:** one row per system (PCE, PCE CD, **SNES**, FBNeo, Neo Geo, **Vectrex**, …) or per ROM for exceptions; versioned in-repo JSON or shell associative arrays.
3. **Merge:** `batocera.conf` edits via awk/sed with backup (`*.bak`) or `batocera-settings-set` where applicable.
4. **RetroArch:** write only under `configs/retroarch/config/<core>/`; never touch unrelated cores.

Flow diagram and installer hook location (v43 `Batocera_ALLINONE` vs separate `userdata/system/scripts/`) TBD.
