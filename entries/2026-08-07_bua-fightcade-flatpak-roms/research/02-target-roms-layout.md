# Research — Target Fightcade ROMs folder structure (SETUP reference)

**Source (golden layout):** `/Volumes/Batocera/SETUP/fightcade/`  
**Captured:** 2026-08-07  
**Maps to Flatpak host ROMs root:**  
`/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/`

Out of scope: CRT / Switchres.

---

## Required top-level layout

```
ROMs/                          ← Flatpak persistent data (sandbox /var/data/ROMs)
├── fbneo/                     ← SETUP/fightcade/fbneo
├── flycast/                   ← SETUP/fightcade/flycast
├── snes9x/                    ← SETUP/fightcade/snes9x
└── ggpofba/                   ← Flatpak also mkdir's this; NOT present in SETUP reference
```

SETUP reference tree (what the ROMs dirs must look like):

```
fightcade/
├── fbneo/
│   ├── *.zip                  ← arcade (+ bios at root)
│   ├── coleco/
│   ├── gamegear/
│   ├── megadrive/
│   ├── msx/
│   ├── nes/
│   ├── nes_fds/
│   ├── pce/
│   ├── sg1000/
│   ├── sgx/
│   ├── sms/
│   ├── spectrum/
│   └── tg16/
├── flycast/
│   ├── atomiswave/
│   ├── data/                  ← BIOS / boot files
│   ├── dreamcast/
│   ├── naomi/
│   │   └── <gamedir>/         ← GD-ROM CHD per GD title
│   └── naomi2/
│       └── <gamedir>/         ← GD-ROM CHD per GD title
└── snes9x/
    └── *.zip                  ← flat; no subdirs
```

---

## `fbneo/` — FC2 FBNeo

**Role:** Arcade + FBNeo console platforms.  
**Flatpak target:** `.../ROMs/fbneo`

### Folders

| Folder | Purpose | Files that go here |
|--------|---------|-------------------|
| `fbneo/` (root) | Arcade ROMs + shared BIOS | `.zip` only (MAME/FBNeo short names) |
| `fbneo/coleco/` | ColecoVision | `.zip` |
| `fbneo/gamegear/` | Sega Game Gear | `.zip` |
| `fbneo/megadrive/` | Sega Mega Drive / Genesis | `.zip` |
| `fbneo/msx/` | MSX | `.zip` |
| `fbneo/nes/` | NES / Famicom | `.zip` |
| `fbneo/nes_fds/` | Famicom Disk System | `.zip` (includes `fdsbios.zip`) |
| `fbneo/pce/` | PC Engine | `.zip` |
| `fbneo/sg1000/` | Sega SG-1000 | `.zip` |
| `fbneo/sgx/` | SuperGrafx | `.zip` |
| `fbneo/sms/` | Sega Master System | `.zip` |
| `fbneo/spectrum/` | ZX Spectrum | `.zip` |
| `fbneo/tg16/` | TurboGrafx-16 | `.zip` |

### File types

| Type | Where | Notes |
|------|-------|--------|
| `.zip` | Root + every console subdir | **Only** extension observed in SETUP. Short-name romset zips (FBNeo / Fightcade naming). |
| BIOS zips | Root and platform dirs | e.g. root `neogeo.zip` (Neo Geo); `nes_fds/fdsbios.zip` |

### Counts in SETUP reference (informative)

| Location | Files |
|----------|------:|
| `fbneo/` root (arcade) | 2122 `.zip` |
| `megadrive/` | 1135 |
| `nes/` | 1134 |
| `msx/` | 793 |
| `sms/` | 398 |
| `gamegear/` | 379 |
| `pce/` | 292 |
| `spectrum/` | 253 |
| `coleco/` | 180 |
| `nes_fds/` | 118 |
| `tg16/` | 93 |
| `sg1000/` | 90 |
| `sgx/` | 5 |

### Rules

