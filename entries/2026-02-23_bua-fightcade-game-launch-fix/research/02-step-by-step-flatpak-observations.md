# Step-by-Step Flatpak Fightcade Observations

## Baseline

Flatpak Fightcade has been used before on this system. Previous log data exists from prior sessions.

## Step 1: App Launched

**Processes:**
- `flatpak-bwrap` (sandbox wrapper)
- `flatpak-session-helper`, `flatpak-portal`, `flatpak-dbus-proxy` (Flatpak infrastructure)
- `/app/bin/fightcade` (wrapper script — runs wineboot, sets up dirs, launches fc2-electron)
- `fc2-electron` — main + zygote + GPU + network + renderer (same as BUA)

**Key difference from BUA:** Flatpak has its own `fightcade` wrapper script that:
1. Creates/updates wine prefix via `wineboot -u`
2. Creates writable dirs for ROMs, config, logs, savestates
3. Copies default configs
4. Launches fc2-electron via `zypak-wrapper`

**Flatpak data paths:**
- Config: `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/config/Fightcade/`
- Data: `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/`
- Logs: `.../data/logs/` (fcade.log, fcade-errors.log, flycast.log, update.log)
- Emulator configs: `.../data/config/fcadefbneo/`, `.../data/config/snes9x/`

## Step 2: Logged In + Joined KOF 2002 Room

**Processes:** Same as Step 1. No new emulator processes yet (expected).

**Existing `fcade.log` shows prior URL handler invocations:**
```
fcade://autoupdate
fcade://userstatus/stwlan/<hash>
fcade://play/fbneo/sfiii3nr1
```

This confirms the `fcade://` URL scheme is the mechanism for:
- Auto-updates
- User status updates
- **Game launch** (`fcade://play/<emulator>/<romname>`)

The `fcade-quark` script (registered as the URL handler) parses these URLs and dispatches:
- `checkrom` commands → `frm` binary (ROM manager / downloader)
- Everything else → `fcade` binary (game coordinator)

## Step 3: Test Game Clicked — WORKING

User clicked Test Game for KOF 2002. **Game launched successfully.**

**fcade.log recorded the URL:**
```
fcade://play/fbneo/kof2002
```

**New processes spawned:**
```
/bin/sh /app/fightcade/Fightcade/emulator/../../Resources/wine.sh  fcadefbneo.exe kof2002
/app/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe kof2002     (Wine running the emulator)
/app/bin/wineserver                                                 (Wine server)
C:\windows\system32\winedevice.exe                                  (Wine device, x2)
```

**The full working chain:**
1. fc2-electron opens `fcade://play/fbneo/kof2002`
2. Flatpak's registered URL handler invokes `fcade-quark`
3. `fcade-quark` calls `fcade` binary with the URL
4. `fcade` invokes `wine.sh` which sources `get-wine-prefix` and calls wine
5. Wine runs `fcadefbneo.exe kof2002`
6. Game is playing

**ROMs:** Flatpak has ROMs that were **manually installed by the user** (not auto-downloaded). Neither version auto-downloads ROMs.

### Key Takeaway

The critical path that works in Flatpak but is broken in BUA:
- `fcade://` URL → registered handler → `fcade-quark` → `fcade`/`frm` → `wine.sh` → `wine fcadefbneo.exe`

In BUA, the first link in that chain is broken: **no URL handler is registered** because `xdg-mime` doesn't exist on Batocera.
