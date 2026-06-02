# Research — mergerFS Write Routing and S12populateshare Awareness

## Findings

### S12populateshare logic (lines 48-58)

Only checks `if test ! -e "$TDIR"` before copying. No awareness of external drives or mergerFS config.

Source: `board/batocera/fsoverlay/etc/init.d/S12populateshare`

### batocera-storage-manager mergerFS options (line 10)

```bash
MERGERFS_OPTS="-o cache.files=partial,dropcacheonclose=true,category.create=eplfs,allow_other,inodecalc=path-hash,moveonenospc=true,minfreespace=4G"
```

- `category.create=eplfs`: all create operations use "existing path, least free space"
- `moveonenospc=true`: auto-move file to another branch if current fills up
- `minfreespace=4G`: branch excluded from creates if < 4GB free

Source: `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager`

### Branch ordering

`.roms_base` is always first (hardcoded at line 647 and 831). External branches follow in config order.

### Observed symptoms (2026-05-16 debugging session)

- Stock SNES/megadrive/c64/nes/pcengine/gba gamelists in `.roms_base` shadow external drive gamelists
- Deleting stock content from `/userdata/roms/{system}/` is undone on reboot by S12populateshare
- Leaving `_info.txt` as a "poison pill" prevents repopulation (directory exists check passes)
- Switch gamelist from a different collection had image/video/marquee tags only for ROMs not on disk; actual 48 ROMs had bare entries with no artwork metadata

### S12populateshare datainit inventory (251 systems total)

236 systems have only `_info.txt` (directory placeholder). **15 systems ship with actual stock ROMs/content** that will shadow external drive content if not handled:

| System | Stock content |
|--------|--------------|
| c64 | `fix_it_felix_64.d64`, gamelist.xml, images, videos |
| cannonball | `Cannonball.cannonball.disabled`, gamelist.xml, images, videos |
| devilutionx | gamelist.xml, images |
| gba | `SpaceTwins.gba`, gamelist.xml, images, videos |
| iortcw | `main/` |
| mame | `mame2003/` |
| megadrive | `Old-Towers.bin`, gamelist.xml, images, videos |
| mrboom | `MrBoom.libretro`, gamelist.xml, images |
| nes | `2048 (tsone).nes`, gamelist.xml, images, videos |
| odcommander | `od-commander.odc`, gamelist.xml, images |
| pcengine | `Reflectron.pce`, `Santatlantean.pce`, gamelist.xml, images, videos |
| prboom | `doom1_shareware.wad`, gamelist.xml, images |
| pygame | `pygun/`, `retrotrivia/`, gamelist.xml, images, manuals |
| sdlpop | `sdlpop.sdlpop`, gamelist.xml, images |
| snes | `DonkeyKongClassic.smc`, gamelist.xml, images, videos |

**Key insight:** Only these 15 systems can cause gamelist shadowing. The other 236 (including `steam`) only get an empty directory with `_info.txt`, which is harmless. `steam` is in the 236 group (placeholder only, no stock content).

The 6 systems the user manages on external drives (c64, megadrive, snes, nes, pcengine, gba) are all in the "ships with stock content" group, which is why shadowing kept recurring.

---

## How mergerFS Actually Works in Batocera

This section explains Batocera's mergerFS configuration in plain terms for users and contributors.

### What mergerFS does

mergerFS is a union filesystem. It takes multiple directories (called "branches") and presents them as a single combined directory. In Batocera, this means multiple drives appear as one `/userdata/roms/` folder.

Example with three drives:

```
Branch 1: /userdata/.roms_base/     (internal NVMe)
Branch 2: /media/BATO-ALL/roms/     (SD card)
Branch 3: /media/BATO-PARROT/roms/  (USB drive)
         ↓ merged into ↓
         /userdata/roms/            (what ES sees)
```

EmulationStation, scrapers, and users only ever see `/userdata/roms/`. They don't know about the branches.

### Two key questions mergerFS answers