- Arcade games: place `<shortname>.zip` directly in `fbneo/` (not in a console subfolder).
- Console games: place `<shortname>.zip` in the matching platform subfolder.
- Neo Geo: game zip in `fbneo/` root **plus** `neogeo.zip` BIOS in `fbneo/` root.
- Do **not** put loose `.nes` / `.bin` / `.smc` here in this layout; SETUP uses zipped Fightcade/FBNeo names only.

---

## `flycast/` — Flycast (Naomi / Naomi2 / Atomiswave / Dreamcast)

**Role:** Sega arcade boards + Dreamcast.  
**Flatpak target:** `.../ROMs/flycast`  
**Note:** No loose files at `flycast/` root in SETUP; everything is in subfolders.

### Folders

| Folder | Purpose | Files that go here |
|--------|---------|-------------------|
| `flycast/atomiswave/` | Atomiswave carts | `.zip` (short names) |
| `flycast/data/` | BIOS / firmware / boot | `.zip` BIOS packs + `.bin` Dreamcast boot ROMs |
| `flycast/dreamcast/` | Dreamcast games | mostly `.chd`; also `.zip` when used |
| `flycast/naomi/` | Naomi carts + GD-ROM titles | `.zip` at this level; GD titles also get a sibling subdir |
| `flycast/naomi/<gamename>/` | GD-ROM disc image for that title | `.chd` (e.g. `gdl-####.chd` / `gds-####.chd`) |
| `flycast/naomi2/` | Naomi 2 carts + GD-ROM titles | same pattern as `naomi/` |
| `flycast/naomi2/<gamename>/` | GD-ROM disc image | `.chd` |

### File types

| Type | Where | Notes |
|------|-------|--------|
| `.zip` | `atomiswave/`, `naomi/`, `naomi2/`, `dreamcast/` (rare), `data/` | Cart/ROM sets and BIOS packs. Short MAME-style names for arcade. |
| `.chd` | `dreamcast/`, `naomi/<game>/`, `naomi2/<game>/` | Disc images. Dreamcast titles often use full display names; Naomi GD uses `gdl-*` / `gds-*` IDs. |
| `.bin` | `data/` only | Dreamcast boot ROM dumps (`dc_boot.bin`, `dc_boot_regionfree.bin`) |

### `flycast/data/` BIOS set (SETUP contents)

| File | Type |
|------|------|
| `awbios.zip` | Atomiswave BIOS |
| `naomi.zip` | Naomi BIOS |
| `naomi2.zip` | Naomi 2 BIOS |
| `naomigd.zip` | Naomi GD-ROM BIOS |
| `airlbios.zip`, `hod2bios.zip`, `f355bios.zip`, `f355dlx.zip` | Board-specific BIOS |
| `dcjp.zip`, `dcfish.zip`, `dctream.zip` | Dreamcast-related packs |
| `dc_boot.bin` | Dreamcast boot ROM |
| `dc_boot_regionfree.bin` | Dreamcast boot ROM (region-free) |

### Naomi / Naomi2 pairing pattern

For GD-ROM games:

```
naomi/
├── ggxx.zip              ← small stub / parent zip at naomi/
└── ggxx/
    └── gdl-0011.chd      ← CHD inside matching shortname folder
```

Same for `naomi2/` (e.g. `vf4.zip` + `vf4/gds-0012c.chd`).  
Cart-only titles (e.g. `capsnk.zip`, `doa2m.zip`) sit as `.zip` in `naomi/` with **no** CHD subdir.

SETUP `naomi/` GD subdirs present: `cvs2`, `ggxx`, `ggxxac`, `ggxxrl`, `ggxxsla`, `luptype`, `meltyb`, `senko`, `senkosp`, `sfz3ugd`, `vtennis2`.  
SETUP `naomi2/` GD subdirs: `beachspi`, `vf4`, `vf4evo`, `vf4tuned`, `vstrik3`.

### Dreamcast

- Primary game files: `.chd` in `flycast/dreamcast/` (full titles as filenames in SETUP).
- Optional `.zip` alongside (SETUP has e.g. `KenJu.zip`).
- BIOS/boot still required under `flycast/data/`.

