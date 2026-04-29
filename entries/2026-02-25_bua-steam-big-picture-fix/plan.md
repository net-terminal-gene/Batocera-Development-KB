# BUA Steam Big Picture Fix

## Agent/Model Scope

Composer + batocera-unofficial-addons repo. Source: [HOW-TO] Fix Steam Big Picture Mode in Batocera PDF (Steam black screen / returns to menu when launching from EmulationStation).

## Build Nomenclature (teammate clarification)

| Component   | Old build     | Latest build   |
|------------|---------------|----------------|
| Installer  | `steam.sh`    | `steam2.sh`    |
| Launcher   | `Launcher`    | `Launcher2`    |

- The BUA installer uses `steam2.sh` → downloads `Launcher2` to `/userdata/system/add-ons/steam/Launcher`.
- A prior merged PR accidentally changed the old build (`steam.sh` / `Launcher`) instead of the latest (`steam2.sh` / `Launcher2`).
- Reports mention Launcher and Launcher2 separately; both exist in the repo.

## Problem

Steam Big Picture Mode launched from Batocera EmulationStation either returns immediately to the menu or shows a black screen with a mouse cursor. Launching via SSH works fine.

**Hardware scope (teammate validation):**
- **Issue reproduced:** Ryzen CPU + AMD GPU only.
- **Works without issues:** Intel + Nvidia, Intel no GPU, Steam Deck (confirmed).
- **Untested / uncertain:** Ryzen + Nvidia.

## Root Cause

Three issues identified in the PDF:

1. **Missing XAUTHORITY** — wmctrl cannot connect to X11 without `XAUTHORITY`; fails with "Cannot open display", times out, returns to menu
2. **Localized window title** — Launcher searches for "Steam" only; Big Picture window in German (and other locales) is titled "Big-Picture-Modus"
3. **Wrong GPU on dual-GPU** — Steam defaults to iGPU; rendering fails, Steam exits after ~13 seconds (optional/configurable fix)

## Solution

**Primary target: `Launcher2`** (latest build; used by `steam2.sh` via installer). Launcher (old) may be fixed for completeness if both builds remain in use.

| Change | File | Effort |
|--------|------|--------|
| Add `export XAUTHORITY=/var/run/xauth` | `steam/extra/Launcher2` | 1 line |
| Broaden wmctrl regex to match localized titles: replace `grep -qi "Steam"` with `grep -qiE "Steam|Big.Picture|Big-Picture"` in both wait loop and monitor loop | `steam/extra/Launcher2` | 2 replacements |
| (Launcher2 already has RIM_ALLOW_ROOT, HOME, TIMEOUT=240, lbfix.sh) | — | — |
| **Launcher (old build)** — same fixes if still served: XAUTHORITY, RIM_ALLOW_ROOT, HOME, broaden regex, TIMEOUT=240 | `steam/extra/Launcher` | Optional |
| DRI_PRIME config (optional / deferred) — config file or auto-detect for dual-GPU; doc-only if not implemented | TBD | Medium |
| Hide ES / fullscreen Steam (optional / deferred) — PDF has these; `wmctrl -r "Big-Picture"` fails on localized titles, would need broader match | `steam/extra/Launcher2` | Low–medium |

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/Launcher2` | Add XAUTHORITY; broaden wmctrl regex (2 places) |
| batocera-unofficial-addons | `steam/extra/Launcher` | Optional: same fixes if old build still in use |

## Out of Scope (this iteration)

- **lbfix.sh** — Launcher2 invokes it; Launcher does not. Not in PDF fix; leave as-is.
- **DRI_PRIME** — Deferred unless dual-GPU users report; config file approach if needed later.
- **Hide ES / fullscreen** — Deferred; requires localized wmctrl match if we add it.

## Validation

- [ ] Launch Steam Big Picture from Ports menu — does not return immediately to menu
- [ ] Steam Big Picture displays (no black screen)
- [ ] Test on German (or other non-English) Batocera locale — window detection works
- [ ] On Ryzen + AMD dual-GPU systems: verify Steam uses dGPU (or document DRI_PRIME config) — primary repro config
- [ ] Regression check: Intel+Nvidia, Intel no GPU, Steam Deck (teammate confirms these work; verify after changes)

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

