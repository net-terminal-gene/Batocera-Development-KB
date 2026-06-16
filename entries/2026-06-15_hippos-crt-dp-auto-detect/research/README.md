# Research — HippOS CRT DP auto-detect

## Findings

SSH investigation 2026-06-15 on `hippos.local` (HippOS 0.4.17) vs `batocera.local` (Batocera + CRT Script).

See **[design/crt-boot-flow.md](../design/crt-boot-flow.md)** (boot pipeline), **[research/auto-detect-limits.md](auto-detect-limits.md)** (why auto/DAC fails), **[design/crt-es-settings-proposal.md](../design/crt-es-settings-proposal.md)** (manual ES CRT section).

### Side-by-side output

| | HippOS (broken) | Batocera (working) |
|---|---|---|
| Active mode | `640x480` DoubleScan | `641x480i` interlaced |
| Horizontal rate | ~60 kHz (31 kHz class) | 15.75 kHz |
| Pixel clock | 54 MHz DoubleScan | 13.34 MHz |
| CRT setup at boot | No (before manual run) | Yes (CRT Script installed) |
| Kernel cmdline | No `video=` / no EDID firmware | `video=DP-1:e drm.edid_firmware=DP-1:edid/ms929.bin` |
| switchres apply | Segfault (exit 139) | OK (exit 0) |

### HippOS xrandr verbose (broken state)

```
640x480 (0x47) 54.000MHz +HSync +VSync DoubleScan *current
        h: width 640 ... clock 60.00KHz
        v: height 480 ... clock 60.00Hz
```

### Batocera xrandr verbose (working)

```
641x480i (0x42) 13.340MHz -HSync -VSync Interlace *current
        h: width 641 ... clock 15.75KHz
        v: height 480 ... clock 60.00Hz
```

### DP-1 EDID

```
0 bytes /sys/class/drm/card0-DP-1/edid
status: connected
```

Zero-byte EDID is normal for CRT via DAC. HippOS auto-detect ignores DP connectors.

### Auto-detect mismatch

`hippos-display-setup` `_crt_auto_detect()`:

```bash
case "${name}" in VGA-*|DVI-I-*) ;; *) continue ;; esac
```

Only VGA/DVI-I. DP-1 never matches → setup never runs when `crt.enabled=auto`.

`hippos-crt-setup` `_auto_crt_output()` has fallback:

```bash
_connected_outputs | head -1   # would return DP-1
```

But crt-setup is gated behind display-setup's stricter detect.

### CRT setup timing

- `hippos-crt-setup` comment: "Runs as root before X starts, called from hippos-display-setup"
- Actual call site: `session-es` line 25, **after** X is running
- `hippos-xorg-setup` does not invoke crt-setup
- `hippos-xserver.service` ExecStartPost: `xrandr --auto`

Before manual diagnostic run, HippOS had:

- No `/etc/X11/xorg.conf.d/90-crt-gpu.conf`
- No `/etc/switchres.ini`
- No `/userdata/system/videomodes.conf`

### switchres segfault

```bash
switchres 640 480 60 -c -i /etc/switchres.ini    # OK (calculate)
DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini  # exit 139
hippos-resolution minTomaxResolution               # segfault in switchres
```

Binary: `/usr/bin/switchres` BuildID 94269d6af2e7cc612a720b906bf2e6da1ecd6c37

### DCN / interlace_force_even

GPU: Navi 32 (0x747E), soc21 / DCN engine. Setup wrote `interlace_force_even=0` because `_detect_dcn()` could not read `/sys/kernel/debug/dri/*/amdgpu_ip_info`.

### Batocera Xorg reference

CRT Script uses modesetting DDX with explicit Monitor section:

```
HorizSync   15-16.5
VertRefresh 49-65
Option      "DefaultModes" "False"
```

HippOS CRT config uses amdgpu OutputClass (TearFree=false) when deployed.

### Hardware note

Live SSH showed different GPUs on each host at time of test:

- `hippos.local`: Navi 32 (RX 7700/7800 XT class)
- `batocera.local`: AMD BC-250

User reports same HippOS PC works with Batocera CRT Script when flashed/swapped. Treat as same CRT signal chain (DP-1 + DAC), possibly different boot images on different machines on LAN.