### Counts in SETUP reference (informative)

| Location | Files |
|----------|------:|
| `atomiswave/` | 29 `.zip` |
| `data/` | 13 (`.zip` + `.bin`) |
| `dreamcast/` | 14 (`.chd` + `.zip`) |
| `naomi/` (files + nested) | 31 |
| `naomi2/` (files + nested) | 12 |

---

## `snes9x/` — SNES9x

**Role:** Super Nintendo Fightcade ROMs.  
**Flatpak target:** `.../ROMs/snes9x`

### Folders

| Folder | Purpose |
|--------|---------|
| `snes9x/` (flat) | All SNES games at root — **no platform subdirs** |

### File types

| Type | Notes |
|------|--------|
| `.zip` only | Short-name zips (Fightcade/SNES9x naming). SETUP: 3444 files, zero subdirectories. |

### Rules

- Do not nest under `snes9x/ntsc/` etc. in this layout.
- Loose `.sfc` / `.smc` not used in the SETUP reference.

---

## Not in SETUP (but Flatpak creates)

| Folder | Flatpak path | Notes |
|--------|--------------|--------|
| `ggpofba/` | `.../ROMs/ggpofba` | FC1 FBAlpha ROMs (`.zip`). Entrypoint `mkdir`s it; SETUP golden tree does not include it. |

---

## Mapping: SETUP → Flatpak host

| SETUP path | Destination after seed |
|------------|------------------------|
| `/Volumes/Batocera/SETUP/fightcade/fbneo/` | `.../data/ROMs/fbneo/` |
| `/Volumes/Batocera/SETUP/fightcade/flycast/` | `.../data/ROMs/flycast/` |
| `/Volumes/Batocera/SETUP/fightcade/snes9x/` | `.../data/ROMs/snes9x/` |

Where `...` = `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade`

[Inference] Copying/rsyncing SETUP’s three trees into those three ROMs dirs is the intended populate step once the ROMs root exists (first launch or pre-seed `mkdir`).

---

## Extension cheat sheet

| Emulator root | Allowed / observed extensions | Subfolders required? |
|---------------|-------------------------------|----------------------|
| `fbneo/` | `.zip` | Yes — 12 console dirs + arcade at root |
| `flycast/` | `.zip`, `.chd`, `.bin` (BIOS only in `data/`) | Yes — `atomiswave`, `data`, `dreamcast`, `naomi`, `naomi2` (+ per-game CHD dirs) |
| `snes9x/` | `.zip` | No — flat |
| `ggpofba/` | `.zip` (expected) | Not in SETUP |

---

## Empty scaffold to pre-create (minimal dirs)

```bash
ROMS_ROOT=/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs

mkdir -p \
  "$ROMS_ROOT/fbneo/coleco" \
  "$ROMS_ROOT/fbneo/gamegear" \
  "$ROMS_ROOT/fbneo/megadrive" \
  "$ROMS_ROOT/fbneo/msx" \
  "$ROMS_ROOT/fbneo/nes" \
  "$ROMS_ROOT/fbneo/nes_fds" \
  "$ROMS_ROOT/fbneo/pce" \
  "$ROMS_ROOT/fbneo/sg1000" \
  "$ROMS_ROOT/fbneo/sgx" \
  "$ROMS_ROOT/fbneo/sms" \
  "$ROMS_ROOT/fbneo/spectrum" \
  "$ROMS_ROOT/fbneo/tg16" \
  "$ROMS_ROOT/flycast/atomiswave" \
  "$ROMS_ROOT/flycast/data" \
  "$ROMS_ROOT/flycast/dreamcast" \
  "$ROMS_ROOT/flycast/naomi" \
  "$ROMS_ROOT/flycast/naomi2" \
  "$ROMS_ROOT/snes9x" \
  "$ROMS_ROOT/ggpofba"
```

Populate by copying SETUP contents into `fbneo/`, `flycast/`, `snes9x/` (Naomi/Naomi2 game CHD subdirs come along with the copy).
