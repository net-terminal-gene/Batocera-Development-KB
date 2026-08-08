# Research — Fightcade Flatpak file inventory + missing ROMs bug

**Host:** `batocera.local` (BATOCERA)  
**Batocera:** `43.1 2026/05/29 04:36`  
**Kernel:** `6.18.16` x86_64  
**Captured:** 2026-08-07 (SSH)  
**Flatpak app:** `com.fightcade.Fightcade` **2.4.2** (Flathub, system install)  
**App commit:** `d5238cd92d278fc74a3134d72915218b4dc7ca1fc22d029ccfd4ff00f3041aba`  
**Bundled Fightcade VERSION.txt:** `2.1.45`  
**Out of scope:** CRT / Switchres / BUA Wine Fightcade add-on

---

## Bug (documented)

### Symptom

After installing Fightcade from Flatpak and refreshing ES (`batocera-flatpak-update`), there is **no usable host-side ROMs directory** to drop games into. The path operators need only appears after a first-run dance, and it lives under a **hidden** `.var` tree.

### Operator workaround (reported)

1. Open Ports → Fightcade (ES Flatpak system)
2. Sign in
3. Join a room → press TEST
4. Exit the app
5. F1 → View → Show Hidden
6. Browse to:

```
/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs
```

### Root cause [Inference from launcher script + host state]

1. **Persistent ROMs are created only at first launch** by the Flatpak entrypoint `/app/bin/fightcade` (`DATADIR=/var/data`):

```sh
mkdir -p ${DATADIR}/ROMs/fbneo
mkdir -p ${DATADIR}/ROMs/ggpofba
mkdir -p ${DATADIR}/ROMs/snes9x
mkdir -p ${DATADIR}/ROMs/flycast
```

2. Inside the sandbox, `/var/data` is the app’s persistent data. On Batocera that maps to the host path:

```
/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/
```

3. **Install + `batocera-flatpak-update` do not create that tree.** They only install the Flatpak binaries and write the ES `.flatpak` stub.

4. The **ROMs folder inside the read-only app bundle** is not a place to put ROMs. Its own `README.txt` says so; it only holds shortcuts (symlinks) to `/var/data/ROMs/...`, which do not exist on the host until first launch.

5. Even after first launch, the path is under **`.var`**, so Batocera’s F1 file manager hides it unless Show Hidden is on.

### Host state at capture (critical)

| Path | State |
|------|--------|
| Flatpak app installed | **YES** (`flatpak list` shows Fightcade 2.4.2) |
| ES launcher stub | **YES** `/userdata/roms/flatpak/Fightcade.flatpak` |
| Host persistent data `.var/app/com.fightcade.Fightcade/` | **MISSING** |
| Host `.../data/ROMs` | **MISSING** (`ROMs_NO`) |

[Inference] This machine has Flatpak Fightcade installed but the app entrypoint has not yet successfully created its sandbox data tree (or the tree was removed). That matches “ROMs folder missing after download.”

---

## Path map (sandbox ↔ host)

| Role | Sandbox path | Host path (Batocera) |
|------|--------------|----------------------|
| Flatpak system install root | (installation) | `/userdata/saves/flatpak/binaries` |
| Flatpak user/home for apps | `$HOME` for flatpak runs | `/userdata/saves/flatpak/data` |
| App persistent data | `/var/data` | `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data` |
| Writable ROMs root | `/var/data/ROMs` | `.../data/ROMs` (**created on first launch**) |
| FBNeo ROMs | `/var/data/ROMs/fbneo` | `.../data/ROMs/fbneo` |
| FC1 / ggpofba ROMs | `/var/data/ROMs/ggpofba` | `.../data/ROMs/ggpofba` |
| SNES9x ROMs | `/var/data/ROMs/snes9x` | `.../data/ROMs/snes9x` |
| Flycast ROMs | `/var/data/ROMs/flycast` | `.../data/ROMs/flycast` |
| Config / logs / wine | `/var/data/config`, `/var/data/logs`, `/var/data/wineprefixes` | same under host `.../data/` |

Batocera Flatpak installation reported by `flatpak --installations`:

```
/userdata/saves/flatpak/binaries
```

---

## Inventory — every Fightcade-related path found

### A. EmulationStation / Ports entry (visible to user)

