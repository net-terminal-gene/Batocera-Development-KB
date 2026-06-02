# Research — Myzar DisplayPort Hybrid Switchres

## Findings

### Boot / GPU

- `#crt=true` in boot.conf causes `amdgpu.dc=0` on RDNA4 → no DP connector unless `amdgpu.dc=1` is **last** on syslinux APPEND
- Kernel: `drm.edid_firmware=DP-1:edid/generic_15.bin`, `video=DP-1:640x480ieS`
- Progressive `640x480.60.00` for ES while kernel is interlaced → sync roll

### ES Video Mode dropdown (only showed 640×480)

- EmulationStation calls `batocera-resolution-hdmi listModes`, not `batocera-resolution`
- Fix: `batocera-resolution-hdmi-myzar.sh` routes `listModes` to CRT (`videomodes.conf`) — ~64 modes

### Per-game cfg archive

- Inspected ~1066 MAME `.cfg` files: vast majority were **only** `<video rotate="270">`
- Safe to remove; games run on `default.cfg` + driver/Switchres
- MAME auto-creates empty stub on first launch (e.g. `pacman.cfg`) — harmless
- Archive `mame-cfg-archive/` deleted 2026-05-21 after validation

### gameStop rotation bug (code)

`batocera-resolution-myzar.sh` `is_menu_mode()` originally returned false whenever `mame_running` — including for `640x480i` during exit while MAME process still alive → menu path skipped.

**Fix:** Only block menu `setMode` when `MYZAR_GAME` flag **and** MAME running; `gameStop` clears flag first.

### Symlink loss on reboot

`custom.sh` contained:

```bash
x11vnc ... &
exit 0
# myzar symlinks never reached
```

**Fix:** Move myzar block to top of `custom.sh`; `install-on-batocera.sh` prepends if missing.

### Agent testing hazards

- SSH `switchres` / `xrandr` on live display changes global mode for menu + games
- Can kill X (`Can't open display :0`) while ES still running
- **Policy:** no live timing probes on cabinet; use `display.log` read-only

### Deprecated skills (2026-05-21 doc update)

| Skill | Reason |
|-------|--------|
| `myzar-mame-rotate` | Bulk rotate 270 → pillarbox |
| `myzar-es-exit-rotation` | Duplicate setRotation; 30s exit with hybrid |
| `apply-myzar-dp-switchres.sh` | Full CRT ES boot breaks rotated menu |

## Config reference (working cabinet)

```ini
# batocera.conf
global.videooutput=DisplayPort-0
es.resolution=640x480i.60.00
display.rotate=1
mame.switchres=1
mame.videomode=default
```

```ini
# mame.ini / vertical.ini (video section)
keepaspect 0
unevenstretchx 1
super_width 1024
```

## Logs

`/userdata/system/logs/display.log` — `myzar gameStart` / `gameStop`, `setMode` lines

## Emulator test matrix

Full per-system expected timings and super-res for this cabinet: **[emulator-expected-resolutions.md](emulator-expected-resolutions.md)** (2026-05-21).
