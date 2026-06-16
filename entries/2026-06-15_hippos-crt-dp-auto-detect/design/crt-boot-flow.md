# CRT boot flow — intended vs actual (HippOS v0.4.17)

## ES menu vs hippos.conf

**System Settings → CRT MONITOR** only exposes:

| ES UI | hippos.conf key | Notes |
|-------|-----------------|-------|
| ENABLE CRT OUTPUT | `crt.enabled` | Toggle sets `true`/`false` only (not `auto`) |
| MONITOR PROFILE | `crt.monitor_profile` | `generic_15`, `arcade_15`, `ntsc`, etc. |

Both trigger reboot when changed.

**Not in ES** (defaults / manual `hippos.conf` only):

| Key | Default (amd64) | Role |
|-----|-----------------|------|
| `crt.boot_resolution` | `640x480i` | Menu/boot base mode; **`i` = interlaced** |
| `crt.interlace` | `true` | switchres.ini `interlace 1` |
| `crt.output` | `auto` | Connector (DP-1, VGA-1, …) |
| `crt.enabled` | `auto` on fresh flash | Auto gate in `hippos-display-setup` |

User does **not** pick resolution in ES. Profile selects timing **family** (15k/25k/31k); boot resolution and interlace come from defaults.

## Intended pipeline

```
Flash → hippos.conf defaults (crt.enabled=auto)
     → systemd: hippos-xserver (X starts)
     → hippos-es.service → session-es
     → hippos-display-setup
         → if CRT enabled/auto-detect: hippos-crt-setup
             → /etc/switchres.ini, Xorg CRT snippets, videomodes.conf
             → EDID (641×480 W+1) + GRUB video=OUTPUT:640x480ieS
         → hippos-resolution minTomaxResolution (switchres boot mode)
     → EmulationStation
     → Game launch: per-system videomode via switchres; exit restores crt.boot_resolution
```

### Boot layers

1. **Kernel** — `video=DP-1:640x480ieS` + `drm.edid_firmware=DP-1:edid/crt.bin` (after crt-setup + GRUB update + reboot)
2. **Xorg** — `90-crt-gpu.conf`, `15-crt-monitor.conf`, `10-crt-ignore.conf` (TearFree off, DefaultModes false)
3. **Session** — switchres applies refined modeline; active mode typically `641x480i` @ ~15.7 kHz

### Resolution / interlace decisions

- **Not** auto-detected from physical CRT EDID (CRTs often have none).
- **`crt.monitor_profile`** → switchres monitor preset + which `videomodes.conf_*` file is installed.
- **`crt.boot_resolution=640x480i`** → boot kernel param + session restore target; `i` suffix preserved in GRUB.
- **EDID W+1** → generated at 641×480 so kernel boot FB differs from ES session (geometry clash avoidance).

## systemd order (actual)

| Stage | Script | CRT-aware? |
|-------|--------|------------|
| Pre-X | `hippos-xorg-setup` | **No** — does not call crt-setup |
| X start | `hippos-xserver` | **No** |
| Post-X | `ExecStartPost: xrandr --auto` | **Fights CRT** |
| ES session | `hippos-display-setup` | **Yes** — crt-setup + switchres |

CRT Xorg snippets written by crt-setup take effect on **next X restart** (or next boot if `/etc` already populated).

## Fresh flash → user enables CRT in ES

| Reboot | Typical state (DP + DAC) |
|--------|------------------------|
| 1 (auto default) | crt-setup never runs → 31 kHz DoubleScan |
| 2 (user toggled CRT ON) | X starts before display-setup; GRUB may be written this session → still often wrong |
| 3 | Kernel `video=` + persisted `/etc` CRT configs → **usually works** |

Validated workaround: `crt.enabled=true` + **`hippos-crt-setup` before reboot** → works in one reboot.

## Gap summary

### Critical

1. `hippos-display-setup` auto-detect skips DP/HDMI (only VGA/DVI-I + zero EDID).
2. crt-setup runs **after** X, not in `hippos-xorg-setup`.
3. `xrandr --auto` in xserver ExecStartPost.
4. switchres segfault on subprocess apply (exit 139).

### UX / design

5. ES has no UI for `crt.output`, `crt.boot_resolution`, `crt.interlace`, or `auto`.
6. ES help text recommends VGA/DVI only; no DP-DAC guidance.
7. Monitor profile ≠ physical monitor identification.
8. Two reboots may be required — not surfaced in UI.
9. DCN `interlace_force_even` detection unreliable.

## Code map (hippos-linux)

| Concern | Path |
|---------|------|
| ES CRT toggle | `src/frontend/emulationstation/es-app/src/guis/GuiMenu.cpp` |
| Defaults / comments | `overlays/userdata/system/hippos.conf`, `overlays/rootfs-amd64/usr/share/hippos/hippos-defaults.conf` |
| Auto gate | `overlays/rootfs/usr/lib/hippos/hippos-display-setup` |
| CRT deploy | `overlays/rootfs/usr/lib/hippos/hippos-crt-setup` |
| Pre-X (empty for CRT) | `overlays/rootfs/usr/lib/hippos/hippos-xorg-setup` |
| X service | `overlays/rootfs/usr/lib/systemd/system/hippos-xserver.service` |
| ES session | `overlays/rootfs/usr/lib/hippos/session-es` |
| Game modes | `overlays/rootfs/usr/lib/hippos/hippos-resolution`, `emulatorlauncher_impl.py` |