| Path | Type | Notes |
|------|------|--------|
| `/userdata/roms/flatpak/` | dir | ES system `flatpak` (`es_systems.cfg` group `ports`) |
| `/userdata/roms/flatpak/Fightcade.flatpak` | file | Contents: `com.fightcade.Fightcade` (app id stub) |
| `/userdata/roms/flatpak/images/Fightcade.png` | file | Icon copied by `batocera-flatpak-update` |
| `/userdata/roms/flatpak/_info.txt` | file | Generic Flatpak system help text |
| `/userdata/roms/flatpak/data/` | dir | Empty; created by `batocera-flatpak-update` (`mkdir -p`) |
| `/userdata/roms/flatpak/gamelist.xml` | — | **Not present** at capture |

ES system definition (stock): path `/userdata/roms/flatpak`, extension `.flatpak`, emulator `flatpak`.

Launch path (configgen): `flatpak run -v <romId>` where romId is read from the `.flatpak` file.

### B. Flatpak install / binaries (read-only app)

Base:

```
/userdata/saves/flatpak/binaries/app/com.fightcade.Fightcade/
```

Active deploy (resolved):

```
/userdata/saves/flatpak/binaries/app/com.fightcade.Fightcade/x86_64/stable/active
→ .../d5238cd92d278fc74a3134d72915218b4dc7ca1fc22d029ccfd4ff00f3041aba
```

| Path | Notes |
|------|--------|
| `.../active/files/bin/fightcade` | **Flatpak entrypoint** — creates `/var/data/ROMs/*`, wine prefix, configs, then boots electron |
| `.../active/files/bin/fcade-quark` | Replay / `fcade://` helper |
| `.../active/files/bin/xdg-open` | Bundled shim |
| `.../active/files/fightcade/Fightcade/` | Main Fightcade tree inside app |
| `.../active/files/fightcade/Fightcade/VERSION.txt` | `2.1.45` |
| `.../active/files/fightcade/Fightcade/Fightcade2.sh` | Upstream Linux launcher (not the Flatpak entrypoint) |
| `.../active/files/fightcade/Fightcade/Fightcade.desktop` | Desktop file inside app |
| `.../active/files/fightcade/Fightcade/fcade-upd` / `fcade-upd.sh` | Updater |
| `.../active/files/fightcade/Fightcade/wine.sh` | Wine helper |
| `.../active/files/fightcade/Fightcade/fc2-electron/` | Electron frontend |
| `.../active/files/fightcade/Fightcade/emulator/` | Emulators + JSON indexes |
| `.../active/files/fightcade/Fightcade/ROMs/` | **Shortcuts only** (see below) |
| `.../active/export/share/applications/com.fightcade.Fightcade.desktop` | Exported desktop |
| `.../active/export/share/applications/com.fightcade.Fightcade.fcade-quark.desktop` | `fcade://` mime handler |
| `.../active/export/share/icons/hicolor/{64,128,256}x256/apps/com.fightcade.Fightcade.png` | Icons |
| `.../active/export/share/metainfo/com.fightcade.Fightcade.metainfo.xml` | AppStream |
| `.../active/export/bin/com.fightcade.Fightcade` | Export wrapper |

Exports also mirrored under:

```
/userdata/saves/flatpak/binaries/exports/...
```

Repo refs:

```
/userdata/saves/flatpak/binaries/repo/refs/remotes/flathub/app/com.fightcade.Fightcade
/userdata/saves/flatpak/binaries/repo/refs/heads/deploy/app/com.fightcade.Fightcade
/userdata/saves/flatpak/binaries/repo/refs/remotes/flathub/runtime/com.fightcade.Fightcade.Locale
```

Locale runtime:

```
/userdata/saves/flatpak/binaries/runtime/com.fightcade.Fightcade.Locale/
```

### C. App-bundled `ROMs/` (NOT where user ROMs go)

```
.../files/fightcade/Fightcade/ROMs/
├── README.txt          # "THE ROMS DON'T GO HERE!!!!!!!!!!!!!!!"
├── FBNeo ROMs      → ../emulator/fbneo/ROMs/   → /var/data/ROMs/fbneo
├── FC1 ROMs        → ../emulator/ggpofba/ROMs/ → /var/data/ROMs/ggpofba
├── Flycast ROMs    → ../emulator/flycast/ROMs/ → /var/data/ROMs/flycast
└── SNES9x ROMs     → ../emulator/snes9x/ROMs/  → /var/data/ROMs/snes9x
```

