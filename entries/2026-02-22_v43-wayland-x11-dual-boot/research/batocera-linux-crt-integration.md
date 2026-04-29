# batocera.linux — CRT Integration Architecture

**Date:** 2026-02-19
**Repo:** `/Users/mikey/batocera.linux` (X11 build)
**Companion to:** `x11-crt-stack-requirements.md`

---

## Overview

This document maps how switchres and the full CRT resolution-switching stack are integrated
into the batocera.linux Buildroot-based codebase. It covers every package that touches CRT
output — from the switchres binary itself through RetroArch, MAME, EmulationStation, and
the display management layer.

**Critical architectural fact:** switchres is auto-selected **only for X11 builds** and
explicitly excluded from Wayland builds. This is baked into the package system. This is
the definitive reason a separate X11 squashfs is required for CRT mode — the Wayland build
physically does not include switchres or any CRT modeline infrastructure.

---

## 1. switchres Package

**Location:** `package/batocera/utils/switchres/`

**Version:** 2.2.1
**Source:** `https://github.com/antonioginer/switchres` tag `v2.2.1`
**License:** GPL-2.0+

### What it builds

```
/usr/bin/switchres          ← standalone CLI tool
/usr/bin/grid               ← grid overlay tool (for CRT alignment)
/usr/bin/geometry           ← Python script wrapper for geometry adjustment
/usr/lib/libswitchres.so    ← shared library (used by RetroArch, MAME internally)
/usr/lib/libswitchres.so.2
/usr/lib/libswitchres.so.2.2.1
/etc/switchres.ini          ← default config file (monitor profile, crt_range, etc.)
```

### Build dependencies

- `libdrm` — DRM/KMS device access
- `sdl2`, `sdl2_ttf` — grid display tool
- `xserver_xorg-server` — required when X11 is enabled (for xrandr modeline injection)

### Auto-selection logic (`Config.in`)

```
select BR2_PACKAGE_SWITCHRES if !BR2_PACKAGE_BATOCERA_TARGET_BCM2835 \
                              && !BR2_PACKAGE_BATOCERA_WAYLAND
```

**Translation:** switchres is automatically included in every non-Raspberry Pi X11 build.
It is **not available** in Wayland builds. There is no manual selection needed — if it's
an X11 x86_64 build, switchres is in.

### switchres.ini (installed default)

The package installs a default `/etc/switchres.ini`. The Batocera-CRT-Script overwrites
this during Phase 2 installation with the user's selected monitor profile. Key fields:

```ini
monitor <PROFILE>          # generic_15, arcade_15, ntsc, pal, etc.
interlace_force_even 1     # 1 for AMD DCN (GCN 3.0+), 0 for DCE/older
dotclock_min 0             # 0 for AMD/NVIDIA, 25.0 for HDMI-only outputs
crt_range0 ...             # horizontal/vertical frequency bounds for this monitor
```

---

## 2. batocera-resolution Package

**Location:** `package/batocera/core/batocera-resolution/`

**Version:** 1.6
**Type:** Shell script — no compilation

### Variant selection

The package installs a different script variant depending on the build target:

| Condition | Variant installed |
|---|---|
| Default | `batocera-resolution.basic` |
| RPI_USERLAND | `batocera-resolution.tvservice` |
| LIBDRM (no Xorg) | `batocera-resolution.drm` |
| **XSERVER_XORG_SERVER** | **`batocera-resolution.xorg`** ← X11 builds |
| Wayland (sway) | `batocera-resolution.wayland-sway` |
| Wayland (labwc) | `batocera-resolution.wayland-labwc` |

### batocera-resolution.xorg (X11 variant — stock)

The stock X11 variant is a **pure xrandr wrapper**. It does NOT call switchres directly.

Key functions:

```bash
listModes       # xrandr --listModes — lists available modes on connected output
setMode         # xrandr --output <OUT> --mode <MODE> --rate <RATE>
currentMode     # queries current display mode
minTomaxResolution  # selects highest resolution ≥ 59Hz automatically
forceMode       # creates custom modeline using cvt + xrandr --newmode
setRotation     # xrandr rotation + touchscreen coordinate transform
listOutputs     # enumerates connected display outputs
setOutput       # selects which output to use
```

### Why the CRT Script replaces this binary