**1. When reading a file, which branch's copy do I serve?**
Policy: `ff` (first found). mergerFS checks branches in order (`.roms_base` first, then external drives in config order). The first branch that has the file wins. This means `.roms_base` always takes priority for reads.

**Consequence:** If `.roms_base/snes/gamelist.xml` and `BATO-ALL/roms/snes/gamelist.xml` both exist, ES always gets the `.roms_base` copy. The external drive's gamelist is invisible. This is the "shadowing" problem.

**2. When creating a new file, which branch does it land on?**
Policy: `category.create=eplfs` (existing path, least free space).

Two-step decision:

- **Step 1 (existing path):** Only branches that already have the parent directory are candidates. If `steam/` exists on NVMe and BATO-PARROT but not BATO-ALL, only NVMe and BATO-PARROT are candidates.
- **Step 2 (least free space):** Among candidates, pick the one with the **least** free space (above the 4GB minimum threshold).

**This is counterintuitive.** Most people assume new files go to the biggest/emptiest drive. They don't. They go to the **fullest** qualifying drive. The rationale: fill up smaller drives first so larger drives stay available longer.

### Worked example: Installing a Steam game

Setup:
- NVMe (`.roms_base`): has `steam/` dir, 1.7 TB free
- BATO-ALL: no `steam/` dir, 228 GB free
- BATO-LG: no `steam/` dir, 68 GB free
- BATO-PARROT: has `steam/` dir, 2.4 TB free

BUA installer creates `3513070_Blaze_of_Storm.sh` in `/userdata/roms/steam/`:

1. mergerFS checks: which branches have `steam/`? NVMe and BATO-PARROT.
2. NVMe has 1.7 TB free. BATO-PARROT has 2.4 TB free.
3. 1.7 TB < 2.4 TB, so the file lands on the **NVMe**.

Result: The game launcher ended up on the NVMe, not the external drive the user intended. The user has no way to control this.

### Worked example: Scraping SNES artwork

Setup:
- NVMe (`.roms_base`): has `snes/` dir, 1.7 TB free
- BATO-ALL: has `snes/` dir, 228 GB free

ES scraper saves `./images/Zelda-image.png` to `/userdata/roms/snes/images/`:

1. mergerFS checks: which branches have `snes/images/`? Both NVMe and BATO-ALL.
2. BATO-ALL has 228 GB free. NVMe has 1.7 TB free.
3. 228 GB < 1.7 TB, so the scraped image lands on **BATO-ALL**.

But if BATO-ALL later fills up past the 4GB threshold, the next scrape lands on NVMe instead. **The same system's files can end up scattered across drives over time.**

### Other important policies

| Option | Value | What it does |
|--------|-------|-------------|
| `moveonenospc=true` | enabled | If a write fills up a drive mid-file, automatically move to another branch |
| `minfreespace=4G` | 4 GB | Exclude any branch with less than 4 GB free from new creates |
| `cache.files=partial` | enabled | Cache open file handles for performance |
| `inodecalc=path-hash` | enabled | Generate stable inode numbers from path (avoids inode collisions across branches) |
| `allow_other` | enabled | Let non-root processes (ES, scrapers) access the mount |

### What users cannot do today

- Route specific systems to specific drives (e.g., "SNES always writes to BATO-ALL")
- Prevent writes to a specific branch (e.g., "never create new files on NVMe")
- Control which branch's gamelist takes priority when both branches have one
- Override the global `eplfs` policy for a subset of paths

### The `ff` + `eplfs` interaction (the root of most user confusion)

Reads and writes use **different** policies:

| Operation | Policy | Behavior |
|-----------|--------|----------|
| Read/open existing file | `ff` (first found) | First branch in order wins (`.roms_base` always wins) |
| Create new file | `eplfs` | Goes to branch with least free space |
| Delete file | `epall` (existing path, all) | Removes from all branches that have it |
| List directory | `seq` (sequential) | Merges listings from all branches |

