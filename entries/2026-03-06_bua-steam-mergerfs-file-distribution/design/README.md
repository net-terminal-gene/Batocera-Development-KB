# Design — mergerfs File Distribution (steam, crt, flatpak, ports)

## Architecture

### mergerfs pool layout

```
/userdata/roms/  (merged view — what Batocera/EmulationStation sees)
  ├── branch 1: /userdata/.roms_base/     (internal NVMe, ext4, 1.8 TB total)
  ├── branch 2: /media/BATO-ALL/roms/     (SD card, 955 GB total)
  ├── branch 3: /media/BATO-LG/roms/      (SD card, 955 GB total)
  └── branch 4: /media/BATO-PARROT/roms/  (external SSD, exfat via fuseblk, 3.7 TB total)
```

### Create policy: `mfs` (most free space)

When a new file is created through `/userdata/roms/`, mergerfs picks the branch with the most available free space. BATO-PARROT has ~2.4 TB free — the most of any branch — so it wins.

### Systems affected

```
/userdata/roms/steam/     ← BUA Steam addon (launchers, shortcuts, art)
/userdata/roms/crt/       ← Batocera-CRT-Script (geometry, grid, mode switcher tools)
/userdata/roms/flatpak/   ← BUA flatpak addons (Fightcade shortcut)
/userdata/roms/ports/     ← BUA addon launchers (Chrome, Crunchyroll, Kodi, RGSX, etc.)
```

None of these are actual ROM/game data. They are addon tools and launchers that belong exclusively on the internal drive.

### Fix approach: per-script `.roms_base` detection

```bash
# Detect mergerfs and write directly to internal drive
if [ -d "/userdata/.roms_base" ]; then
  ROMS_ROOT="/userdata/.roms_base"
else
  ROMS_ROOT="/userdata/roms"
fi
```

This works because:
- `.roms_base` only exists when mergerfs is active (external drives present)
- When no external drives are connected, `/userdata/roms` is a regular directory — no mergerfs, no scattering
- Files written to `.roms_base` are visible in the merged view via mergerfs (first branch)

### Fix scope

| System | Fix difficulty | Approach |
|--------|---------------|----------|
| steam | Done | 4 scripts modified |
| crt | Small | 2-4 write targets in CRT Script |
| flatpak | Medium | 7 BUA scripts + template |
| ports | Large (100+ scripts) | Needs systemic fix: shared helper or storage-manager exclusion |
