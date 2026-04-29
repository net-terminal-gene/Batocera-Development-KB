# 01 — Added Batocera-CRT-Script via FileZilla

**Date:** 2026-02-20
**Action:** Manually transferred the `Batocera-CRT-Script` directory to `/userdata/system/` on the Batocera machine using FileZilla.
**Previous state:** `00-v43-Wayland-factory-settings.md`

---

## Verification

### /userdata/system/Batocera-CRT-Script/ — Present

```
Batocera_ALLINONE
Boot_configs
Boot_logos
Cards_detection
Geometry_modeline
GunCon2
Mame_configs
System_configs
UsrBin_configs
etc_configs
extra
install-vnc_server_batocera
```

Total size: **119MB**

### Batocera_ALLINONE/ — Scripts present

```
total 880
-rw-r--r-- 1 root root 133325 Feb 20 23:53 Batocera-CRT-Script-v40.sh
-rw-r--r-- 1 root root 141246 Feb 20 23:53 Batocera-CRT-Script-v41.sh
-rw-r--r-- 1 root root 221792 Feb 20 23:53 Batocera-CRT-Script-v42.sh
-rw-r--r-- 1 root root 252163 Feb 20 23:53 Batocera-CRT-Script-v43.sh
-rw-r--r-- 1 root root 123579 Feb 20 23:53 Batocera-CRT-Script.sh
-rw-r--r-- 1 root root   4917 Feb 20 23:53 crt_script_selfcheck.sh
```

### v43 Script — Confirmed

| Check | Result |
|---|---|
| Line count | 5702 (matches local — dual-boot code present) |
| Shebang | `#!/bin/bash` |
| File size | 252,163 bytes |
| Permissions | `-rw-r--r--` (needs `chmod 755` before running) |

### mode_switcher.sh — Present

`/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh` — **FOUND**

### Phase flag — Not present

No `.install_phase` file. (Expected — script has not been run yet.)

### Disk Space

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   10G  4.4G  5.7G  44% /boot
/dev/nvme0n1p2  1.8T  258M  1.7T   1% /userdata
```

`/userdata` usage went from 140MB → 258MB (+118MB for the script directory). Boot partition unchanged.

---

## What Changed from Step 00

| Item | Before (00) | After (01) |
|---|---|---|
| `/userdata/system/Batocera-CRT-Script/` | Does not exist | Present (119MB) |
| `/userdata` used | 140MB | 258MB |
| `/boot` | Unchanged | Unchanged |
| `grub.cfg` | Unchanged | Unchanged |
| Phase flag | Not present | Not present |

## Next Step

`chmod 755` and run the v43 script:

```bash
cd /userdata/system/Batocera-CRT-Script/Batocera_ALLINONE && chmod 755 Batocera-CRT-Script-v43.sh && ./Batocera-CRT-Script-v43.sh
```
