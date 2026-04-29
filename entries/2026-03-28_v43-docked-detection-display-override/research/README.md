# Research — v43 Docked Detection Display Override

## Key Commits

### Upstream batocera.linux (the problem)

**`d9b1d23bfc`** — "fix docked output" (March 13, 2026, dmanlfc)
- Introduced `_detect_docked_output()` in `batocera-switch-screen-checker`
- Added `DOCKED_FLAG="/var/run/batocera-docked"`
- Logic: read configured outputs, compare against connected, flag unknowns as docked
- Also updated `emulationstation-standalone` to read the flag and override output

**`aca5e9c751`** — "properly turn off other displays when external connected / docked" (March 14, 2026, dmanlfc)
- Refined: if no configured outputs, fall back to status file as baseline
- Also: when docked at init, write only docked output to status file

### CRT Script (ported the same logic)

**`4fce0e9`** — PR #405 (March 18, 2026, ZFEbHVUE)
- Ported docked detection into `emulationstation-standalone-v43_ZFEbHVUE-MultiScreen`
- Code is nearly line-for-line identical to upstream

**`cbdcc04`** — "Merge upstream/main into crt-hd-mode-switcher-v43" (March 28, 2026)
- Brought the logic into the `crt-hd-mode-switcher-v43` branch

## How the Bug Manifests

`batocera-switch-screen-checker` is triggered by:
```
ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="/bin/bash /usr/bin/batocera-switch-screen-checker-delayed"
```

This fires on any DRM hotplug event on any hardware — no platform guard.

When a second display is connected on a PC or Steam Deck:
1. udev fires the checker
2. `_detect_docked_output()` reads `global.videooutput=HDMI-2`, `global.videooutput2=none`
3. `batocera-resolution listOutputs` returns both `HDMI-2` and `DP-1`
4. `DP-1` is not in known outputs → written to `/var/run/batocera-docked`
5. On ES restart, `emulationstation-standalone` reads flag → calls `batocera-resolution setOutput DP-1` → HDMI-2 goes blank

## The Fix (dmanlfc, not yet on GitHub as of March 28)

Inverted the guard in `_detect_docked_output()`:

```bash
# If the user has explicitly configured video outputs, docked mode
# detection must not run — it would override their configuration.
if [ -n "${KNOWN_OUTPUTS}" ]; then
    echo "Checker: Explicit video outputs configured (${KNOWN_OUTPUTS}). Skipping docked detection." >> "$LOG"
    rm -f "${DOCKED_FLAG}"
    return 0
fi
```

Docked detection now ONLY runs when zero outputs are configured — the genuine handheld/dock use case.

## Build System Scope

`batocera-switch-screen-checker` is installed unconditionally in `batocera-scripts.mk` with no `ifeq` guards. Affects all builds: x86 PC, Steam Deck, ARM (Raspberry Pi, etc.).

## Version Scope

- **v42**: Not affected. No docked detection commits in v42. v42 `emulationstation-standalone` in CRT script has no docked flag logic.
- **v43**: Affected on all hardware from March 13 onward.

## Secondary Finding: DRM vs xrandr Output Name Mismatch

DRM connector names (from `/sys/class/drm/*/status`) use format `HDMI-A-2`.
xrandr and `batocera-resolution listOutputs` use format `HDMI-2`.

On some AMD GPUs these differ. The CRT script wrote the DRM name (`HDMI-A-2`) to `batocera.conf`. ES validates against `listOutputs` (xrandr names), so `HDMI-A-2` is rejected as invalid.

**Live evidence from display.log:**
```
Standalone: Invalid output - HDMI-A-2
Standalone: First video output defaulted to - DP-1
```

## SSH Diagnostics Performed

### Steam Deck
- `global.videooutput=eDP-1`, `global.videooutput2=none`
- `/var/run/batocera-docked` contained `DP-1`
- EDID errors on DP-1: `[drm:dm_helpers_read_local_edid] *ERROR* EDID err: 2` (CRT has no EDID chip)
- Both eDP-1 and DP-1 showed as DRM `connected`

### PC (HP 705 G4 style, AMD RX 7700/7800 XT)
- `global.videooutput=HDMI-2`, no output2 set
- Plugging DP-1 → `/var/run/batocera-docked` immediately contained `DP-1`
- GPU: `Navi 32 [Radeon RX 7700 XT / 7800 XT]` — EDID intermittently failing on both DP ports
- After fix image: docked flag never written with configured outputs present

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

