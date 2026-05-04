# Research — Fightcade Switchres CRT Integration

## Findings

### HD vs CRT detection for Fightcade gating

See **`research/01-hd-crt-gating.md`** and session **`design/README.md`** § CRT activation gates.
Userdata-only checks (`videomodes.conf`, `batocera.conf` grep) are insufficient alone.

### Fightcade Architecture on Batocera

- Installed via BUA to `/userdata/system/add-ons/fightcade/`
- Electron client (`fc2-electron`) as the UI
- Game launch via `fcade://play/<emulator>/<romname>` URL scheme
- xdg-open shim (PR #143) routes URLs to `fcade.sh`
- `fcade` binary (native Linux ELF, closed-source) orchestrates emulator launch
- Wine (GE-Proton 8-26 AppImage) runs Windows emulator executables
- `sym_wine.sh` manages `/usr/bin/wine` symlink lifecycle

### Emulators Bundled

| Emulator | Binary | Type | Blitter |
|----------|--------|------|---------|
| FBNeo | fcadefbneo.exe (32MB) | Wine | DX9 Alt (nVidSelect 4) |
| GGPO FBA | ggpofba-ng.exe (7MB) | Wine | Unknown |
| Snes9x | fcadesnes9x.exe (4MB) | Wine | Unknown |
| Flycast | flycast.elf (15MB) | Native Linux | SDL2/OpenGL |

### Switchres on System

- `/usr/bin/switchres` v2.2.1
- `libswitchres.so.2.2.1` available
- `/etc/switchres.ini` configured: `monitor ms929`, `interlace_force_even 1` (AMD APU)
- CLI-only, no daemon/socket
- `-s -l "cmd"` pattern: switch, launch, auto-restore on exit

### FBNeo `-a` Flag Failure

When FBNeo is invoked with `-a` (arcade resolution), it attempts `ChangeDisplaySettings()` via Wine to 512x224x22bpp@0Hz. Wine tries xrandr mode switch but the resolution isn't in the mode list. Error: "This is not a standard VGA resolution; please make sure it is supported."

Fix: don't use `-a`. Pre-switch with switchres and use borderless windowed fullscreen.

### MAME Database as Resolution Source

`/usr/bin/mame/mame -listxml <rom>` returns XML with `<display>` element:

```xml
<display tag="screen" type="raster" rotate="0" width="384" height="224" refresh="59.599491" />
```

Timing: 29ms per ROM lookup. 13,867 ROMs in FBNeo's database.

### FBNeo `-listextrainfo` (Alternative)

Via Wine (~1.3s): gives resolution + aspect but NOT refresh rate.

```
sfiii3nr1   384x224   4:3   0x09000001   "CPS-3"
```

### Wine Display Behavior

- No virtual desktop mode configured
- No FBNeo-specific display overrides in Wine registry
- Wine renders through X11; sees xrandr mode changes
- `bVidDX9WinFullscreen 1` (borderless windowed) avoids Wine ChangeDisplaySettings entirely
