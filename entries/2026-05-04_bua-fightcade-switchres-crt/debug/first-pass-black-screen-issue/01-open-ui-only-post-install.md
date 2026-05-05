# 01 — Open Fightcade UI only (post-install)

**Date:** 2026-05-04  
**Purpose:** First checkpoint after wrapper + Ports script were deployed on the device.

## Captured

- Fightcade launched from Ports; **no TEST GAME / online** yet (baseline before step 2–3 retest).

## Display snapshot (SSH, Fightcade UI open only)

Recorded immediately after user relaunch; `DISPLAY=:0.0`:

| Query | Value |
|-------|--------|
| `batocera-resolution currentMode` | `641x480.59.98` |
| `batocera-resolution currentResolution` | `641x480` |
| `batocera-resolution getDisplayMode` | `xorg` |

Use this row as the **menu baseline** when comparing after game exit / restore tests.
