# Research — Batocera Flycast systems (`_info.txt`) vs Fightcade `flycast/`

**Captured:** 2026-08-07 (`batocera.local` + `/Volumes/Batocera/roms/*/\_info.txt`)  
**Fightcade golden:** `/Volumes/Batocera/SETUP/fightcade/flycast/`  
**Flatpak target:** `.../data/ROMs/flycast/`

---

## Verdict

Batocera does **not** have a single `roms/flycast` folder. Flycast content is split across **four systems**, each with its own `_info.txt` and accepted extensions. That does **not** match Fightcade’s one-tree layout (`flycast/{atomiswave,data,dreamcast,naomi,naomi2}`), so you **cannot** symlink “Batocera Flycast roms” as one path into Fightcade.

Partial overlaps exist (`.zip` / `.chd`), but folder topology and BIOS placement differ.

---

## Batocera systems (from each `_info.txt`)

There is **no** `/userdata/roms/flycast`. Present:

| System path | `_info.txt` accepted extensions | Other notes from `_info.txt` |
|-------------|----------------------------------|------------------------------|
| `/userdata/roms/dreamcast` | `.cdi` `.cue` `.gdi` `.chd` `.m3u` | Wiki: systems:dreamcast |
| `/userdata/roms/naomi` | `.lst` `.bin` `.dat` `.zip` `.7z` | — |
| `/userdata/roms/naomi2` | `.zip` `.7z` | Needs **Naomi 2 BIOS** as `naomi2.zip` in **`bios/dc`** (not under roms) |
| `/userdata/roms/atomiswave` | `.lst` `.bin` `.dat` `.zip` `.7z` | — |

### Full `_info.txt` text (host)

**dreamcast:**
```
ROM files extensions accepted: ".cdi .cue .gdi .chd .m3u"
```

**naomi:**
```
ROM files extensions accepted: ".lst .bin .dat .zip .7z"
```

**naomi2:**
```
ROM files extensions accepted: ".zip .7z"
… add the naomi2.zip file to your bios/dc directory.
```

**atomiswave:**
```
ROM files extensions accepted: ".lst .bin .dat .zip .7z"
```

---

## Fightcade expected tree (SETUP)

```
ROMs/flycast/
├── atomiswave/     ← .zip only (in SETUP)
├── data/           ← BIOS/boot here (.zip + dc_boot*.bin)
├── dreamcast/      ← mostly .chd (+ some .zip)
├── naomi/          ← .zip carts; GD titles = shortname.zip + shortname/*.chd
└── naomi2/         ← same pattern as naomi/
```

---

## Extension / layout comparison

| Content | Batocera expectation | Fightcade SETUP | Symlink-friendly? |
|---------|----------------------|-----------------|-------------------|
| Dreamcast games | `roms/dreamcast/` — `.cdi .cue .gdi .chd .m3u` (often multi-file cue/gdi sets) | `flycast/dreamcast/` — primarily **`.chd`** (full titles in SETUP) | **Weak** — `.chd` overlaps; cue/gdi/m3u layout is Batocera-centric, not Fightcade’s flat CHD pool |
| Naomi carts | `roms/naomi/` — `.zip .7z` (+ `.lst .bin .dat`) | `flycast/naomi/*.zip` | **Partial** for `.zip` only |
| Naomi GD-ROM | Not called out as separate dir in `_info`; typically zip + CHD handling differs by emulator | `flycast/naomi/<game>/*.chd` + parent `<game>.zip` | **No** — Batocera doesn’t use this nested Fightcade pairing as the stock layout |
| Naomi 2 | `roms/naomi2/` — `.zip .7z`; BIOS in `bios/dc/naomi2.zip` | `flycast/naomi2/` + BIOS in `flycast/data/naomi2.zip` | **No** for BIOS path; games only partial |
| Atomiswave | `roms/atomiswave/` — `.zip .7z` (+ lst/bin/dat) | `flycast/atomiswave/*.zip` | **Partial** for `.zip` |
| BIOS / boot | `/userdata/bios/dc/` (`naomi.zip`, `awbios.zip`, `dc_boot.bin`, …) | `flycast/data/` (same kind of files) | **No** — different location; would need a second link/copy into Fightcade `data/` |

---

## BIOS: Batocera vs Fightcade

On this host, `/userdata/bios/dc/` already contains Fightcade-like BIOS names, including:

`awbios.zip`, `naomi.zip`, `naomi2.zip`, `naomigd.zip`, `airlbios.zip`, `hod2bios.zip`, `f355bios.zip`, `f355dlx.zip`, `dc_boot.bin`, `dcjp.zip`, `dcfish.zip`, …

Fightcade wants those under **`ROMs/flycast/data/`** (SETUP), not under Batocera `bios/dc`.

So even if game dirs were linked, BIOS would still need a separate copy/symlink/override into Fightcade’s `data/`.

---

## Why “just symlink Batocera Flycast” fails

1. **Four Batocera paths** → **one** Fightcade `flycast/` root with fixed child names.
2. Dreamcast `_info` allows multi-disc / cue-sheet sets Fightcade’s folder doesn’t use the same way.
3. Naomi/AW `_info` allow `.lst .bin .dat .7z` that Fightcade SETUP doesn’t use.
4. Fightcade Naomi GD needs **`shortname.zip` + `shortname/chd`** pairing; stock Batocera `_info` does not describe that tree.
5. BIOS lives in `bios/dc` on Batocera vs `flycast/data` in Fightcade.
6. Same Flatpak sandbox issue as FBNeo: host symlinks need filesystem override or bind-mount.

---

## Practical takeaway

- **Do not** expect to point Fightcade `ROMs/flycast` at a single Batocera roms folder.
- Closest future experiment (still not “just symlink”): per-subdir links + BIOS link, e.g. `flycast/atomiswave` → `roms/atomiswave`, **if** those dirs are pure Fightcade-compatible `.zip` sets — and still grant Flatpak access. Dreamcast/Naomi GD remain the hard cases.
- For now (user has no Flycast Fightcade focus): treat Flycast as **SETUP copy into seeded `ROMs/flycast`**, not Batocera roms reuse.
