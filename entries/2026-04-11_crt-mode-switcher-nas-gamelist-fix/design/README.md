# Design — CRT Mode Switcher: NAS Gamelist Visibility Fix

## Architecture

### Old Flow (problematic)

```
install_crt_tools(mode)
  ├─ if mode == "hd"
  │    rm -rf $CRT_ROMS/crt/*          ← deletes everything
  │    cp mode_switcher.sh              ← selective copy: switcher only
  │    cp mode_switcher images
  │    cp gamelist.xml
  │    cp CRT.svg / CRT.png
  │
  └─ if mode == "crt"
       rm -rf $CRT_ROMS/crt/*          ← deletes everything
       cp -a .../crt/ $CRT_ROMS/       ← full copy
```

**NAS failure point:** On CIFS/NFS mounts, `rm -rf` flushes before reboot but the subsequent `cp` writes may not — leaving the directory empty after reboot.

### New Flow (fixed)

```
install_crt_tools(mode)
  ├─ cp -a .../crt/. $CRT_ROMS/crt/   ← unified full copy (both modes)
  ├─ cp CRT.svg / CRT.png
  ├─ restore/recreate GunCon2_Calibration.sh
  └─ set_crt_gamelist_visibility($CRT_ROMS/crt/gamelist.xml, mode)
       ├─ if mode == "hd"
       │    awk: add <hidden>true</hidden> after every <path>
       │         except ./mode_switcher.sh
       └─ if mode == "crt"
            sed: remove all <hidden> lines
```

### set_crt_gamelist_visibility Logic

**HD mode (awk pass):**
- Tracks when inside the `mode_switcher.sh` game block (`in_switcher` flag)
- Strips any pre-existing `<hidden>` lines to avoid duplicates
- Injects `<hidden>true</hidden>` after every `<path>` that is NOT mode_switcher

**CRT mode (sed pass):**
- Removes all `<hidden>` lines — every entry becomes visible

### Why gamelist.xml and not file deletion

- Files stay present on disk at all times — NAS write-back order is irrelevant
- EmulationStation respects `<hidden>true</hidden>` and does not display the entry
- ES still requires the CRT system to have at least one visible entry — mode_switcher.sh is always shown so the system remains accessible in HD mode
