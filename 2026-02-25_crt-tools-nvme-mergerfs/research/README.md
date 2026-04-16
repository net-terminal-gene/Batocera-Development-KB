# Research — CRT Tools on Boot Drive (mergerFS Conflict)

## Findings

### Mode Switcher CRT Path Usage

From `Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh`:

| Line | Function | Path | Operation |
|------|----------|------|-----------|
| 187-188 | `get_video_output_xrandr` | `/userdata/roms/crt/GunCon2_Calibration.sh` | Read |
| 380-382 | `backup_mode_files` (CRT) | `/userdata/roms/crt/GunCon2_Calibration.sh` | Read + copy to backup |
| 869-917 | `restore_mode_files` | `/userdata/roms/crt/` | `rm -rf`, `mkdir`, `cp` (full reinstall) |
| 937-938 | GunCon2 restore | `/userdata/roms/crt/GunCon2_Calibration.sh` | Write |
| 941 | GunCon2 recreate | `/userdata/roms/crt/GunCon2_Calibration.sh` | Write |

All CRT tool operations use `/userdata/roms/crt` — the mergerFS pool path.

### Current Physical Location (2026-02-25)

- Boot drive (`.roms_base/crt`): 0 files
- BATO-ALL: 0 files
- BATO-PARROT: 6 files
- BATO-LG: 0 files

CRT tools currently reside on BATO-PARROT. With `=NC` fix, mode switcher writes would continue landing there — problematic when BATO-PARROT is disconnected during boot/mode switch. CRT tools must be on the boot drive (NVMe, SATA, or microSD).

### mergerFS Limitation

mergerFS has no per-subdirectory or per-path branch policy. You cannot say "boot-drive branch is =NC except for `/crt/`". The `=NC` flag applies to the entire branch.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

