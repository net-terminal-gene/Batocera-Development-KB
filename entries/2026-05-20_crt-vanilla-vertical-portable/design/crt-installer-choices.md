# CRT Installer Choices — Vertical (Vanilla Path)

Record **exact menu answers** when running `Batocera-CRT-Script-v42.sh` or `v43.sh` on fresh Batocera. Fill in from current Myzar if re-running installer is not possible — use captured `BUILD_15KHz_Batocera.log` on device.

## Target orientation

| Setting | Recommended for clockwise vertical cabinet |
|---------|------------------------------------------|
| Physical monitor rotation | Match cabinet (Clockwise / Counter-Clockwise) |
| ES orientation | **TATE270** (vertical clockwise) or **TATE90** if CCW |
| `display.rotate` | **1** (right) for TATE270 on current Myzar |

## What the installer writes (do not hand-edit unless documented)

- `/userdata/system/batocera.conf` — `display.rotate`, `mame.rotation`, switchres, bezels, per-emulator lines
- `/userdata/system/scripts/first_script.sh` — from `System_configs/First_script/first_script.sh-generic-v42`
- `/userdata/system/configs/mame/mame.ini`, `ui.ini`, `ini/horizont.ini`, `ini/vertical.ini`
- `/etc/switchres.ini`
- `/usr/bin/batocera-resolution` (MYZAR/ZFEbHVUE variant per GPU path)
- Patched `emulatorlauncher.py` / `videoMode.py` when ZFEbHVUE path selected

## MAME rotation policy (choose one)

| Policy | `batocera.conf` | Per-game cfg |
|--------|-----------------|--------------|
| **CRT default** | `mame.rotation=autorol` (TATE270) | Only exceptions |
| **Myzar aggressive** | May omit autorol | **1066×** `rotate=270` in `/userdata/system/configs/mame/*.cfg` |

Current device uses **bulk cfgs** (1066 files) + `display.rotate=1`; `mame.rotation` line not present in grep snapshot.

## Explicitly NOT using Myzar image

**Reason:** Myzar project policy rejects DisplayPort and DP+DAC CRT paths. This build needs DP to the display chain, so the platform is **vanilla Batocera + CRT Script**, not Myzar/Mizar releases.

Do not treat Myzar as the authority for `videooutput` or boot when DP is required.

## Version pin

| Component | Current cabinet (snapshot) | Target |
|-----------|--------------------------|--------|
| Batocera | **41ocp** (2025/01/06) | **42 or 43** official |
| CRT script on device | Not present under `/userdata/system/Batocera-CRT-Script` | Match Batocera major version |
| Mac CRT script repo | `Batocera-CRT-Script` v43 locally | Copy matching tag to userdata before install |