These live in the **read-only** Flatpak app filesystem. Symlink targets under `/var/data/...` only resolve after the entrypoint creates them.

### D. Emulator trees (app) — writable targets are symlinks into `/var/data`

#### `emulator/fbneo/`

| Item | Target / note |
|------|----------------|
| `ROMs` | → `/var/data/ROMs/fbneo` |
| `config` | → `/var/data/config/fcadefbneo` |
| `fbneo-training-mode` | → `/var/data/fbneo-training-mode` |
| `fightcade` | → `/var/data/config/fcadefbneo/fightcade` |
| `savestates` | → `/var/data/config/fcadefbneo/savestates` |
| `fcadefbneo.exe`, `fcv39.exe`, DLLs | real files in app |
| `fbneo-training-mode-original/`, `savestates_orig/`, `support/`, `ui/` | real dirs in app |

#### `emulator/snes9x/`

| Item | Target / note |
|------|----------------|
| `ROMs` | → `/var/data/ROMs/snes9x` |
| `Saves` | → `/var/data/config/snes9x/Saves` |
| `fcadesnes9x.conf` | → `/var/data/config/snes9x/fcadesnes9x.conf` |
| `Valid.Ext`, `stdout.txt`, `stderr.txt` | → under `/var/data/config/snes9x/` |
| `fcadesnes9x.exe`, default conf, `ggponet.dll` | real files |

#### `emulator/flycast/`

| Item | Target / note |
|------|----------------|
| `ROMs` | → `/var/data/ROMs/flycast` |
| `data` | → `/var/data/config/flycast/data` |
| `emu.cfg` | → `/var/data/config/flycast/emu.cfg` |
| `mappings` | → `/var/data/config/flycast/mappings` |
| `flycast.log` | → `/var/data/logs/flycast.log` |
| `flycast.elf`, `data_orig/`, `replays/`, `training/` | real |

#### `emulator/ggpofba/`

| Item | Target / note |
|------|----------------|
| `ROMs` | → `/var/data/ROMs/ggpofba` |
| `ggpofba-ng.exe`, `config/`, `savestates/` | real |

#### `emulator/` shared logs / JSON (symlinks into `/var/data`)

Examples (all → `/var/data/...`):

- `fcade.log`, `fcade.log.1`–`.3`, `fcade-errors.log` → `/var/data/logs/...`
- `fbneo_roms.json`, `fbneo_*_roms.json`, `fc1_roms.json`, `flycast_roms.json`, `snes9x_roms.json`, `nulldc_roms.json` → `/var/data/*.json`
- Top-level `update.log`, `update-errors.log` → `/var/data/logs/...`

Real binaries also under `emulator/`: `fcade`, `fcade.sh`, `frm`, `proton.sh`.

### E. Flatpak user data home (present) vs Fightcade sandbox data (missing)

Present under `/userdata/saves/flatpak/data/` at capture:

```
/userdata/saves/flatpak/data/
├── .cache/.flatpak-helper/monitor/   # seeded by batocera-flatpak-update
├── .config/glib-2.0/settings/
└── .local/share/flatpak/appstream/.../icons/.../com.fightcade.Fightcade.png
```

**Missing (bug surface):**

```
/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/
```

Expected after first successful `fightcade` entrypoint run:

```
/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/
├── ROMs/
│   ├── fbneo/
│   ├── ggpofba/
│   ├── snes9x/
│   └── flycast/
├── config/          # fcadefbneo, snes9x, flycast, ...
├── logs/
├── wineprefixes/    # created by wineboot in entrypoint
├── fbneo-training-mode/
└── *.json           # rom index files (as written/downloaded)
```

### F. Desktop exports (host-visible copies)

```
/userdata/saves/flatpak/binaries/exports/share/applications/com.fightcade.Fightcade.desktop
/userdata/saves/flatpak/binaries/exports/share/applications/com.fightcade.Fightcade.fcade-quark.desktop
/userdata/saves/flatpak/binaries/exports/share/icons/hicolor/*/apps/com.fightcade.Fightcade.png
/userdata/saves/flatpak/binaries/exports/bin/com.fightcade.Fightcade
/userdata/saves/flatpak/binaries/exports/share/metainfo/com.fightcade.Fightcade.metainfo.xml
```

Main desktop Exec:

```
/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=fightcade com.fightcade.Fightcade
```