This means:
- You **write** a gamelist to BATO-ALL (because it had least free space at the time)
- On reboot, S12populateshare puts a stock gamelist in `.roms_base`
- ES **reads** the `.roms_base` copy (because `ff` checks `.roms_base` first)
- Your BATO-ALL gamelist with all the artwork is invisible

The user did everything right. The system's policy combination creates the conflict.

### Hot-plug behavior

When a drive is ejected, `batocera-storage-manager` rebuilds the mergerFS pool without that branch. Files on the ejected drive disappear from the merged view instantly. When the drive is plugged back in and merged, the files reappear.

This is reliable and works as expected. The issue is only with write routing and read priority, not with hot-plug.

### The stock content problem (S12populateshare)

Batocera ships with 251 system directories. On every boot, an init script called `S12populateshare` copies these from a read-only system image into `/userdata/roms/`. It only copies a directory if it doesn't already exist at the destination.

**15 of those 251 systems come with actual ROMs and gamelists** (demo games for the out-of-box experience):

c64, cannonball, devilutionx, gba, iortcw, mame, megadrive, mrboom, nes, odcommander, pcengine, prboom, pygame, sdlpop, snes

The other 236 systems (including steam, switch, ps2, etc.) only get an empty folder with `_info.txt` and are harmless.

**Why this causes problems with external drives:**

Here's the boot sequence when you have an external drive with your own SNES collection:

1. **S12populateshare runs first** (before mergerFS). It sees `/userdata/roms/snes/` is empty or missing, so it copies the stock Donkey Kong ROM and a minimal `gamelist.xml` into `/userdata/roms/snes/`.

2. **batocera-storage-manager runs next.** It moves everything from `/userdata/roms/` into `/userdata/.roms_base/`, including the stock Donkey Kong and gamelist. Then it mounts mergerFS.

3. **mergerFS merges the branches.** Now `.roms_base/snes/` has the stock gamelist, and `BATO-ALL/roms/snes/` has your fully scraped gamelist with 200+ games and artwork.

4. **ES reads the gamelist.** The `ff` (first found) policy checks `.roms_base` first. It finds the stock gamelist there. Your BATO-ALL gamelist is invisible. All your artwork is gone.

**The circular trap:**

- "I'll just delete the stock content from `.roms_base`!" -- Next reboot, S12populateshare sees the empty folder and repopulates it.
- "I'll delete the entire folder!" -- Next reboot, S12populateshare sees it's missing and recreates it.
- "I'll delete it after mergerFS mounts!" -- You're deleting through the merged view, which removes from ALL branches (the `epall` delete policy). Your external drive content gets deleted too.

**The workaround: the poison pill**

The only way to break the cycle is to leave something in `.roms_base/{system}/` that:
1. Keeps the directory non-empty (so S12populateshare sees it exists and skips it)
2. Does NOT include a `gamelist.xml` (so there's nothing to shadow your external gamelist)

The solution: keep only `_info.txt` in `.roms_base/{system}/`. Delete the stock ROMs, `gamelist.xml`, `images/`, and `videos/`. The `_info.txt` file acts as a "poison pill" that satisfies S12populateshare's existence check while leaving nothing for `ff` to shadow.

**Step-by-step for each affected system (c64, megadrive, snes, nes, pcengine, gba, or any of the 15 stock-content systems):**

1. Eject all external drives (so mergerFS is down and you're working on the raw NVMe)
2. In `/userdata/roms/{system}/`, delete everything EXCEPT `_info.txt`:
   - Remove `gamelist.xml`
   - Remove all `.bin`, `.smc`, `.nes`, `.pce`, `.d64`, `.gba` ROM files
   - Remove `images/` and `videos/` directories
3. Verify only `_info.txt` remains
4. Re-merge your external drives

After this, ES will read the gamelist from your external drive (the only branch that has one), and S12populateshare will leave the directory alone on future reboots because it still exists.

**Important:** This must be done per-system. Any of the 15 stock-content systems that you also manage on an external drive needs this treatment. Systems you don't have on an external drive can be left alone (the stock content is harmless if there's nothing to shadow).
