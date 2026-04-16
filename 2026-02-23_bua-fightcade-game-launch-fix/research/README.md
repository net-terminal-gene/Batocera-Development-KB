# Research — BUA Fightcade Game Launch Fix

## Findings

### BUA Installer Analysis (fightcade.sh)

- Downloads `Fightcade-linux-latest.tar.gz` from `https://web.fightcade.com/download/`
- Extracts to `/userdata/system/add-ons/fightcade/`
- Downloads Wine AppImage (wine-staging GE-Proton 8-26) to `usr/bin/wine`
- Downloads `sym_wine.sh` to manage symlink lifecycle
- Downloads JSON game definitions to emulator directory
- Creates port launcher at `/userdata/roms/ports/Fightcade.sh`

### Wine AppImage

- File: `/userdata/system/add-ons/fightcade/usr/bin/wine` (662MB ELF AppImage)
- Version: `wine-8.0-3001-g39021e609a2 (Staging)`
- Confirmed executable on Batocera (FUSE available)
- No Wine prefix has ever been created on the system

### Flatpak Version (working)

- Bundles proper Wine (wine, wine64, wineserver, winetricks) as native binaries
- lib32 directory with 32-bit libraries
- Creates versioned Wine prefix at `/var/data/wineprefixes/<wine-version>`
- `wine.sh` wrapper that sources `get-wine-prefix` before calling wine
- Sets up writable directories for ROMs, config, logs, savestates via symlinks

### Emulators (both versions identical)

- fbneo: `fcadefbneo.exe` (Windows, requires Wine)
- snes9x: `fcadesnes9x.exe` (Windows, requires Wine)
- ggpofba: `ggpofba-ng.exe` (Windows, requires Wine)
- flycast: `flycast.elf` (native Linux ELF, no Wine needed)

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

