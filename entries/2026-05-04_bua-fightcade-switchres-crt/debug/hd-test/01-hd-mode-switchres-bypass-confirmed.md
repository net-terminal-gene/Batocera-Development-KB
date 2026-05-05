# HD mode — Switchres bypass confirmed + PAL threshold fix

**Date:** 2026-05-04  
**Game:** Street Fighter III: 3rd Strike (`sfiii3nr1`)  
**Modes tested:** HD (1920x1080), CRT PAL (769x576)

---

## Test objective

1. Verify that Switchres does NOT activate when Fightcade runs in HD mode.
2. Verify that Switchres DOES activate when running on a PAL CRT (576i).

## Environment

- x86_64, X11-only build (no Wayland)
- `batocera-resolution getDisplayMode` → `xorg` (same in both CRT and HD)

## Gate evaluation

`fightcade_should_use_switchres()` checks:

| Gate | Check | HD (1920x1080) | CRT NTSC (641x480i) | CRT PAL (769x576) |
|------|-------|----------------|---------------------|-------------------|
| Line 24 | `switchres` present | Yes | Yes | Yes |
| Line 26 | `.disable` file | No | No | No |
| Line 29 | `displayMode == xorg` | Yes (passes) | Yes (passes) | Yes (passes) |
| Line 39 | `width < 1024` | 1920 >= 1024 **BLOCKED** | 641 < 1024 OK | 769 < 1024 OK |

## Bug found: PAL CRT blocked by original threshold

Original threshold was `< 720`. PAL CRT menu resolution is **769x576** (width 769 >= 720), which caused Switchres to be bypassed on PAL CRTs.

**Fix:** Threshold changed from `720` to `1024`.

Width ranges:
- CRT game modes: 320-640 (always under 1024)
- CRT NTSC menu: 641 (under 1024)
- CRT PAL menu: 769 (under 1024)
- HD minimum: 1280 (over 1024)

Clean separation between CRT (max 769) and HD (min 1280) with 1024 threshold.

## Verification — HD mode (1920x1080)

```
=== Fightcade UI open ===
Screen 0: current 1920 x 1080
No wrapper process, no SR-1 modes

=== TEST GAME launched (sfiii3nr1) ===
Screen 0: current 1920 x 1080 (unchanged)
No switchres_fightcade_wrap.sh process
FBNeo running: fcadefbneo.exe sfiii3nr1 (via direct fcade.sh pass-through)
```

PASS: Switchres correctly bypassed in HD mode.

## Verification — CRT PAL mode (769x576)

```
=== Before fix (threshold 720) ===
Menu: 769x576 (width 769 >= 720 → Switchres bypassed)
TEST GAME launched at menu resolution, no SR-1 mode

=== After fix (threshold 1024) ===
Menu: 769x576 (width 769 < 1024 → Switchres activated)
SR-1_384x224@59.60 *current
Wrapper running: switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
```

PASS: Switchres correctly activated on PAL CRT after threshold fix.

## Note for X11-only builds

On X11-only builds, the `getDisplayMode` check provides no CRT/HD discrimination (always returns `xorg`). The width check is the sole effective guard. The `xorg` gate only protects on dual-boot Wayland/X11 systems (v43+).
