# Research — BUA Steam Big Picture Fix

## Source Document

[HOW-TO] Fix Steam Big Picture Mode in Batocera — PDF dated February 2026. Tested on Batocera 42, AMD Renoir iGPU + RX 6600 XT.

## Three Root Causes (from PDF)

### Issue 1 — Missing XAUTHORITY

- **Symptom:** Launcher uses wmctrl to detect Steam window; wmctrl fails with "Cannot open display"
- **Cause:** XAUTHORITY not set when Launcher runs from EmulationStation context
- **Effect:** wmctrl -l returns error; Launcher waits 240s timeout, exits, Batocera returns to menu
- **Fix:** `export XAUTHORITY=/var/run/xauth`

### Issue 2 — Wrong GPU (dual-GPU systems)

- **Symptom:** Steam renders on iGPU, fails silently after ~13 seconds
- **Cause:** Steam's `default_gpu_id: 1` picks integrated GPU; dedicated GPU not used
- **Evidence:** `/userdata/system/add-ons/steam/.local/share/Steam/logs/console-linux.txt`
- **Fix:** `export DRI_PRIME=pci-0000_12_00_0` — PCI slot is hardware-specific

**Finding PCI slot:**
```bash
cat /sys/class/drm/card0/device/device   # device ID
cat /sys/class/drm/card1/device/device   # compare to find dGPU
cat /sys/class/drm/cardN/device/uevent | grep PCI_SLOT_NAME
```

### Issue 3 — Localized window title

- **Symptom:** Launcher searches for window titled "Steam"; never finds it
- **Cause:** In German, Big Picture window is titled "Big-Picture-Modus"
- **Effect:** wmctrl times out after 240s, returns to menu
- **Fix:** `wmctrl -l | grep -qiE "Steam|Big.Picture|Big-Picture"`

## Current BUA Launcher Analysis

**File:** `batocera-unofficial-addons/steam/extra/Launcher` (old build)

| Fix | Status |
|-----|--------|
| XAUTHORITY | ❌ Missing |
| RIM_ALLOW_ROOT, HOME | ❌ Missing (Launcher2 has these) |
| DRI_PRIME | ❌ Missing |
| Localized window regex | ❌ Uses `grep -qi "Steam"` only |

**File:** `batocera-unofficial-addons/steam/extra/Launcher2` (latest build) — **FIXED**

| Fix | Status |
|-----|--------|
| XAUTHORITY | ✅ Added |
| RIM_ALLOW_ROOT, HOME | ✅ Present |
| DRI_PRIME | ❌ Missing (deferred) |
| Localized window regex | ✅ `grep -qiE "Steam|Big.Picture|Big-Picture"` |

**Deployment:** `steam2.sh` (BUA installer) downloads Launcher2 from GitHub to `/userdata/system/add-ons/steam/Launcher`. `steam.sh` (old build) downloads Launcher.

## PDF Working Script Additions

The PDF's "Working Launcher Script" also includes:

- Hide EmulationStation: `wmctrl -r EmulationStation -b add,hidden 2>/dev/null || true`
- Bring Steam fullscreen: `wmctrl -r "Big-Picture" -b add,fullscreen` and `wmctrl -a "Big-Picture"`

**Caveat:** `wmctrl -r "Big-Picture"` uses a fixed title — would fail on localized systems. If implemented, would need a broader match or different approach.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

