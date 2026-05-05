# 20 — `--rmmode` fix: second TEST GAME black screen resolved

**Status:** Fix confirmed by user testing. Second TEST GAME, ES round-trip, and cross-game launches all produce picture.

---

## Root cause (confirmed from `fightcade.log`)

Entry **`18`** added `xrandr --delmode` to strip SR-* modes before each `switchres -s -k`. This detaches the mode from the output but **does not destroy the mode object** from the RandR server. On the second TEST GAME, Switchres calls `XRRCreateMode` / `XRRAddOutputMode` and finds the stale mode object still in the server pool:

```text
Switchres: Calculating best video mode for 384x224@59.599491 orientation: normal
Switchres: Modeline "384x224_59 15.495868KHz 59.599491Hz" 7.840909 384 415 452 506 224 234 237 260   -hsync -vsync
XRANDR: <1> (add_mode) [WARNING] mode already exist (duplicate request)
```

Switchres skips CRTC activation after the duplicate warning [Inference]. The output stays on menu timing (641x480) while Wine launches at game resolution (384x224). CRT receives wrong timing or no sync. Result: black screen.

## Fix applied

One line added to `fightcade_drop_stale_switchres_modes` in `switchres_fightcade_wrap.template.sh`:

```bash
xrandr --delmode "$out" "$m" 2>/dev/null || true
xrandr --rmmode "$m" 2>/dev/null || true   # <-- NEW: destroy mode object from X server
```

`--delmode` detaches the mode from the output. `--rmmode` destroys the mode object from the RandR server entirely. Next `switchres -s -k` creates a fresh mode without duplicate warning.

Also changed `switchres` stderr from `2>/dev/null` to `2>&1` so errors appear in `fightcade.log`.

## Mandatory bundle

### Pre-test baseline (fresh reboot, no Fightcade)

```text
=== XRANDR ===
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00*
```

No SR-* modes present. Clean state.

### `fightcade.log` — second launch duplicate warning (pre-fix, from entry 18 session)

```text
Switchres: Calculating best video mode for 384x224@59.599491 orientation: normal
Switchres: Modeline "384x224_59 15.495868KHz 59.599491Hz" 7.840909 ...
XRANDR: <1> (add_mode) [WARNING] mode already exist (duplicate request)
```

### Deployed wrapper verification (post-fix)

```text
$ grep -n rmmode /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh
298:            xrandr --rmmode "$m" 2>/dev/null || true
```

### Live state during KOF98 TEST GAME (post-fix, user confirmed picture)

```text
=== XRANDR ===
Screen 0: minimum 320 x 200, current 320 x 224, maximum 16384 x 16384
DP-1 connected primary 320x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_320x224@59.19  59.19*

=== PROCS ===
17651 /bin/bash .../bin/xdg-open fcade://play/fbneo/kof98
17653 /bin/bash .../extra/switchres_fightcade_wrap.sh fcade://play/fbneo/kof98
17858 .../usr/bin/wine .../fbneo/fcadefbneo.exe kof98
17887 .../fbneo/fcadefbneo.exe kof98
```

SR-1_320x224@59.19 is active (starred). Correct native resolution for KOF98.

## Test results (user confirmed)

| Scenario | Result |
|----------|--------|
| SF3 TEST GAME (first launch) | Picture, 384x224@59.60 |
| SF3 TEST GAME (repeated, same session) | Picture, no black screen |
| Exit Fightcade to ES, relaunch, TEST GAME | Picture, no black screen |
| KOF98 TEST GAME (different game, different resolution) | Picture, 320x224@59.19 |

All four failure modes from entries **`07`**, **`13`**, **`17`** are resolved.

## What changed vs entry 18

Entry 18 added `--delmode` only. This entry adds `--rmmode` after `--delmode`, which is the actual fix. `--delmode` alone was insufficient because the mode object persisted in the RandR server, causing Switchres to hit the duplicate `add_mode` path on the next launch.

---

## Related

- **`13-test-game-black-screen-bug-round-trip.md`** — first documentation of ES round-trip black screen
- **`17-test-game-black-screen-after-reassert-fix.md`** — reassert fix insufficient, duplicate `add_mode` still occurs
- **`18-ssh-recovery-and-delmode-fix-applied.md`** — `--delmode` fix (incomplete, see this entry)
