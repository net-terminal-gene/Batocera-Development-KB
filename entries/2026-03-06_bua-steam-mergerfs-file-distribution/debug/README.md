# Debug — mergerfs File Distribution Pin Fix

## Verification Commands

```bash
# Check boot guard log
cat /userdata/system/logs/mergerfs-pin-internal.log

# Confirm all 4 dirs on internal
ls -d /userdata/.roms_base/{steam,crt,flatpak,ports}

# Confirm NOTHING on externals
ls -d /media/*/roms/{steam,crt,flatpak,ports} 2>/dev/null

# Check watcher process
ps aux | grep mergerfs-pin | grep -v grep

# Check mergerfs mount and policy
mount | grep mergerfs
getfattr -n user.mergerfs.category.create /userdata/roms/.mergerfs

# Check free space (mfs target)
df -h /userdata/.roms_base /media/BATO-PARROT/roms /media/BATO-ALL/roms /media/BATO-LG/roms

# Check CRT mode switcher uses CRT_ROMS
grep -c 'CRT_ROMS' /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh
grep -c '/userdata/roms/crt' /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh

# Check Steam launcher uses ROMS_ROOT
head -20 /userdata/system/add-ons/steam/create-steam-launchers.sh
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Boot guard log has no post-reboot entry | `custom.sh` not calling the script, or not executable |
| Watcher process not running after reboot | `custom.sh` missing or guard script error |
| Protected dirs appearing on external drives | Watcher not running; or script created files before watcher started |
| CRT tools on external after mode switch | `03_backup_restore.sh` still has hardcoded paths (not deployed) |
| Steam files on external | `create-steam-launchers.sh` not using `ROMS_ROOT` |
| `custom.sh` not executing at boot | File not chmod 755, or wrong path |

---

## Debug Log

### 01 — Post-reboot validation (2026-03-06 10:15)

**Context**: First reboot after deploying all fixes (Steam, CRT mode_switcher, boot guard).

**Finding**: Boot guard script did NOT run on reboot.

**Root cause**: Script was placed in `/userdata/system/scripts/` which is Batocera's **event hook** directory (game start/stop), not a boot script location. Batocera runs boot scripts from `/userdata/system/custom.sh`.

**Fix**: Created `/userdata/system/custom.sh` that calls `bash /userdata/system/scripts/mergerfs-pin-internal.sh &` in background.

**Verification after fix** (ran `custom.sh` manually, then saved overlay):

```
[2026-03-06 10:21:52] === Boot: mergerfs-pin-internal starting ===
[2026-03-06 10:21:52] === Boot: pin complete, watcher PID=5977 (checks every 5 min) ===
```

```
$ ps aux | grep mergerfs-pin | grep -v grep
root  5977  0.0  0.0  4364  1556 ?  S  10:21  0:00  bash /userdata/system/scripts/mergerfs-pin-internal.sh
```

**All 4 dirs on internal, 0 on externals:**

```
=== Internal .roms_base ===
/userdata/.roms_base/crt      (5 .sh tools)
/userdata/.roms_base/flatpak  (Fightcade.flatpak, gamelist, images)
/userdata/.roms_base/ports    (Crunchyroll, Fightcade, Chrome, Kodi, RGSX)
/userdata/.roms_base/steam    (all launchers + images)

