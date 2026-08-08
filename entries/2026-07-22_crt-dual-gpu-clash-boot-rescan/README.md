# CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

**Session:** `2026-07-22_crt-dual-gpu-clash-boot-rescan`
**Status:** TBD
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

On a dual-GPU PC (AMD CRT GPU + discrete NVIDIA for Windows/Steam), the CRT Script can pick a connector name (e.g. `DP-5`) while both GPUs are visible, then X dies on NVIDIA `modeset(G0)` or, after NVIDIA is blacklisted for CRT boot, DRM renumbers the AMD connectors (`DP-5` → `DP-2`). EmulationStation then drives the wrong output (ultrawide) and the CRT goes black. Goal: handle this in the CRT Script by detecting a clash, applying a CRT-only boot blacklist, then rescanning connectors before writing EDID/`video=`/`global.videooutput`.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | Investigation notes and system findings |
| [design/](design/) | Architecture and flow |
| [debug/](debug/) | Test logs, repro steps, failure signs |

Authoritative detail lives in **VERDICT.md** and **pr-status.md** once work is done; **plan.md** shows original intent vs what shipped.