The stock `batocera-resolution.xorg` has no awareness of:
- `videomodes.conf` (the CRT mode database)
- switchres (it uses `cvt` for modelines, not the CRT-accurate switchres)
- Geometry parameters (`H_size`, `H_shift`, `V_shift`)
- CRT monitor frequency constraints
- Modeline cleanup (removing old switchres modelines before adding new ones)

The Batocera-CRT-Script installs a patched replacement that adds all of these. The patched
version calls `switchres ... -c` to generate accurate CRT modelines instead of `cvt`.

### Additional files installed by this package

- `/usr/bin/batocera-screenshot` — screenshot script
- `/etc/X11/xorg.conf.d/20-amdgpu.conf` — AMD GPU Xorg config (X11 builds)
  Copied from `board/batocera/x86/fsoverlay/`

---

## 3. RetroArch CRT Integration

**Location:** `package/batocera/emulators/retroarch/`

### Internal switchres (not the external binary)

RetroArch has its own embedded switchres implementation at `deps/switchres/` — a vendored
copy of the switchres library built directly into the RetroArch binary. RetroArch does
**not** call `/usr/bin/switchres`. It links against its own internal copy.

### Patches applied to RetroArch's switchres

**`006-drm-conn.patch`**
- Adds reading of `/var/run/drmConn` to select a specific DRM connector
- This allows Batocera to tell RetroArch's internal switchres which connector to use
  for CRT output (e.g., DVI-I vs HDMI vs DisplayPort)
- The CRT Script writes the correct connector name to `/var/run/drmConn`

**`021-switchres-kmsdrm-relax.patch`**
- Relaxes the dumb buffer support check in RetroArch's switchres KMS/DRM code
- Required for some GPU/driver combinations where the dumb buffer check incorrectly
  blocks CRT mode switching

### Build flags

```mk
--enable-kms     (if BR2_PACKAGE_LIBDRM)
--enable-x11     (if BR2_PACKAGE_XSERVER_XORG_SERVER)
```

### RetroArch CRT config (retroarch.cfg)

RetroArch's built-in CRT switching is controlled by these settings:

```
video_crt_switch_resolution = "1"    # enables CRT resolution switching
crt_switch_resolution = "1"          # alternate key (older versions)
```

When enabled, RetroArch calls its internal switchres before launching a core to
generate the correct modeline for that system's resolution and refresh rate.

### The /var/run/drmConn file

This file is the connector bridge between Batocera's CRT Script and RetroArch's internal
switchres. The CRT Script writes the selected CRT output's DRM connector name here during
installation. RetroArch's patched switchres reads it at launch to know which physical
output to target.

```bash
# Written by CRT Script during install:
echo "DVI-I-1" > /var/run/drmConn

# Read by RetroArch's patched switchres internally before mode switch
```

---

## 4. MAME / GroovyMAME CRT Integration

**Package location:** `package/batocera/emulators/mame/` (GroovyMAME variant)

### Built-in switchres (Switchres 2.21f)

MAME in Batocera uses GroovyMAME, which bundles Switchres 2.21f. Like RetroArch, MAME
does not call `/usr/bin/switchres` — it has its own internal copy linked at build time.

### How it's enabled (configgen — `mameGenerator.py`)

```python
if system.config.get_bool("switchres"):
    commandArray += [ "-modeline_generation" ]   # generate CRT modelines
    commandArray += [ "-changeres" ]             # switch resolution for each game
    commandArray += [ "-modesetting" ]           # use modesetting (not vendor DDX)
    commandArray += [ "-readconfig" ]            # read switchres.ini
```

MAME reads `/etc/switchres.ini` for the monitor profile. Setting the correct profile in
switchres.ini is therefore critical for MAME CRT output even though MAME has its own copy
of the switchres library.

### MAME-specific Xorg requirement

The `-modesetting` flag tells MAME's internal switchres to use the modesetting DDX driver
path for modeline injection. This is why `/etc/X11/xorg.conf.d/20-modesetting.conf`
(installed by the CRT Script) is essential — without it, MAME's modesetting path fails.

---

## 5. EmulationStation Display Management

**Location:** `package/batocera/emulationstation/batocera-emulationstation/`

### emulationstation-standalone script

This is the main launcher script, called by the X11 xinitrc on boot.

**Display setup sequence (before ES launches):**

```bash
1. batocera-resolution listOutputs      # find connected displays
2. batocera-resolution setOutput <OUT>  # select which output to use
3. batocera-resolution setMode <MODE>   # set resolution (from batocera-boot.conf es.resolution)
   OR
   batocera-resolution minTomaxResolution-secure  # auto-select max resolution
4. batocera-resolution setRotation <N>  # handle rotation if configured
5. → Launch EmulationStation binary
```

