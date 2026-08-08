# CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

## Agent/Model Scope

Composer + `ssh-batocera`; CRT Script installer changes in `Batocera-CRT-Script-v43.sh` / related boot helpers. Manual recovery already validated on live hardware (2026-07-22).

## Problem

Users with two GPUs (typical: AMD for CRT + NVIDIA for Windows/HD) hit a boot failure or black screen after running the CRT Script:

1. **X crash:** Batocera still loads proprietary NVIDIA via `S05nvidia` / `batocera-nvidia`. X initializes AMD CRT successfully, then adds NVIDIA as `modeset(G0)` and dies with `Failed to create pixmap`. ES never starts; console shows BUA `symlink_manager` spam ("Symlink creation pass completed").
2. **Connector renumber after fix:** Soft `modprobe.blacklist` is not enough (Batocera force-loads NVIDIA). Hard `module_blacklist=` on the CRT syslinux entry stops NVIDIA modules, but AMD DRM connector names change (e.g. `DP-5` → `DP-2`). Installer-written `drm.edid_firmware=DP-5:...`, `video=DP-5:e`, and `global.videooutput=DP-5` then point at a dead name. ES falls back to another connected display (ultrawide) → CRT black screen even though ES is "running".

Windows on another drive must remain unaffected (CRT-boot-only changes).

## Root Cause

| Layer | Cause |
|-------|--------|
| X dual-GPU | X AutoAddGPU + NVIDIA DRM present → fatal `modeset(G0)` |
| Soft blacklist | `modprobe.blacklist=` does not stop explicit `batocera-nvidia` / `modprobe` |
| Renumber | With NVIDIA unbound, AMD becomes sole DRM card; connector indices shift |
| Installer order | CRT Script currently binds EDID/videooutput to connector names **before** any dual-GPU isolation, so names are unstable |

Related: CRT Script already **skips** `boot-custom.sh` when proprietary NVIDIA is detected, which left this dual-GPU X path unhandled.

## Solution

Proposed CRT Script strategy (installer-time, CRT LABEL only):

1. **Detect clash** — 2+ VGA/3D PCI GPUs, and CRT output is on a non-NVIDIA GPU while NVIDIA proprietary modules/drivers are present (or will be loaded by Batocera).
2. **Apply CRT-only isolation** on `LABEL crt` `APPEND` in all syslinux copies:
   - `module_blacklist=nvidia,nvidia_modeset,nvidia_drm,nvidia_uvm`
   - Optional Xorg overlay: `AutoAddGPU false` + AMD `BusID` Device/Screen (belt-and-suspenders).
3. **Do not finalize connector names yet** — either:
   - **A (preferred if feasible):** Stage blacklist, instruct power cycle into CRT kernel with isolation, then **Phase-2 rescan** DRM/xrandr and write EDID/`video=`/`global.videooutput`/`10-monitor.conf` against post-blacklist names; or
   - **B:** Predict renumber by filtering DRM to CRT GPU card only (ignore NVIDIA `cardN`) and map by PCI BusID + connector type/status before writing; validate after first CRT boot.
4. **Ignore non-CRT outputs** on the CRT GPU (and any leftover NVIDIA-named outputs) in `10-monitor.conf`.
5. **Never touch** HD `LABEL batocera` / Windows / BIOS.
6. **Document** dual-GPU path in installer UI + wiki (power cycle required; ultrawide may stay plugged for HD boot).

Open design choice: A (rescan after reboot) vs B (predict card-local names). User preference leans A: update boot, then rescan so DP-5→DP-2 cannot poison configs.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Dual-GPU detect; CRT APPEND `module_blacklist`; defer/rescan connector bind |
| Batocera-CRT-Script | `etc_configs/Monitors_config/10-monitor.conf` (generator) | Post-rescan Ignore/primary |
| Batocera-CRT-Script | `UsrBin_configs/boot-custom.sh` (or new helper) | Possibly AMD-only Xorg even when NVIDIA present |
| Batocera-CRT-Script | syslinux APPEND helpers | CRT-only params; leave HD entry alone |
| (live, already applied) | `/boot/.../syslinux.cfg`, `/etc/X11/xorg.conf.d/05-amd-only.conf`, `batocera.conf` | Manual recovery on lab machine |

## Validation

- [ ] Dual-GPU AMD+NVIDIA: CRT boot → ES on CRT, no `modeset(G0)`, no symlink console loop
- [ ] After installer path: `global.videooutput` matches live CRT connector (post-blacklist name)
- [ ] `drm.edid_firmware` / `video=` match same connector; Switchres/`ms929` (or chosen) EDID on CRT
- [ ] Active mode is 15 kHz interlaced when profile requires it (`641x480i` etc.), not progressive on CRT
- [ ] HD `LABEL batocera` still loads NVIDIA / unaffected
- [ ] Windows on other drive unaffected
- [ ] Single-GPU machines: no behavior change (no blacklist, no extra reboot phase)
