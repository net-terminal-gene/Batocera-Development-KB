# Design — BUA Fightcade Game Launch Fix

## The Game Launch Chain

When a user clicks Test Game / Play / Challenge in the Fightcade UI, the following chain must execute:

```
fc2-electron (UI)
  │
  ├─ opens fcade://checkrom/<emulator>/<rom>     (ROM check/download)
  │    → URL handler → fcade-quark → frm binary
  │
  └─ opens fcade://play/<emulator>/<rom>          (game launch)
       → URL handler → fcade-quark → fcade binary
            → wine.sh (sets WINEPREFIX) → wine <emulator>.exe <rom>
```

## What Works in Flatpak (Reference)

### 1. URL Handler Registration

Flatpak exports a `.desktop` file via its own system:

```ini
# com.fightcade.Fightcade.fcade-quark.desktop
[Desktop Entry]
Type=Application
Name=FightCade Replay
Exec=/usr/bin/flatpak run --command=fcade-quark com.fightcade.Fightcade %U
MimeType=x-scheme-handler/fcade
NoDisplay=true
```

This registers `fcade://` as a custom URL scheme handled by `fcade-quark`.

### 2. fcade-quark Script (URL Dispatcher)

```bash
#!/bin/sh
PARAM=${1+"$@"}
export WINEDEBUG=-all

echo "======\n${PARAM}\n======" >> /var/data/fcade.log

IFS='/' read -r -a fcadecmd <<< "$PARAM"

if [ ${fcadecmd[2]} = "checkrom" ]; then
    # ROM check/download via frm
    script -a -c "/app/fightcade/Fightcade/emulator/frm ${fcadecmd[3]} ${fcadecmd[4]}" /var/data/frm.log
else
    # Game launch via fcade
    /app/fightcade/Fightcade/emulator/fcade ${PARAM} 2>&1 &
fi
```

Two code paths:
- `checkrom` → `frm` binary (Fightcade ROM Manager — checks/downloads ROMs)
- Everything else → `fcade` binary (game coordinator — launches emulators)

### 3. wine.sh Wrapper

```bash
#!/bin/sh
WINEPATH="/app/bin/wine"
. /app/bin/get-wine-prefix          # sets WINEPREFIX
/app/bin/wine "$@"
```

The `fcade` binary invokes `wine.sh` (located at `../../Resources/wine.sh` relative to the emulator dir). Observed in process list:

```
/bin/sh /app/fightcade/Fightcade/emulator/../../Resources/wine.sh fcadefbneo.exe kof2002
```

### 4. Wine Prefix Initialization

The Flatpak `fightcade` wrapper runs `wineboot -u` at every launch to create/update the prefix:

```bash
WINEPREFIX=${WINEPREFIX} WINEDEBUG=-all DISPLAY=:invalid wineboot -u
```

## What Breaks in BUA

### Chain Diagram (BUA — broken)

```
fc2-electron (UI)
  │
  └─ opens fcade://play/fbneo/kof2002
       → OS looks up x-scheme-handler/fcade
         → NOT FOUND (xdg-mime absent, no handler registered)
           → SILENT FAILURE — nothing happens
```

### Missing Components

| Component | Flatpak | BUA | Impact |
|-----------|---------|-----|--------|
| URL handler `.desktop` file | Flatpak export system | Not created (`xdg-mime` absent) | **Fatal** — fcade:// URLs go nowhere |
| `fcade-quark` dispatcher | `/app/bin/fcade-quark` | Does not exist | **Fatal** — no script to receive URLs |
| `wine.sh` wrapper | `/app/fightcade/.../Resources/wine.sh` | Does not exist | **Fatal** — `fcade` binary can't find wine wrapper |
| Wine prefix (`wineboot -u`) | Runs at every launch | Never runs | **Fatal** — Wine can't execute .exe files |
| `mimeapps.list` | Flatpak-managed | Does not exist | Part of URL handler registration |
| Writable dirs setup | Creates ROMs, config, logs, savestates dirs | Not done (but /userdata is writable) | Minor — dirs are writable by default |

### Why `Fightcade2.sh` Doesn't Help

The upstream `Fightcade2.sh` (from the tarball) tries to register the handler:

```bash
if [ -x /usr/bin/xdg-mime ]; then
    mkdir -p ~/.local/share/applications/
    # creates fcade-quark.desktop
    xdg-mime default fcade-quark.desktop x-scheme-handler/fcade
fi
```

But **`xdg-mime` does not exist on Batocera** — no `/usr/bin/xdg-mime`, no `/usr/bin/xdg-open`, no `xdg-*` binaries at all. The block is skipped entirely.

Even if `xdg-mime` existed, the `.desktop` file it creates would point to `fcade.sh` (which just calls `fcade` binary directly), not a `fcade-quark` style script that also handles `checkrom` → `frm`.

### The fcade Binary Calls wine.sh

From the Flatpak process capture, when a game launches:

```
/bin/sh /app/fightcade/Fightcade/emulator/../../Resources/wine.sh  fcadefbneo.exe kof2002
```

The `fcade` binary invokes `wine.sh` at a relative path: `../../Resources/wine.sh` from the emulator directory. In the BUA layout:

```
/userdata/system/add-ons/fightcade/Fightcade/emulator/../../Resources/wine.sh
= /userdata/system/add-ons/fightcade/Resources/wine.sh
```

This file does not exist in BUA. There is no `Resources/` directory at all.

## Fix Requirements

### 1. Create `fcade-quark` script

A URL dispatcher that receives `fcade://` URLs and routes them:
- `checkrom` → `frm` (ROM check/download)
- Everything else → `fcade` (game launch)

Must be placed where the `.desktop` file's `Exec` can find it.

### 2. Register `fcade://` URL handler

Without `xdg-mime`, manually create:
- `~/.local/share/applications/fcade-quark.desktop` (with `MimeType=x-scheme-handler/fcade`)
- `~/.local/share/applications/mimeapps.list` (with `x-scheme-handler/fcade=fcade-quark.desktop`)

Where `~` = `$HOME` = `/userdata/system/add-ons/fightcade` (as set by the port launcher).

### 3. Create `wine.sh` wrapper

Place at `/userdata/system/add-ons/fightcade/Resources/wine.sh` (the relative path `fcade` expects). Must:
- Set `WINEPREFIX`
- Call the BUA Wine AppImage (via `/usr/bin/wine` symlink or direct path)

### 4. Initialize Wine prefix

Run `wineboot -u` with proper `WINEPREFIX` and `DISPLAY` before first use. Can be done:
- During install (in `fightcade.sh`)
- At launch time (in the port script, before `Fightcade2.sh`)

Launch-time is better — matches Flatpak behavior and handles Wine upgrades.

## Affected Files

| File | Action |
|------|--------|
| `fightcade/fightcade.sh` | Add: create `fcade-quark`, `wine.sh`, `.desktop` file, `mimeapps.list`, `wineboot -u` |
| `fightcade/sym_wine.sh` | No change needed |
| Port launcher (`/userdata/roms/ports/Fightcade.sh`) | Add: Wine prefix init, URL handler registration at launch time |
