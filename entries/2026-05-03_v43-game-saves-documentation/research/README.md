# Research — v43 game saves layout

**Primary evidence bundle (Steam ↔ ES):** **`research/steam-es-batocera-steam-update-regression.md`** — v42 vs v43 **`batocera-steam-update`** `steam_apps_dir`, upstream commit **`ab1a8b85f9`**, ES hooks, `gamelist.xml` / `*.steam` format, chmod note, v43 re-check checklist.

Captured **2026-05-03** from **batocera.local** (post-reflash v43). Commands run via `~/bin/ssh-batocera.sh`.

**Platform:** **x86_64** Batocera image only. **Not** the Zen3-specific image; do not generalize these paths to Zen3 without a separate capture.

## Build / userdata identity

| Item | Value |
|------|--------|
| Image | **x86_64** (not Zen3) |
| `batocera-version` | `43acou 2026/04/29 20:12` |
| `/userdata/system/data.version` | `43 2026/04/29 20:12` |

## Disk

| Item | Value |
|------|--------|
| `/userdata` mount | `/dev/sda2` on **ext4**, rw |
| Size (sample) | ~430G total, ~8.9G used |

## Top-level `/userdata`

Directories present: `bios`, `cheats`, `decorations`, `extractions`, `kodi`, `library`, `lost+found`, `music`, `recordings`, `roms`, `saves`, `screenshots`, `splash`, `system`, `themes`.

- **`roms`:** ~251 top-level entries (systems + special folders).
- **`.roms_base`:** **not present** (`/userdata/system/.roms_base` missing); mergerFS pin not active on this install.

## `/userdata/saves`

| Path | Role (observed) |
|------|-----------------|
| `readme.txt` / `lisez-moi.txt` | States folder holds saves and states |
| `flatpak/` | **~8.4G** — Flatpak apps + data (`binaries/`, `data/` with `.var`, `.local`, `.config`, `.cache`) |
| `steam/` | **empty** (only `.` / `..`) at capture time |
| `ports/` | present (small) |

`find /userdata/saves -maxdepth 2 -type d` showed only `saves`, `saves/flatpak`, `saves/flatpak/{binaries,data}`, `saves/ports`, `saves/steam`. **No** per-system libretro folders (e.g. `snes`, `mgba`) yet; consistent with **little or no emulator play** since reflash.

## Steam (Flatpak) under saves

- Steam client data: `/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/Steam/` (populated: `appcache`, `config`, `steamapps`, …).
- **`/userdata/saves/flatpak/data/Desktop`:** **does not exist** at capture (relevant to `batocera-steam-update` desktop scan; separate Steam↔ES topic).

**Update (documented):** upstream **`batocera-steam-update`** (v43 image) scans **`Desktop/`**; **v42 deployed script** still scans **`.../.local/share/applications`**. See **`steam-es-batocera-steam-update-regression.md`**.

## Config / settings

- `grep -iE 'storage|save|merger|roms' /userdata/system/batocera.conf`: only commented autosave example (`#snes.autosave=0`); **no** active `storage.*` lines in grep sample.
- `/userdata/system/configs/`: `bua`, `cannonball`, `chrome`, `dosbox`, `emulationstation`, `mupen64`, `retroarch`, `theforceengine` (retroarch `savefile_directory` not set in checked files yet / empty).

## Overlay / root

- `/` is **overlay** (lower squashfs + upper `overlay_root`); **`/userdata`** is normal block device, not overlay upper for the whole tree.

## v42 comparison (x86_64)

**Done:** same probe style on **v42 x86_64** (not Zen3). See **`research/v42-x86_64-snapshot.md`** for full numbers and a **delta table** vs this v43 capture.

**Caveat:** v43 data was from a **fresh reflash** on **sda**; v42 data is a **long-used** install on **NVMe**. Differences in **`du`** reflect **use**, not necessarily **version** changing paths.
