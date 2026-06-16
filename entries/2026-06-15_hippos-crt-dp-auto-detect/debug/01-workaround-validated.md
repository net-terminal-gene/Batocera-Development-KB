# Workaround validated on hardware — 2026-06-15

## Goal

Get `hippos.local` (v0.4.17, Navi 32, DP-1 + DP-to-VGA DAC) displaying correctly on 15 kHz CRT before patching `hippos-linux`.

## Steps applied

```bash
ssh root@hippos.local
hippos-settings set crt.enabled true
hippos-crt-setup
# optional: sed -i 's/interlace_force_even      0/interlace_force_even      1/' /etc/switchres.ini
update-grub   # via hippos-upgrade if dropin unchanged but grub.cfg stale
reboot
```

**Note:** HippOS does not use `batocera-save-overlay`. Root is overlayfs with upper in btrfs `@overlay` (persists automatically). GRUB lives on rw vfat `/boot/efi` — no `mount -o remount,rw /boot` needed on this box.

## Before

| Check | Value |
|-------|-------|
| `crt.enabled` | `auto` |
| Active mode | `640x480` DoubleScan @ ~60 kHz horizontal (~31 kHz class) |
| `/proc/cmdline` | No `video=` or `drm.edid_firmware` |
| User-visible | Garbled / wrong on 15 kHz CRT |

## After reboot

| Check | Value |
|-------|-------|
| `crt.enabled` | `true` (persisted in `/userdata/system/hippos.conf`) |
| Active mode | `641x480i` @ 15.78 kHz interlaced |
| `/proc/cmdline` | `video=DP-1:640x480ieS drm.edid_firmware=DP-1:edid/crt.bin` |
| GRUB | Params in `/boot/efi/grub/grub.cfg` |
| User-visible | **PASS** — ES menu readable on CRT (operator confirmed) |

### xrandr verbose (post-reboot)

```
641x480i (0x47) 13.160MHz -HSync -VSync Interlace *current +preferred
        h: width 641 ... clock 15.78KHz
        v: height 480 ... clock 60.57Hz
```

Comparable to Batocera working output (`641x480i` @ 15.75 kHz).

## Still failing after workaround

- `DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini` → **segfault (139)**
- `crt.enabled=auto` still broken for DP-1 (not tested post-workaround; root cause unchanged)
- `hippos-crt-setup` resets `interlace_force_even=0` on DCN when re-run from `hippos-display-setup` (output still OK on this hardware)

## Next

Patch `hippos-linux` so auto + DP works without manual `crt.enabled=true`. Fix switchres apply segfault for in-game mode switching.
