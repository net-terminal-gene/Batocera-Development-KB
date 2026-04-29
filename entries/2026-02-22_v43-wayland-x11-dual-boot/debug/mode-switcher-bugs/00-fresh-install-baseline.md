# Fresh Install Baseline — 2026-02-22 00:14 UTC

**Purpose:** Factory state snapshot before running Batocera-CRT-Script Phase 1.

## System State

| Item | Value |
|------|-------|
| Uptime | 4 minutes |
| Kernel | 6.18.9 |
| Boot image | `/boot/linux` (Wayland) |
| CMDLINE | `BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/boot/initrd.gz` |
| Dual-boot | NO (`/boot/crt/linux` does not exist) |

## Script Files Verification

| File | Status |
|------|--------|
| `Batocera-CRT-Script-v43.sh` | Present, executable (`-rwxr-xr-x`, 257679 bytes) |
| `crt-launcher.sh` | Present, **not executable** (`-rw-r--r--`, 1229 bytes) — expected; v43.sh installer will `chmod 755` during Phase 2 |
| `es_systems_crt.cfg` | Present, command points to `crt-launcher.sh` wrapper |

## Wrapper Verification

`crt-launcher.sh` uses the correct CLI command:
```
CURRENT=$(batocera-resolution currentMode 2>/dev/null)
```

`es_systems_crt.cfg` command tag:
```xml
<command>/userdata/system/Batocera-CRT-Script/Geometry_modeline/crt-launcher.sh %CONTROLLERSCONFIG% -system %SYSTEM% -rom %ROM% -gameinfoxml %GAMEINFOXML% -systemname %SYSTEMNAME%</command>
```

## Next Step

Run Batocera-CRT-Script Phase 1 (Wayland). System will shut down after Phase 1 completes.
