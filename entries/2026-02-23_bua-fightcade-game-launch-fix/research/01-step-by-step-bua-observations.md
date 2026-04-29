# Step-by-Step BUA Fightcade Observations

## Baseline (before launch)

- No Fightcade processes running
- No `/usr/bin/wine` symlink exists
- No `/userdata/system/logs/fightcade.log` file exists
- No emulator logs in `/userdata/system/add-ons/fightcade/Fightcade/emulator/`
- No wine prefix at `/userdata/system/add-ons/fightcade/.wine`

## Step 1: App Launched (pre-login)

Launched from Ports menu via emulatorlauncher.

**Processes:**
- `emulatorlauncher` (Python) — launched the port script
- `sym_wine.sh` (PID 5894) — running in background, symlink created
- `fc2-electron` — main process + zygote + GPU + network + renderer

**Wine symlink:** Active
```
/usr/bin/wine -> /userdata/system/add-ons/fightcade/usr/bin/wine
```

**Log output:**
```
Mon Feb 23 08:24:06 PM MST 2026: Launching Fightcade
Creating symlink: /usr/bin/wine -> /userdata/system/add-ons/fightcade/usr/bin/wine
Fightcade exited.
Symlink created. Monitoring fc2-electron process...
fc2-electron is running.
```

**Note:** "Fightcade exited" appears because `Fightcade2.sh` launches `fc2-electron` with `&` (background) and then the script itself exits. This is expected — `sym_wine.sh` keeps running and monitors fc2-electron separately.

**Status:** Normal. UI visible on screen.

## Step 2: Logged In

No change from Step 1. Same processes, no new log entries (only sym_wine polling). Login succeeded.

**Status:** Normal.

## Step 3: Joined KOF 2002 Game Room

User clicked "Join" CTA for The King Of Fighters 2002.

**Processes:** Identical to Step 2 — no new processes spawned. No `fcade`, no `wine`, no `fbneo`.

**Log:** Only sym_wine polling ("fc2-electron is running.") — no game-launch-related entries.

**Emulator logs:** None created.

**ROMs directory:** Empty — `fbneo/ROMs/` contains no files. KOF 2002 ROM was not auto-downloaded.

**ROMs directory structure:**
```
Fightcade/ROMs/
  FBNeo ROMs -> ../emulator/fbneo/ROMs/   (empty)
  FC1 ROMs   -> ../emulator/ggpofba/ROMs/ (empty)
  Flycast ROMs -> ../emulator/flycast/ROMs/ (empty)
  SNES9x ROMs -> ../emulator/snes9x/ROMs/ (empty)
  README.txt
```

**Key observation:** Joining a room does not trigger any download or emulator activity. No ROM auto-download occurred. The game launch happens when you click Play/Challenge.

## Step 4: Clicked "Test Game" — SILENT FAILURE

User clicked "Test Game" CTA in the KOF 2002 room. **Nothing happened.**

**Processes:** Identical to Step 3. No `fcade`, no `wine`, no `fbneo` spawned. Nothing new at all.

**Log:** No new entries. Only sym_wine polling.

**Emulator logs:** None created.

**ROMs:** Still empty. No download attempted.

**Wine prefix:** Still doesn't exist.

**Recently modified files:** Only Electron cache files (`.config/Fightcade/Cache/`).

### Root Cause Identified: Missing `fcade://` URL Handler

When you click "Test Game", `fc2-electron` opens a `fcade://` URL. This URL must be handled by a registered scheme handler that invokes the `fcade` binary (the game coordinator).

**The handler registration requires `xdg-mime`, which does not exist on Batocera:**
```
which xdg-mime  -> (not found)
which xdg-open  -> (not found)
ls /usr/bin/xdg-* -> (nothing)
```

**In `Fightcade2.sh`, the handler registration is gated:**
```bash
if [ -x /usr/bin/xdg-mime ]; then
    mkdir -p ~/.local/share/applications/
    # ... creates fcade-quark.desktop with MimeType=x-scheme-handler/fcade
    xdg-mime default fcade-quark.desktop x-scheme-handler/fcade
fi
```

Since `xdg-mime` doesn't exist, this block is skipped entirely. No `fcade-quark.desktop` was created. Result: `fc2-electron` sends `fcade://` URLs into the void.

### How Flatpak Solves This

Flatpak registers its own `fcade://` handler via the Flatpak export system:
- Desktop file: `com.fightcade.Fightcade.fcade-quark.desktop`
- Exec: `/usr/bin/flatpak run --command=fcade-quark com.fightcade.Fightcade %U`
- The `fcade-quark` script parses the URL, calls `frm` (for ROM checks) or `fcade` (for game launch)

Key: Flatpak's `fcade-quark` wrapper also handles ROM downloads via `frm` (the Fightcade ROM manager binary), which is invoked when the URL contains `checkrom`.
