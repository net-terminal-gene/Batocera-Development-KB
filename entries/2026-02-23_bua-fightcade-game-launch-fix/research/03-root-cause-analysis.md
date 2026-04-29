# Root Cause Analysis — BUA Fightcade Game Launch Failure

## Summary

BUA Fightcade silently fails to launch games because the `fcade://` URL scheme handler is never registered. Without it, clicking Test Game/Play/Challenge does nothing.

## The Game Launch Chain

```
User clicks "Test Game"
  → fc2-electron opens fcade://play/fbneo/kof2002
    → OS looks up x-scheme-handler/fcade
      → Registered handler invokes fcade-quark script
        → fcade-quark dispatches to fcade binary or frm binary
          → fcade invokes wine.sh → wine fcadefbneo.exe kof2002
```

## Where It Breaks (BUA)

**Link 1 is broken:** The URL scheme handler is never registered.

`Fightcade2.sh` tries to register it:
```bash
if [ -x /usr/bin/xdg-mime ]; then
    mkdir -p ~/.local/share/applications/
    # creates fcade-quark.desktop
    xdg-mime default fcade-quark.desktop x-scheme-handler/fcade
fi
```

**`xdg-mime` does not exist on Batocera.** The entire block is skipped. No handler is registered. When fc2-electron sends `fcade://` URLs, they go nowhere.

## How Flatpak Solves It

Flatpak uses its own export system to register a `.desktop` file:
```ini
[Desktop Entry]
Name=FightCade Replay
Exec=/usr/bin/flatpak run --command=fcade-quark com.fightcade.Fightcade %U
MimeType=x-scheme-handler/fcade
```

The `fcade-quark` wrapper script then dispatches:
- `checkrom` URLs → `frm` binary (downloads ROMs)
- All other URLs → `fcade` binary (launches games)

## Secondary Issues (will surface after fixing the URL handler)

1. **No Wine prefix initialized** — BUA never runs `wineboot -u`. Wine needs a prefix to run .exe files. The Flatpak version does this at every launch.

2. **No `wine.sh` wrapper** — The Flatpak has a `wine.sh` in the Fightcade directory that sources `get-wine-prefix` before calling wine. The BUA tarball does not include this file (it's Flatpak-specific).

3. **No writable directory setup** — Flatpak creates writable dirs for ROMs, configs, logs, savestates. BUA doesn't do this, but the BUA directories should be writable already since they're on /userdata.

4. **ROMs are not auto-downloaded** — Neither BUA nor Flatpak auto-downloads ROMs. The user manually installed ROMs into the Flatpak version. Even placing ROMs in the correct BUA folder does not help — the game still fails to launch because the URL handler chain is completely broken before Wine/emulators are ever invoked.

## What BUA Repo Provides (batocera-unofficial-addons/fightcade/)

| File | Purpose |
|------|---------|
| `fightcade.sh` | Installer only — downloads tarball, Wine AppImage, sym_wine.sh, JSON ROM defs, creates port launcher |
| `sym_wine.sh` | Symlinks Wine AppImage to `/usr/bin/wine`, monitors fc2-electron lifecycle |
| `fightcade_uninstall.sh` | Uninstaller |
| `extra/fightcade-logo.png` | Logo for Ports menu |

## What BUA Does NOT Provide (but Flatpak Does)

1. **No `fcade-quark` script** — nothing to handle `fcade://` URLs
2. **No URL handler registration** — no `.desktop` file, no `mimeapps.list`
3. **No `wine.sh` wrapper** — no WINEPREFIX management before calling wine
4. **No `wineboot -u`** — wine prefix never initialized
5. **No `checkrom` dispatch** — BUA's `fcade.sh` (in tarball) calls `fcade` directly without routing `checkrom` commands to `frm` (ROM manager)

The BUA installer creates a port launcher that only does two things: symlink wine and run `Fightcade2.sh`. It never sets up the infrastructure that the game launch chain requires.

## Confirmed Root Causes

1. **Primary:** Missing `fcade://` URL scheme handler registration due to absent `xdg-mime` on Batocera. No `fcade-quark` script exists to dispatch URLs.
2. **Secondary:** Missing Wine prefix initialization (`wineboot -u`) and `wine.sh` wrapper (sets WINEPREFIX).
3. **Tertiary:** No `checkrom` → `frm` dispatch for ROM auto-download.