**EmulationStation itself does not call batocera-resolution.** It sets up the display before
launching, then hands off to the ES binary. Per-game mode switching is handled by emulators.

### X11 boot chain

```
UEFI/GRUB → kernel → init → S31emulationstation → startx
        → X11 server starts
        → /etc/X11/xinitrc.d/99batocera → xorg/xinitrc
        → openbox launched with emulationstation-standalone as startup command
        → emulationstation-standalone (display setup) → EmulationStation binary
```

### videoMode.py (configgen utility)

Location: `package/batocera/core/batocera-es-system/batocera-es-system/...`

Python module used by all configgen scripts:

```python
changeMode()           # calls batocera-resolution setMode
getCurrentMode()       # calls batocera-resolution currentMode
getRefreshRate()       # calls batocera-resolution currentRefreshRate
getScreensInfos()      # calls batocera-resolution screenInfos
```

Each emulator's configgen script imports this module. When an emulator is launched,
its configgen calls `changeMode()` which calls `batocera-resolution setMode <MODE_ID>`.
For the stock (non-CRT) build this uses xrandr. For CRT mode, the patched
`batocera-resolution` intercepts this call and routes it through switchres.

---

## 6. The Complete CRT Switching Picture

### Three parallel switchres implementations

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CRT Modeline Generation                          │
│                                                                     │
│  /usr/bin/switchres          ← Called by patched batocera-resolution│
│  (switchres package v2.2.1)      for all non-MAME, non-RA emulators │
│                                                                     │
│  RetroArch deps/switchres    ← RetroArch internal, reads           │
│  (linked into retroarch bin)     /var/run/drmConn for connector     │
│                                                                     │
│  MAME Switchres 2.21f        ← GroovyMAME internal, reads          │
│  (linked into mame bin)          /etc/switchres.ini for profile     │
└─────────────────────────────────────────────────────────────────────┘
```

All three share the same `/etc/switchres.ini` for monitor profile configuration. The
CRT Script's Phase 2 installation writes this file once and all three implementations
read it — they just each have their own copy of the switchres logic.

### Full per-system resolution switching flow

```
User selects game in EmulationStation
        │
        ▼
ES → EmulatorLauncher → configgen for system (Python)
        │
        ├── MAME? → mameGenerator.py adds -modeline_generation -changeres -modesetting
        │               → MAME starts, internal Switchres 2.21f reads /etc/switchres.ini
        │               → generates modeline, injects via modesetting DDX + xrandr
        │
        ├── RetroArch? → retroarchGenerator.py sets video_crt_switch_resolution=1
        │               → RA starts, internal switchres reads /var/run/drmConn
        │               → generates modeline for the core's system resolution/refresh
        │               → injects via KMS/DRM or xrandr
        │
        └── Other emulator? → videoMode.py → changeMode() → batocera-resolution setMode
                            → patched batocera-resolution reads videomodes.conf
                            → calls /usr/bin/switchres -c for modeline
                            → applies via xrandr --newmode / --addmode / --output --mode
```

---

## 7. X11 Boot Chain in Detail

```
/etc/init.d/S31emulationstation
        │
        └── startx /etc/X11/xinit/xserverrc -- :0
                    │
                    └── Xorg starts with /etc/X11/xorg.conf.d/ configs:
                            10-monitor.conf     (ignore all but CRT output)
                            15-crt-monitor.conf (HorizSync/VertRefresh from EDID)
                            20-modesetting.conf (force modesetting DDX)
                            20-amdgpu.conf      (AMD GPU base config)
                            │
                            └── /etc/X11/xinitrc.d/99batocera
                                    └── xorg/xinitrc
                                            └── openbox --startup emulationstation-standalone
                                                    │
                                                    └── emulationstation-standalone
                                                            │ (display setup via batocera-resolution)
                                                            └── emulationstation binary
