# Proposed ES CRT settings — manual setup (replacing auto)

**Status:** Recommendation to hippos-linux maintainer (2026-06-15). Not implemented.

## Rationale

- **`crt.enabled=auto` is not reliable** for DP + DAC, dual-head, or EDID edge cases.
- The OS **cannot detect a DAC** or distinguish “CRT DisplayPort” vs “HD DisplayPort” — only connected + EDID heuristics (see `research/auto-detect-limits.md`).
- Batocera CRT Script uses **explicit installer choices** (output, profile). HippOS should expose the same intent in ES, not guess.

**Conclusion:** Drop auto as the primary path. Default fresh flash to **`crt.enabled=false`**. User configures CRT explicitly in System Settings.

## Proposed menu structure

```
System Settings
  CRT
    ENABLE CRT
    CRT VIDEO OUTPUT      ← new (maps to crt.output)
    MONITOR PROFILE       ← exists today
    BOOT RESOLUTION       ← new (maps to crt.boot_resolution)
```

All changes that affect boot (enable, output, profile, boot resolution) → **`exitreboot`** prompt on save (same pattern as current CRT toggle).

### Field mapping

| ES label | hippos.conf key | Notes |
|----------|-----------------|-------|
| ENABLE CRT | `crt.enabled` | `true` / `false` only (no `auto` in UI) |
| CRT VIDEO OUTPUT | `crt.output` | Picker: connected DRM connectors (`DP-1`, `HDMI-A-1`, …) |
| MONITOR PROFILE | `crt.monitor_profile` | Existing list (`generic_15`, `arcade_15_25_31`, …) |
| BOOT RESOLUTION | `crt.boot_resolution` | Profile-filtered list; see below |

Help text under **CRT VIDEO OUTPUT:** *“If using a DisplayPort or HDMI to VGA adapter, select the port the adapter is plugged into.”*

### Boot resolution UX

Choices **filter by selected MONITOR PROFILE** (do not offer 31 kHz boot on `generic_15`-only profile).

**Example — `arcade_15_25_31` (multisync):**

| UI label (example) | Meaning |
|--------------------|---------|
| 640×480i @ 15 kHz | Interlaced menu at 15 kHz band |
| 640×480i @ 25 kHz | Interlaced menu at 25 kHz band |
| 640×480i @ 31 kHz | Interlaced menu at 31 kHz band |
| 640×480p @ 15 kHz | Progressive menu at 15 kHz |
| 640×480p @ 25 kHz | … |
| 640×480p @ 31 kHz | … |
| 768×576i @ 15/25/31 kHz | PAL-style base modes where profile allows |

**Example — `generic_15`:**

| UI label |
|----------|
| 640×480i @ 15 kHz |
| 640×480p @ 15 kHz |
| 768×576i @ 15 kHz |

Implementation note: UI labels are human-readable; stored values must match what `hippos-crt-setup` / switchres already consume (e.g. `640x480i` + profile ranges, or an extended encoding TBD). **Generate lists from videomodes/switchres data**, not hardcoded strings in ES.

`i` vs `p` in boot choice replaces hidden `crt.interlace` for menu/boot purposes.

## What this does not fix alone

Pipeline work still required so **first reboot after save** applies CRT correctly:

1. Run `hippos-crt-setup` from `hippos-xorg-setup` (before X).
2. Skip `xrandr --auto` in `hippos-xserver` when CRT enabled.
3. Fix switchres apply segfault (in-game mode switching).
4. DCN `interlace_force_even` detection.

UI + pipeline together = complete user journey.

## ES code touchpoints

| Area | Path |
|------|------|
| Current CRT group (2 items) | `src/frontend/emulationstation/es-app/src/guis/GuiMenu.cpp` ~1880 |
| Output list API | `hippos-resolution listOutputs` |
| Boot mode list (new script?) | e.g. `hippos-resolution listCrtBootModes --profile=…` |

## Relation to Phase 1 workaround

Validated operator path today:

```bash
hippos-settings set crt.enabled true
hippos-crt-setup && reboot
```

Proposed ES section replaces manual `hippos.conf` / SSH with the same four keys, one reboot prompt.
