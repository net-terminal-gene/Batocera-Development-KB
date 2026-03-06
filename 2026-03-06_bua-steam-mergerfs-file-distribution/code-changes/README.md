# Code Changes — mergerfs File Distribution Fix

Every code change made to pin addon/tool writes to the internal drive, preventing mergerfs `mfs` from scattering files to external drives.

## Change Index

| # | System | Target | Deployed to Remote? | Doc |
|---|--------|--------|---------------------|-----|
| 1 | Steam | `/userdata/system/add-ons/steam/create-steam-launchers.sh` | **YES** — live on remote Batocera | [01-steam-create-steam-launchers.md](01-steam-create-steam-launchers.md) |
| 2 | CRT | `Batocera-CRT-Script-v43.sh` (installer) | **NO** — local repo only | [02-crt-installer-v43.md](02-crt-installer-v43.md) |
| 3 | CRT | `mode_switcher.sh` (parent script) | **YES** — live on remote Batocera | [03-crt-mode-switcher-parent.md](03-crt-mode-switcher-parent.md) |
| 4 | CRT | `03_backup_restore.sh` (mode switcher module) | **YES** — live on remote Batocera | [04-crt-mode-switcher-backup-restore.md](04-crt-mode-switcher-backup-restore.md) |
| 5 | ALL | `mergerfs-pin-internal.sh` (boot guard + watcher) | **YES** — live on remote Batocera | [05-boot-guard-mergerfs-pin-internal.md](05-boot-guard-mergerfs-pin-internal.md) |

## Pattern Used

All changes follow the same pattern — detect `.roms_base` and write there instead of the merged `/userdata/roms/`:

```bash
if [ -d "/userdata/.roms_base" ]; then
  VARIABLE="/userdata/.roms_base"
else
  VARIABLE="/userdata/roms"
fi
```

- When mergerfs is active, `/userdata/.roms_base` is the internal NVMe branch.
- When mergerfs is NOT active (no external drives), it falls back to `/userdata/roms` (which IS the NVMe directly).
- This ensures files always land on the internal drive regardless of mergerfs state.

## What Is NOT Changed

- **Read-only paths** — Scripts that only *read* from `/userdata/roms/crt/` (e.g. checking if a file exists for detection) work fine through the merged view. Reads find the file regardless of which branch it's on.
- **`DIRS_TO_REMOVE` array** in `Batocera-CRT-Script-v43.sh` line 359 — This is the *uninstall/restore* cleanup path. It must stay as `/userdata/roms/crt` so `rm -rf` goes through the merged view and deletes files from whichever branch they're on.
- **Commented-out code** in `Batocera-CRT-Script-v43.sh` lines 5136-5137 — Dead code, no effect.
