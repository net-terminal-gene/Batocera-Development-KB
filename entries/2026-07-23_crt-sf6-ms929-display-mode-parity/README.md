# CRT SF6 / ms929 Display Mode Parity (BC-250 vs RX 7700 XT)

**Session:** `2026-07-23_crt-sf6-ms929-display-mode-parity`
**Status:** TBD — BC-250 golden reference captured; RX 7700 box not fixed
**Primary repo:** machine config / launcher (BUA Steam + CRT Script); not a PR yet
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Street Fighter 6 looks sharp on an AsRock **BC-250** Batocera CRT box (ms929 scaler) and soft/pixelated on a dual-GPU **RX 7700 XT** Batocera CRT box with the same game build and similar quality settings. Exhaustive audit of the good machine shows SF6’s only graphics store is `config.ini`, and the decisive difference is **which display modes the OS exposes to the game**: BC-250 shows three modes so `FullScreenDisplayMode=0` means **640×480**; the 7700 box exposes dozens of junk modes so index `0` means **320×180**. Goal: make the 7700 box match BC-250 mode enumeration (and Steam/Proton path where needed) without further ES/display thrash.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, root cause, fix plan, validation |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links (none yet) |
| [research/bc250-golden-reference.md](research/bc250-golden-reference.md) | Live dump of perfect SF6 stack |
| [research/rx7700-broken-state.md](research/rx7700-broken-state.md) | What we measured on the bad box |
| [research/bc250-sf6-full-audit.out](research/bc250-sf6-full-audit.out) | Raw 756KB audit from BC-250 |
| [design/](design/) | Target architecture / fix flow |
| [debug/](debug/) | Pass/fail checks and failure signs |

Related prior session (dual-GPU DP rename): `entries/2026-07-22_crt-dual-gpu-clash-boot-rescan/`.
