# Research — Batocera `roms/snes` vs Fightcade `ROMs/snes9x`

**Captured:** 2026-08-07 (SSH `batocera.local` after user populate)  
**Batocera path:** `/userdata/roms/snes`  
**Fightcade target:** `.../data/ROMs/snes9x`  
**Golden layout:** `/Volumes/Batocera/SETUP/fightcade/snes9x/`

---

## Verdict

**Yes — per-folder symlink is a good fit** for the current live `/userdata/roms/snes` contents.

That folder is now a flat Fightcade shortname `.zip` set matching SETUP `snes9x/`, not a typical Batocera display-name `.sfc`/`.7z` library.

Still subject to Flatpak host filesystem access (same as flycast/fbneo links).

---

## Batocera `_info.txt` (accepted formats)

```
ROM files extensions accepted: ".smc .fig .sfc .gd3 .gd7 .dx2 .bsx .swc .zip .7z"
```

Wiki: systems:snes  

`_info` allows many loose/cart formats. Fightcade only needs shortname `.zip` in a flat dir. The **live contents** are what matter for symlink, not the full `_info` allow-list.

---

## Live `/userdata/roms/snes` (SSH)

| Property | Value |
|----------|--------|
| Shape | Flat game files + `images/` + `videos/` |
| Approx file count | ~3447 at top level |
| Dominant format | Fightcade shortname `.zip` (`16mj.zip`, `2020bb.zip`, `aaahhrm.zip`, …) |
| Extras | `_info.txt`, one sample `DonkeyKongClassic (Shiru).smc`, ES media dirs |
| `roms/snes9x` | does not exist |

Matches SETUP sample names and scale (SETUP: **3444** `.zip`, **0** subdirs, `.zip` only).

---

## Fightcade SETUP `snes9x/`

```
snes9x/
└── *.zip    # flat, short Fightcade names, no platform subdirs
```

3444 zips; no nested folders.

---

## Comparison

| | Batocera `roms/snes` (live) | Fightcade `ROMs/snes9x` |
|--|----------------------------|-------------------------|
| Layout | Flat (+ media subdirs) | Flat |
| Naming | Fightcade shortnames | Fightcade shortnames |
| Primary ext | `.zip` | `.zip` |
| Path name | `snes` | `snes9x` | different names; symlink bridges this |

Extras Fightcade can ignore: `_info.txt`, `images/`, `videos/`, stray `.smc`.

---

## Symlink

```bash
FC_SNES=/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/snes9x
rmdir "$FC_SNES" 2>/dev/null || true
ln -s /userdata/roms/snes "$FC_SNES"
```

Requires:
1. Fightcade ROMs tree seeded (first launch or mkdir)
2. Flatpak can read `/userdata/roms/snes` (override or bind-mount)

---

## Note on `/Volumes/Batocera/roms/snes`

The share mount can show a **different** library (display-name `.7z` / `.zip` / `.smc`). Do not use that tree as the Fightcade reference; use live `batocera.local:/userdata/roms/snes`, which is the Fightcade-shaped set.
