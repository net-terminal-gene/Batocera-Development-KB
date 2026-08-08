# VERDICT — CRT SF6 / ms929 Display Mode Parity

## Status: TBD

## Summary

BC-250 golden reference fully documented (live SF6 audit). RX 7700 XT box still not at visual parity. Root cause identified with evidence: SF6 display-mode index against a junk XRandR mode list. Fix not yet shipped on the bad machine.

## Plan vs reality

Documentation and diagnosis complete. Implementation Phase B (mode allowlist / Switchres parity) not completed on the 7700 box in this session.

## Root Causes

1. On the 7700 CRT box, X exposes many sub-640 modes; SF6 `FullScreenDisplayMode=0` maps to **320×180** (or similar), then stretches — soft image; in-game resolution UI appears inert when the game keeps rewriting the index.
2. BC-250 exposes only three X modes; index `0` = **640×480** with borderless **854×480** window — sharp.
3. Quality-preset matching and Flatpak Steam alone do not fix (1).

## Changes Applied

| Item | Change |
|------|--------|
| KB entry | This documentation set + raw BC-250 audit |
| 7700 box | Prior session: config thrash, later restore toward CRT DP-retarget backup; launcher force/watch hooks may remain — not a complete fix |

## What worked / what didn’t

| Worked | Didn’t |
|--------|--------|
| Side-by-side host audit | sed-only mode index |
| Identifying xrandr vs listModes | ES 854 forcing / kill loops |
| Confirming identical game build | Assuming GPU fillrate was the issue |

## Next session entry point

1. Power on `batocera.local`.
2. Follow `plan.md` Phase A → B.
3. Stop when validation checklist in `plan.md` is green.
4. Close this VERDICT to **FIXED** with post-fix `rx7700` audit attached.
