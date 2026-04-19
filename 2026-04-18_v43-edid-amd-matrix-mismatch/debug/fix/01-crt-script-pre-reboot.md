# 01 - CRT script install complete, pre-reboot (fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh` + install on device)  
**Purpose:** Same checkpoint as [pre-fix 01](../pre-fix/01-crt-script-pre-reboot.md): install finished, **before** you press ENTER to reboot. Log and kernel-line evidence on the **fix** image (patched `03_backup_restore.sh` in tree).

**Scope:** X11-only lab. No Wayland / no two-kernel PR #395 dual-boot.

## Run context (verified over SSH)

| Check | Result |
|-------|--------|
| `batocera-version` | `43ov 2026/04/07 09:23` ([Inference] leading `43ov` may be copy/display artifact; build matches stock **43** image.) |
| Installer | `/userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` present, **0755**, ~261 KiB |
| `03_backup_restore.sh` on device | Present (~91 KiB); contains **`CRT_SYSLINUX_MASTER`** (e.g. line ~470) and **`Pre-saved CRT syslinux`** (e.g. line ~751) |
| `/boot/boot-custom.sh` | Present, **0755**, ~3149 bytes (install tail: installed OK) |
| End of installer | Banner still on **Press ENTER to reboot** (log tail shows first-boot instructions block) |

Interactive menu choices are **not** re-logged byte-for-byte here; align with [pre-fix 01](../pre-fix/01-crt-script-pre-reboot.md) unless you note a deliberate change below.

## GPU and output (SSH)

| Field | Value |
|-------|--------|
| `lspci` | `Navi 32 [Radeon RX 7700 XT / 7800 XT]` |
| `/userdata/system/logs/TYPE_OF_CARD_DRIVERS.info` | `AMD/ATI` then `AMDGPU` (two lines) |
| CRT / bind line | Not re-captured in this SSH snippet; treat as same lab as pre-fix unless you paste `BUILD` bind lines |

## Monitor profile and EDID (log evidence, fix run)

**`BootRes.log`:**

```
Monitor Type: generic_15
Boot Resolution: 768x576@25
```

**`BUILD_15KHz_Batocera.log` (filtered):**

```
Parity decision: interlace_force_even=1 (engine=DCN)
DEBUG: EDID PRE-bump applied; EDID will be generated at 769x576
EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e  (IFE=1, engine=DCN)
monitor mame = generic_15
```

**Interpretation:** **769×576** generation path, **DCN**, **IFE=1**. No **`switchres 1280 …`** line in this grep window, so this run matches **native / AMD-style** EDID generation for `generic_15`, same conclusion as pre-fix 01.

## `/lib/firmware/edid/generic_15.bin` (pre-reboot, on disk)

`stat` (live):

```
Size: 128
Modify: 2026-04-19 18:50:07 +0200
```

## Syslinux (where the kernel line landed)

This image has **no** `/boot/EFI/syslinux.cfg` (see [00](00-v43-x11-first-boot.md)). **`/boot/EFI/batocera/syslinux.cfg`** carries the CRT parameters:

```
APPEND label=BATOCERA ... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

That matches the installer’s expectation on this layout; the patched mode switcher scans **EFI/syslinux.cfg first**, then **`EFI/batocera/syslinux.cfg`**, etc., so **master discovery must hit the file that actually contains `drm.edid_firmware`**.

## Other install choices

Same table as [pre-fix 01](../pre-fix/01-crt-script-pre-reboot.md) unless you edit this file to record a change.

## Post-install actions (from log tail)

- `boot-custom.sh` installed to `/boot/` (0755).
- Installer ends with **reboot after ENTER** over SSH notice (still pending when this capture was taken).

## State intentionally left for **02** (after reboot)

- Full `edid-decode` on `generic_15.bin`.
- Longer `BUILD_15KHz_Batocera.log` excerpt (`TYPE_OF_CARD` in full build section if needed).
- `DISPLAY=:0.0 xrandr` with CRT as primary post-ES **Boot_*** selection.

## Next

- **[02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)** (post-reboot CRT baseline): done in fix phase; see that file. Same ladder position as [pre-fix 02](../pre-fix/02-crt-mode-pre-mode-switcher.md).

## Reference

- Prior step: [00-v43-x11-first-boot.md](00-v43-x11-first-boot.md)  
- Historical narrative: [../pre-fix/01-crt-script-pre-reboot.md](../pre-fix/01-crt-script-pre-reboot.md)