`fcade-quark` desktop: `MimeType=x-scheme-handler/fcade`, `NoDisplay=true`.

### G. Related Flatpak runtimes pulled for Fightcade (host)

Under `/userdata/saves/flatpak/binaries/runtime/`:

- `com.fightcade.Fightcade.Locale`
- `org.freedesktop.Platform` (+ Locale, codecs-extra, GL.default)
- `org.freedesktop.Platform.Compat.i386`
- `org.freedesktop.Platform.GL32.default`
- `org.winehq.Wine.gecko`
- `org.winehq.Wine.mono`

Manifest notes: base `org.winehq.Wine` stable-25.08; runtime `org.freedesktop.Platform/x86_64/25.08`; command `fightcade`; sockets `x11` + `pulseaudio`; `USE_DXVK=false`.

### H. Batocera helpers that touch Flatpak (not Fightcade-specific)

| Path | Role |
|------|------|
| `/usr/bin/batocera-flatpak-update` | Lists apps, writes `/userdata/roms/flatpak/<Name>.flatpak`, copies icons, seeds `.cache/.flatpak-helper/monitor` |
| `/usr/bin/flatpak` | Flatpak 1.12.9 |
| `/etc/profile.d/flatpak.sh` | Adds Flatpak exports to `XDG_DATA_DIRS` |
| `configgen` `flatpakGenerator.py` | Runs `flatpak run -v <romId>` |

`batocera-flatpak-update` does **not** pre-create `.var/app/com.fightcade.Fightcade/data/ROMs`.

### I. Not present (checked)

| Path | Result |
|------|--------|
| `/userdata/saves/flatpak/data/.var/app/` | does not exist |
| `/userdata/system/flatpak` | does not exist |
| `/var/lib/flatpak` | does not exist (Batocera uses `/userdata/saves/flatpak/binaries`) |
| `/userdata/roms/ports/*fight*` | none |
| Flatpak override for `com.fightcade.Fightcade` | empty (`flatpak override --show` blank) |

---

## Entrypoint excerpt (evidence for ROMs mkdir)

From host copy of `/app/bin/fightcade`:

```sh
DATADIR=/var/data
# ...
mkdir -p /var/data/logs
# ...
# Create persistent ROM folders if they don't exist
mkdir -p ${DATADIR}/ROMs/fbneo
mkdir -p ${DATADIR}/ROMs/ggpofba
mkdir -p ${DATADIR}/ROMs/snes9x
mkdir -p ${DATADIR}/ROMs/flycast
# ... also seeds config/, wine prefix, then:
/app/bin/zypak-wrapper /app/fightcade/Fightcade/fc2-electron/fc2-electron --disable-gpu-sandbox --no-sandbox
```

So: **any first successful launch of the Flatpak command `fightcade` should create the host ROMs tree** — room TEST is likely just one way operators force a full launch, not a special Fightcade “create ROMs” API.

---

## Why the folder is hard to find even after it exists

1. Host path contains **`.var`** (dot-directory) → hidden in F1 unless Show Hidden.
2. Path is deep under `/userdata/saves/flatpak/data/`, not under `/userdata/roms/`.
3. App-bundled `.../Fightcade/ROMs` looks like the right place but is read-only shortcuts.

---

## Fix directions (not implemented; for plan.md)

1. Pre-seed after install / in `batocera-flatpak-update` (Fightcade-specific or generic):

   `mkdir -p /userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/{fbneo,ggpofba,snes9x,flycast}`

2. Symlink a **visible** bridge, e.g. `/userdata/roms/flatpak/data/Fightcade-ROMs` → the `.var/.../ROMs` tree (note: `/userdata/roms/flatpak/data/` already exists empty).

3. Document the real host path in ES / Ports help (still leaves discoverability pain).

4. Optional: one-shot `flatpak run --command=fightcade ...` headless seed (heavier; also creates wine prefix).

---

## SSH commands used

```bash
flatpak list | grep -i fight
flatpak info com.fightcade.Fightcade
flatpak info -m com.fightcade.Fightcade
find /userdata -iname *fightcade*
find /userdata -path *com.fightcade*
ls -la /userdata/roms/flatpak/
cat /userdata/roms/flatpak/Fightcade.flatpak
test -d /userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs
# inspected .../files/bin/fightcade and .../Fightcade/ROMs/
```
