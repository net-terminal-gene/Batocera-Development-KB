# Research — mergerfs File Distribution (steam, crt, flatpak, ports)

## Snapshot Date: 2026-03-06

## Drive Free Space

| Drive | Mount | Filesystem | Total | Free | Use% |
|-------|-------|------------|-------|------|------|
| NVMe (CT2000P310SSD2) | `/userdata` (`.roms_base`) | ext4 | 1.8 TB | 1.3 TB | 25% |
| SSD (CT4000BX500SSD1) | `/media/BATO-PARROT` | exfat (fuseblk) | 3.7 TB | 2.4 TB | 37% |
| SD (FG8Y7) | `/media/BATO-ALL` | — | 955 GB | 228 GB | 77% |
| SD (USB3.0 CRW) | `/media/BATO-LG` | — | 955 GB | 68 GB | 93% |

## mergerfs Configuration

```
mergerfs.roms=/userdata/roms@/media/BATO-ALL/roms:/media/BATO-LG/roms:/media/BATO-PARROT/roms
```

Create policy: `category.create=mfs` (most free space)

---

## Steam — File Inventory (RESOLVED)

BATO-PARROT steam directory **deleted** after all files confirmed on `.roms_base`.

### `.roms_base/steam/` (Internal NVMe) — Complete

- 49 `.sh` game launchers
- 29 `.steam` shortcut files
- 49 `.keys` padtokey profiles
- `gamelist.xml` (79 entries, merged from both sources)
- `images/` — 179 image files
- `videos/` — 13 video files
- `_info.txt`
- `gamelist.xml.pre-merge` (backup)

### Games Only Previously on BATO-PARROT (now on `.roms_base`)

28 `.steam` shortcut files and 36 images were unique to BATO-PARROT and have been copied to `.roms_base`.

---

## CRT — File Inventory

### BATO-PARROT `/media/BATO-PARROT/roms/crt/` (still present, all copied to `.roms_base`)

| File | Type |
|------|------|
| GunCon2_Calibration.sh | Launcher |
| es_adjust_tool.sh | Launcher |
| es_adjust_tool.sh.keys | Padtokey |
| geometry.sh | Launcher |
| geometry.sh.keys | Padtokey |
| grid_tool.sh | Launcher |
| grid_tool.sh.keys | Padtokey |
| mode_switcher.sh | Launcher |
| mode_switcher.sh.keys | Padtokey |
| overlays_overrides.sh | Launcher |
| overlays_overrides.sh.keys | Padtokey |
| gamelist.xml | Game list |
| images/ | 18 images + v1/ subdir (4 images) |
| manuals/ | CRT.sh-manual.pdf |

### `.roms_base/crt/` — Now contains all of the above

Previously only had `.DS_Store`. All CRT files copied from BATO-PARROT.

---

## Flatpak — File Inventory

### BATO-PARROT `/media/BATO-PARROT/roms/flatpak/` (still present, all copied to `.roms_base`)

| File | Type |
|------|------|
| Fightcade.flatpak | Shortcut |
| gamelist.xml | Game list |
| data/ | Empty dir |
| images/ | Fightcade-marquee.png, Fightcade.png |

### `.roms_base/flatpak/` — Now contains all of the above

Previously only had `_info.txt` and empty `data/`.

---

## Ports — File Inventory

### BATO-PARROT `/media/BATO-PARROT/roms/ports/` (still present, all copied to `.roms_base`)

| File | Also on .roms_base? |
|------|---------------------|
| Crunchyroll.sh | Yes (duplicate) |
| Crunchyroll.sh.keys | Yes (duplicate) |
| GoogleChrome.sh | Yes (duplicate) |
| Kodi.sh | Yes (duplicate) |
| Sudachi Qlauncher.sh.keys | Was unique — now copied |
| bua.sh | Yes (duplicate) |
| gamelist.xml | Yes (both have copies) |
| RGSX/ | Yes (duplicate, all 74 files match) |
| RGSX_INSTALL_LOGS/ | Yes (duplicate) |
| images/ | 2 unique copied (fightcade-wheel.png, netflix-wheel.png) |
| videos/ | Yes (duplicate) |

### `.roms_base/ports/` — Now contains all of the above, plus:

| File | Note |
|------|------|
| Fightcade.sh | Only on .roms_base |
| Switch AppImages Updater.sh | Only on .roms_base |
| Switch AppImages Updater.sh.keys | Only on .roms_base |
| _info.txt | Only on .roms_base |
| _delete_me.txt | Only on .roms_base |

---

## BUA Script Fix Scope

### Scripts that write to `/userdata/roms/ports` (100+ files)

Every BUA addon installer writes its launcher to `/userdata/roms/ports/`. Modifying each individually is not feasible. These scripts all follow a pattern from template files:

- `app/templates/template.sh`
- `app/templates/flatpak-template.sh`
- `app/templates/linux_template.sh`
- `app/templates/local_template.sh`

A systemic fix would need to modify these templates and regenerate, or add a shared helper.

### Scripts that write to `/userdata/roms/flatpak` (7 files)

- `stremio/stremio.sh`, `plex/plex.sh`, `parsec/parsec.sh`, `itchio/itch.sh`, `inputleap/inputleap.sh`, `everest/everest.sh`, `bottles/bottles.sh`
- Plus `app/templates/flatpak-template.sh`

### Scripts that write to `/userdata/roms/crt` (Batocera-CRT-Script)

- `Batocera-CRT-Script.sh` (lines 1750-1751, 1903-1904)
- `Batocera-CRT-Script-v43.sh` (similar references)

---

## Findings

1. **mergerfs `mfs` policy is the root cause** for all four systems.
2. **Steam fix is implemented** — 4 BUA scripts modified, all files consolidated on `.roms_base`, BATO-PARROT steam dir deleted.
3. **crt/flatpak/ports files migrated** — all unique files copied to `.roms_base`. BATO-PARROT copies awaiting deletion approval.
4. **Systemic BUA fix needed** — 100+ scripts write to `/userdata/roms/ports`. Individual fixes are impractical. Best approach is a shared helper or `batocera-storage-manager` exclusion list.
5. **No data was lost** — all copies were verified before any deletion.
