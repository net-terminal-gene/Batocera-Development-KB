# Research — CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

## Findings (lab, 2026-07-22)

### Hardware / OS

- Batocera CRT kernel (`BOOT_IMAGE=/crt/linux`), dual-boot syslinux: `LABEL batocera` (HD Wayland) + `LABEL crt` (X11).
- GPUs: NVIDIA RTX 3090 `21:00.0` + AMD Navi 32 (7800 XT) `4a:00.0` (Xorg BusID `PCI:74:0:0`).
- CRT via AMD DP through Switchres EDID `ms929.bin`; ultrawide ASUS VG34V also connected.

### Failure sequence

1. CRT Script configured `DP-5`, EDID `drm.edid_firmware=DP-5:edid/ms929.bin`, `global.videooutput=DP-5`.
2. Skipped `boot-custom.sh` because proprietary NVIDIA detected.
3. Boot: AMD CRT path OK; X also brought up NVIDIA as `modeset(G0)` → `Failed to create pixmap` → fatal → no ES.
4. Console left showing BUA `symlink_manager` watch loop ("Symlink creation pass completed") — red herring.

### Blacklist behavior

| Mechanism | Result |
|-----------|--------|
| `modprobe.blacklist=nvidia,...` on CRT APPEND | Present in cmdline but NVIDIA modules **still loaded** (`S05nvidia` / `batocera-nvidia` force-load) |
| `module_blacklist=nvidia,nvidia_modeset,nvidia_drm,nvidia_uvm` | NVIDIA modules **gone**; X + ES start |

### Connector renumber (post `module_blacklist`)

| Before (both GPUs in DRM) | After (AMD only) |
|---------------------------|------------------|
| `card1-DP-5` CRT | `card0-DP-2` CRT |
| `card1-DP-4` etc. | `card0-DP-1` ultrawide |
| NVIDIA `card0-*` | absent |

Symptom when names not updated: ES on `DP-1` (ultrawide) at 641x480; CRT dark. After retarget to `DP-2` + `641x480i` @ 15.7 kHz, ES visible on CRT.

### Batocera hooks that matter

- `/etc/init.d/S05nvidia` → `batocera-nvidia auto` when `nvidia-driver` not false.
- `/etc/init.d/S30checkprime` can still treat NVIDIA PCI as "primary GPU" even with modules blacklisted (lspci still sees device).
- Soft blacklist ≠ hard `module_blacklist`.

### Installer implication

Any connector string chosen **while NVIDIA is still in DRM** is unsafe to persist if CRT boot will isolate NVIDIA. Script must either rescan after isolation or bind by stable attributes (PCI BusID + relative connector) and rewrite names after first CRT boot.
