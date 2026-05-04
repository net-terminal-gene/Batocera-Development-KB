# v42 x86_64 snapshot (same host class as v43 doc)

Captured **2026-05-04** via `~/bin/ssh-batocera.sh` on **batocera.local** after switching the machine to **v42**.

**Platform:** **x86_64** (not Zen3), same scope label as the v43 capture.

## Build / userdata identity

| Item | Value |
|------|--------|
| `batocera-version` | `42aco 2025/10/06 14:36` |
| `/userdata/system/data.version` | `42 2025/10/06 14:36` |
| `uname -m` | `x86_64` |

## Disk

| Item | Value |
|------|--------|
| `/userdata` mount | `/dev/nvme0n1p2` on **ext4**, rw |
| Size | ~1.8T total, ~400G used, ~1.3T avail |

## mergerFS / internal pin

| Item | Value |
|------|--------|
| `/userdata/system/.roms_base` | **absent** (`no .roms_base`) |

## Overlay

- `/` overlay: **single** lower `.../overlay/base` (squashfs). (v43 capture on the other disk showed `base` + `base2`; different image line or build packaging.)

## `/userdata/saves` (high level)

Many **per-system / per-emulator** trees exist (long-term install), including for example: `3ds`, `amiga`, `amstradcpc`, `c64`, `dolphin-emu`, `dos`, `mame`, `megadrive`, `msx1`, `msx2`, `n64`, `pcenginecd`, `prboom`, `switch`, `xbox`, `CRT`, `mesa_shader_cache_db`, plus `readme.txt` / `lisez-moi.txt` / `Info.txt`.

**Sizes (sample `du -sh /userdata/saves/*`):**

| Path | Approx size |
|------|----------------|
| `flatpak/` | **389G** |
| `xbox/` | 394M |
| `mame/` | 138M |
| `3ds/` | 58M |
| `mesa_shader_cache_db/` | 1.9M |
| `switch/` | 528K |
| `dolphin-emu/` | 212K |
| `n64/` | 132K |
| `steam/` | 4K (tiny / mostly empty dir listing) |
| many others | 4K–20K |

Same **canonical layout** as Batocera docs: **`/userdata/saves`** holds flatpak + emulator saves; **`flatpak/data/.var/...`** is where Steam and other flatpaks keep app data.

## `batocera.conf` (storage grep)

- No matches for leading `storage.`, `global.save`, `global.storage`, `merger`, `roms` in the sampled grep; broader `storage|merger|roms` grep also returned **no lines** in the head sample (likely no active storage overrides, or keys use different spelling).

## Delta vs v43 capture (same project, different machines / life cycle)

| Topic | v43 snapshot (earlier KB) | v42 snapshot (this file) |
|------|---------------------------|----------------------------|
| **Build** | `43acou` 2026/04/29 | `42aco` 2025/10/06 |
| **Disk** | `/dev/sda2` ~430G, light use | `/dev/nvme0n1p2` ~1.8T, heavy use |
| **`.roms_base`** | absent | absent |
| **`saves/` emulator dirs** | essentially **none** (fresh reflash) | **many** populated dirs |
| **`saves/flatpak` size** | ~8.4G | ~389G |
| **Interpretation** | Path **model** is the same (`saves/` + `saves/flatpak/...`); difference is **age and use**, not evidence that v42 vs v43 moved the root save location on these hosts. |

For **upstream**: if the question is “did v43 change where saves live?”, these two captures alone only show **same tree, different fill state** on **two different block devices**. A fair controlled test would be **same disk**, **same ROMs/saves copy**, upgrade path **v42→v43** (or vice versa) and diff before/after.

## `batocera-steam-update` on this v42 host (SSH, 2026-05)

From **`sed -n '60,70p' /usr/bin/batocera-steam-update`** on **batocera.local** (`42aco`):

- **`steam_apps_dir="/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/applications"`**

**`/userdata/saves/flatpak/data/Desktop`:** `ls` → **No such file or directory**.

Steam↔ES regression analysis (vs v43 / upstream git): **`steam-es-batocera-steam-update-regression.md`**.
