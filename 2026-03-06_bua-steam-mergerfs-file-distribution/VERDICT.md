# VERDICT — mergerfs File Distribution (steam, crt, flatpak, ports)

## Status: IN PROGRESS

## Summary

mergerfs `category.create=mfs` policy was scattering BUA addon and CRT Script files across external drives (primarily BATO-PARROT, which has the most free space). Four ROM subsystems were affected: steam, crt, flatpak, and ports. All unique files have been consolidated to the internal NVMe (`.roms_base`). Steam scripts have been modified to always write to `.roms_base`. BATO-PARROT's steam directory has been deleted. The remaining three directories (crt, flatpak, ports) still exist on BATO-PARROT awaiting deletion approval.

## Changes Applied

| File | Change |
|------|--------|
| `steam/extra/create-steam-launchers2.sh` | Pin writes to `.roms_base` |
| `steam/extra/create-steam-launchers.sh` | Pin writes to `.roms_base` |
| `steam/steam2.sh` | Pin writes to `.roms_base` |
| `steam/steam.sh` | Pin writes to `.roms_base` |
| BATO-PARROT `/roms/steam/` | Deleted after verification |
| `.roms_base/steam/gamelist.xml` | Merged 26 entries from BATO-PARROT |
| `.roms_base/crt/` | 35 files copied from BATO-PARROT |
| `.roms_base/flatpak/` | 4 files copied from BATO-PARROT |
| `.roms_base/ports/` | 3 files copied from BATO-PARROT |

## Outstanding

- Delete crt/flatpak/ports from BATO-PARROT (awaiting approval)
- CRT Script fix (pin `/userdata/roms/crt` writes to `.roms_base`)
- BUA systemic fix for ports/flatpak (100+ scripts)