=== External drives ===
(none)
```

**Status**: PARTIALLY FIXED — see debug entry 02.

---

### 02 — Second reboot: custom.sh not executed (2026-03-06 10:25)

**Context**: Rebooted to confirm `custom.sh` runs at boot.

**Finding**: Boot guard still did NOT run. Log has no new entry, watcher not running.

**Root cause**: **Batocera v43 deprecated `custom.sh`**. The init script `S99userservices` moves `custom.sh` to `/userdata/system/services/custom_service` on first boot. Since `custom_service` already existed (from BUA installs), our `custom.sh` was simply ignored — never executed, never moved.

v43 boot service mechanism:
- `/userdata/system/services/custom_service` is the actual boot service
- Managed by `batocera-services` (enabled with `*` marker)
- Our `custom.sh` was dead on arrival

**Fix**: Appended the guard call to the existing `custom_service`:

```
# Pin steam/crt/flatpak/ports to internal drive (mergerfs protection)
bash "/userdata/system/scripts/mergerfs-pin-internal.sh" &
```

**Verification** (manual run, pre-reboot):

```
[2026-03-06 10:26:28] === Boot: mergerfs-pin-internal starting ===
[2026-03-06 10:26:28] === Boot: pin complete, watcher PID=4662 (checks every 5 min) ===
```

Watcher running: `root 4662 ... bash /userdata/system/scripts/mergerfs-pin-internal.sh`

**Status**: FIXED — `custom_service` updated, overlay saved.

---

### 03 — Third reboot: boot guard running (2026-03-06 10:28)

**Context**: Reboot to confirm `custom_service` invokes the guard at boot.

**Result**: SUCCESS.

```
[2026-03-06 10:28:43] === Boot: mergerfs-pin-internal starting ===
[2026-03-06 10:28:43] === Boot: pin complete, watcher PID=3484 (checks every 5 min) ===
```

Watcher running: `root 3484 ... bash /userdata/system/scripts/mergerfs-pin-internal.sh`
External drives: zero protected dirs.

**Status**: VERIFIED — boot guard runs automatically via `custom_service` on every reboot.

---

### 04 — Mode Switcher test: CRT→HD switch (2026-03-06 10:32)

**Context**: User ran Mode Switcher (switched to HD mode). Script completed, files saved, but has NOT rebooted yet.

**Result**: SUCCESS — all CRT files written to internal drive.

**Mode switcher log** (`BUILD_15KHz_Batocera.log`):
```
[10:32:04]: Reinstalling CRT Tools for hd mode...
[10:32:04]: HD Mode: Installing Mode Selector only
[10:32:06]: VERIFIED: /userdata/.roms_base/crt exists
-rwxr-xr-x 1 root root 199 Mar  6 10:32 /userdata/.roms_base/crt/mode_switcher.sh
[10:32:06]: Restore completed for hd mode (userdata-only approach)
```

Key line: `VERIFIED: /userdata/.roms_base/crt exists` — the `$CRT_ROMS` variable resolved to `.roms_base` and the verification block confirmed it.

**Internal `.roms_base/crt/` contents** (HD mode — only mode_switcher + assets):
```
CRT.png          (78017 bytes, 10:32)
CRT.svg          (5189 bytes, 10:32)
gamelist.xml     (4743 bytes, 10:32)
images/          (dir, 10:32)
mode_switcher.sh (199 bytes, 10:32)
mode_switcher.sh.keys (2068 bytes, 10:32)
```

**External drives**: zero `crt/` directories on any drive.

**Boot guard log**: guard ran at 10:31:46 (before mode switch at 10:32:04) — watcher PID 5471 active.

**All 4 systems clean on externals**: no `steam/`, `crt/`, `flatpak/`, `ports/` on BATO-PARROT, BATO-ALL, or BATO-LG.

**Status**: PASS — `$CRT_ROMS` fix working correctly at runtime. Pre-reboot state clean.

---

### 05 — Post-mode-switch reboot (2026-03-06 10:35)

**Context**: Reboot after HD mode switch (full cycle: mode switch → save → reboot).

**Result**: SUCCESS — all systems clean.

- Boot guard ran at 10:34:48, watcher running (PID 3636, 3653)
- CRT tools on internal: `CRT.png`, `CRT.svg`, `gamelist.xml`, `images/`, `mode_switcher.sh`, `mode_switcher.sh.keys`
- External drives: zero protected dirs on any drive

**Status**: PASS — full mode-switch + reboot cycle verified. No files scattered to external drives.

---

### 06 — Steam game launch from migrated files (2026-03-06 ~10:36)

**Context**: Launched **Balatro** — a `.steam` shortcut that was originally unique to BATO-PARROT and was migrated to `.roms_base` during this session.

**Result**: SUCCESS — 100% working. Game loads and runs correctly from its new location on the internal NVMe.

**Status**: PASS — migrated Steam files are fully functional.

---

### 07 — New Steam game install: ZeroRanger (2026-03-06 10:42)

**Context**: User installed ZeroRanger (AppID 809020) via Steam to test that newly created launcher files land on the internal drive.

**Result**: SUCCESS — all files created on `.roms_base`, zero on external drives.

```
/userdata/.roms_base/steam/809020_ZeroRanger.sh       (687 bytes, 10:42)
/userdata/.roms_base/steam/809020_ZeroRanger.sh.keys  (207 bytes, 10:42)
/userdata/.roms_base/steam/images/809020_ZeroRanger.jpg (20382 bytes, 10:42)
gamelist.xml entry: <path>./809020_ZeroRanger.sh</path> <name>ZeroRanger</name>
```

External drives: zero `steam/` directories.

**Status**: PASS — `create-steam-launchers.sh` `ROMS_ROOT` fix confirmed for new installs.

---

### 08 — CRT mode switch + reboot (2026-03-06 10:52)

**Context**: User switched from HD back to CRT mode and rebooted. This exercises the `else` branch of `03_backup_restore.sh` — the full CRT tools install path (`cp -a crt/`, GunCon2 restore, permissions, overlays_overrides).

**Mode switcher log** (`BUILD_15KHz_Batocera.log`):
```
[10:52:58]: Restored GunCon2_Calibration.sh from CRT Mode backup
[10:52:58]: VERIFIED: /userdata/.roms_base/crt exists
[10:52:58]: Restore completed for crt mode (userdata-only approach)
```

**Internal `.roms_base/crt/`** — full CRT tools installed:
```
GunCon2_Calibration.sh       (restored from backup)
es_adjust_tool.sh            + .keys
geometry.sh                  + .keys
grid_tool.sh                 + .keys
mode_switcher.sh             + .keys
overlays_overrides.sh        + .keys  (10:52 — freshly copied)
gamelist.xml
images/                      (with subdirs)
manuals/
```

**External drives**: zero protected dirs on any drive.
**Boot guard**: ran at 10:53:59, watcher PID 3493 active.

**Status**: PASS — CRT mode `else` branch fully verified. Both HD and CRT mode switch paths confirmed working.
