# Debug — HD Mode Switcher DRM vs xrandr Output Name Bug (April 2, 2026)

## Issue Confirmed: Reproducible

Ran the HD/CRT Mode Switcher to switch back to HD mode (before reboot). The mode switcher wrote:

```
global.videooutput=HDMI-A-2
```

This is the DRM connector name. `batocera-resolution listOutputs` (xrandr) exposes this port as `HDMI-2`. These are different strings and ES validates against the xrandr name, so the setting is rejected on boot:

```
Standalone: Invalid output - HDMI-A-2
Standalone: First video output defaulted to - DP-1
```

This bug is reproducible every time the mode switcher writes the HD output to `batocera.conf`. The CRT output (`DP-1`) does not have this problem — it writes the correct xrandr name. The mismatch is specific to HDMI ports on this AMD GPU (Navi 32).

## Workaround Applied

Manually corrected via SSH:

```bash
batocera-settings-set global.videooutput HDMI-2
```

## Name Mapping on This Machine

| DRM connector name | xrandr / batocera-resolution name |
|--------------------|-----------------------------------|
| `HDMI-A-2` | `HDMI-2` |
| `DP-1` | `DP-1` (matches — no issue) |

## Root Cause (Inference)

The HD/CRT Mode Switcher is likely reading the output name from the DRM layer (e.g. `/sys/class/drm/*/status` or a similar source) rather than from `batocera-resolution listOutputs`. On some AMD GPUs the DRM layer uses `HDMI-A-X` naming while xrandr normalizes it to `HDMI-X`.

## What Needs Fixing in CRT Script

The mode switcher should source HD output names from `batocera-resolution listOutputs` (or `DISPLAY=:0 xrandr --query`) rather than from DRM connector enumeration. This ensures the name written to `batocera.conf` always matches what ES validation expects.

## Affected Scope

- Confirmed on: AMD Navi 32 (RX 7700/7800 XT)
- Not affected: DP outputs on same machine
- Unknown: whether Intel or Nvidia GPUs have the same mismatch

## Fix Applied (April 2, 2026)

Added `drm_name_to_xrandr()` normalization to `02_hd_output_selection.sh`. The function converts DRM sysfs connector names to xrandr format before they enter the output arrays:

```bash
drm_name_to_xrandr() {
    local name="$1"
    case "$name" in
        HDMI-[A-Z]-*) echo "HDMI-${name#HDMI-?-}" ;;
        *)            echo "$name" ;;
    esac
}
```

The pattern `HDMI-[A-Z]-*` covers both kernel-defined HDMI connector types (`DRM_MODE_CONNECTOR_HDMIA` = `HDMI-A` and `DRM_MODE_CONNECTOR_HDMIB` = `HDMI-B`, per `drm_connector_enum_list` in `drm_connector.c`). `HDMI-B` (dual-link, HDMI 1.0 spec) is essentially nonexistent in hardware but is defined in the kernel enum. All other connector types (DP, DVI-I/D/A, VGA, eDP, LVDS) match between DRM sysfs and xrandr -- no normalization needed.

Applied in `scan_xrandr_outputs()` after extracting the name from the sysfs path and before adding to `ALL_OUTPUTS`/`CONNECTED_OUTPUTS`. DRM sysfs is still used for enumeration (xrandr cannot see inactive outputs in CRT mode), but names are normalized so `batocera.conf` always gets xrandr-format values.

The mapping is the inverse of the alias logic in `map_xrandr_to_drm()` (Batocera-CRT-Script-v43.sh line 1842-1849) and matches what `log_drm_map_snapshot()` documents as the xrandr candidate for HDMI-A connectors.

## Hardware Verification (April 2, 2026)

Updated file deployed via FileZilla. Mode switcher run to switch to CRT mode. SSH verification:

```
$ cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
global.videooutput=HDMI-2

$ cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
global.videooutput=DP-1

$ grep videooutput /userdata/system/batocera.conf
global.videooutput=DP-1
global.videooutput2=none
```

HD backup now correctly shows `HDMI-2` (xrandr format) instead of the previous `HDMI-A-2` (DRM format). CRT backup (`DP-1`) was unaffected as DP names match between DRM and xrandr.

**Status:** Fixed. Committed as `1c01262` on `crt-hd-mode-switcher-v43`.