```

**Note on `S00bootcustom`:** The `boot-custom.sh` / `S00bootcustom` early-boot script that
generates `15-crt-monitor.conf` from the EDID is **not** part of the upstream batocera.linux
package tree. It is installed by the Batocera-CRT-Script itself during Phase 2. This means:
- A clean X11 squashfs does NOT have it
- The CRT Script must install it as part of Phase 2 setup
- On subsequent boots, it runs early enough to configure Xorg before the X server starts

---

## 8. What the X11 Squashfs Includes (vs Wayland)

| Component | X11 squashfs | Wayland squashfs |
|---|---|---|
| `/usr/bin/switchres` | ✅ Built in | ❌ Not included |
| `libswitchres.so` | ✅ Built in | ❌ Not included |
| `/usr/bin/xrandr` | ✅ Built in | ❌ Not applicable |
| `Xorg` / modesetting DDX | ✅ Built in | ❌ Not applicable |
| `batocera-resolution.xorg` | ✅ Installed | ❌ `.wayland-labwc` instead |
| RetroArch (with switchres patches) | ✅ Built in | ✅ Built in (same binary) |
| MAME / GroovyMAME | ✅ Built in | ✅ Built in (same binary) |
| `/etc/switchres.ini` | ✅ Default installed | ❌ Not installed |
| `/var/run/drmConn` | Written at runtime by CRT Script | ❌ Not applicable |

The Wayland build substitutes the X11 display stack with `labwc` compositor, `wlroots`,
and Wayland-native display management. None of the xrandr/modeline injection infrastructure
exists there.

---

## 9. What the CRT Script Must Add on Top of the X11 Build

The X11 squashfs provides the foundation. The CRT Script's Phase 2 adds the CRT-specific
layer on top:

| What | How | When |
|---|---|---|
| Patched `batocera-resolution` | Overwrites `/usr/bin/batocera-resolution` | Phase 2 |
| `/etc/switchres.ini` | Writes user's monitor profile | Phase 2 |
| `/etc/X11/xorg.conf.d/10-monitor.conf` | Writes CRT output, ignores others | Phase 2 |
| `/etc/X11/xorg.conf.d/15-crt-monitor.conf` | Generated by boot-custom.sh at every boot | Every boot |
| `/etc/X11/xorg.conf.d/20-modesetting.conf` | Forces modesetting DDX | Phase 2 |
| `/lib/firmware/edid/custom.bin` | switchres EDID generation | Phase 2 |
| `/etc/init.d/S00bootcustom` → `boot-custom.sh` | Installed by CRT Script | Phase 2 |
| `/var/run/drmConn` | Written with selected connector name (for RetroArch) | Phase 2 |
| `/userdata/system/videomodes.conf` | CRT mode database (survives reboot — shared partition) | Phase 2 |
| GRUB CRT kernel params (`drm.edid_firmware=...`) | Added to CRT menuentry in grub.cfg | Phase 1 |

**Phase 1** (runs while still on Wayland, before first reboot): Only touches boot partition —
extracts X11 squashfs, modifies grub.cfg, writes initrd-crt.gz.

**Phase 2** (runs after first reboot into X11): Configures all the CRT-specific files listed
above into the running X11 environment. xrandr is now available, so output detection and
EDID generation work correctly.

---

## 10. Key File Locations Reference

```
Package source (in batocera.linux repo):
  package/batocera/utils/switchres/              ← switchres package
  package/batocera/core/batocera-resolution/     ← batocera-resolution package
  package/batocera/emulators/retroarch/          ← RetroArch + switchres patches
  package/batocera/emulators/mame/               ← GroovyMAME + Switchres 2.21f
  package/batocera/emulationstation/             ← ES + emulationstation-standalone
  package/batocera/core/batocera-es-system/      ← configgen scripts incl. videoMode.py

Runtime (inside the X11 squashfs):
  /usr/bin/switchres                             ← switchres CLI tool
  /usr/bin/geometry                              ← Python geometry wrapper
  /usr/bin/grid                                  ← CRT grid overlay tool
  /usr/lib/libswitchres.so                       ← shared library
  /usr/bin/batocera-resolution                   ← display management (patched by CRT Script)
  /etc/switchres.ini                             ← monitor profile (written by CRT Script)
  /etc/X11/xorg.conf.d/                          ← Xorg configs (written by CRT Script)
  /lib/firmware/edid/custom.bin                  ← EDID binary (written by CRT Script)
  /var/run/drmConn                               ← connector for RetroArch (written by CRT Script)

Shared partition (/userdata/ — survives both boots):
  /userdata/system/videomodes.conf               ← CRT mode database
  /userdata/system/batocera.conf                 ← global config incl. videooutput/videomode
  /userdata/system/Batocera-CRT-Script/          ← CRT Script config, profiles, backups
```
