# Research — Fightcade Flatpak HD Video Settings

## Config path resolution (snes9x)

- snes9x reports at launch: `Reading config file Z:\app\fightcade\Fightcade\emulator\snes9x\fcadesnes9x.conf.` (wine `Z:` = `/`).
- That path is a **symlink** into writable app-data:
  ```
  .../emulator/snes9x/fcadesnes9x.conf -> /var/data/config/snes9x/fcadesnes9x.conf
  ```
  which resolves on the host to
  `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/config/snes9x/fcadesnes9x.conf`.
- The flatpak app tree is deployed **writable** under
  `/userdata/saves/flatpak/binaries/app/com.fightcade.Fightcade/x86_64/stable/<hash>/files/fightcade/Fightcade/`.
- Alongside the active conf sits `fcadesnes9x.default.conf` — the pristine template. Its `Lock` line carries the authoritative comment (below).

## Stock defaults vs patched (snes9x)

From `fcadesnes9x.default.conf` on device:

| Key | Stock default | After patch/preset | Why |
|-----|---------------|--------------------|-----|
| `Fullscreen:Enabled` | `FALSE` | `TRUE` | stock launches windowed |
| `Fullscreen:Width` / `Height` | `640` / `480` | detected panel res | native resolution |
| `Fullscreen:EmulateFullscreen` | `TRUE` | `TRUE` (preset) | borderless fullscreen under wine |
| `HideMenu` | `FALSE` | `TRUE` (preset) | hide menu bar during play |
| `Stretch:AspectRatioBaseWidth` | `256` (~8:7) | `299` (preset) | correct 4:3 aspect |
| `Vsync` | `FALSE` | `TRUE` | stop tearing |
| `[Config] Lock` | `FALSE` | **`FALSE`** (was wrongly `TRUE`) | allow snes9x to save changes |

Authoritative `Lock` semantics (verbatim from `default.conf`):

> `Lock          = FALSE  # if true, prevents Snes9x from editing this configuration file (or making it read-only while it is running)`

## Preset coverage (why the patcher can be trimmed)

- `hd/presets/fcadefbneo.ini` already ships: `bVidCorrectAspect 1`, `bVidVSync 1`, `bVidFullStretch 0`, `bVidAutoSwitchFull 0`, `bVidDX9WinFullscreen 0`, `bVidArcaderesHor/Ver 0`, `bMonitorAutoCheck 1`, `bVidTripleBuffer 1`, `nWindowPosX/Y 0`. Only `nVid{Hor,Ver}{Width,Height}` (hardcoded 1920x1080) are panel-specific.
- `hd/presets/flycast/emu.cfg` already ships `fullscreen = yes` and `rend.vsync = yes`. Only `width`/`height` are panel-specific.
- `hd/presets/fcadesnes9x.conf` ships all video/aspect/menu values; only resolution + `Lock` repair matter at patch time.
- **ggpofba** ships **no** preset, so its `patch_ggpofba_hd_ini` (vsync + triple buffer) remains the sole source and is left intact.

## Install-time behavior

- `install_hd_preset()` copies a preset **only if the destination does not exist**. Fresh install = preset copied then patched (seds redundant but harmless). Upgrade over an existing file = preset NOT copied, so the retained seds (resolution, fullscreen, vsync, `Lock=FALSE`) are what correct/repair the live file.
- `patch-hd-video.sh` runs from `install.sh` (HD path) only; the game-hook does not call it per launch.
