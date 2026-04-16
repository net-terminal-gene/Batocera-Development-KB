# Research — CRT Installer: Bootstrap global.videomode and global.videooutput

## Findings

### batocera.conf Key Behavior

`batocera-settings-get global.videomode` returns:
- The value set in `batocera.conf` if present (e.g., `CEA 4 HDMI`, `Boot_576i 1.0:0:0 15KHz 50Hz`, `769x576.50.00060`)
- Empty string if the key is absent (never set by user or installer)

`batocera-settings-set global.videomode "Boot_576i 1.0:0:0 15KHz 50Hz"` writes the friendly name.
`batocera-resolution listModes` returns friendly names from `videomodes.conf` — these are what ES shows.

### Boot_ Mode Name Format

Entries in `videomodes.conf` use the format:
```
Boot_576i 1.0:0:0 15KHz 50Hz   → 768x576 PAL 15kHz
Boot_480i 1.0:0:0 15KHz 60Hz   → 640x480 NTSC 15kHz
Boot_480i 1.0:0:0 31KHz 60Hz   → 640x480 VGA 31kHz
```
These are exactly what should be written to `global.videomode` — they're the identifiers ES uses to show the current Video Mode in System Settings.

### Truncation Source (Confirmed, from 2026-04-08 session)

The truncated value (`769x576.50.00`) originated from `batocera-resolution currentMode` being called in X11/CRT mode — a DRM/Wayland tool that returns empty in X11. The mode switcher fell back to reading `global.videomode` directly from `batocera.conf`. Since the installer never wrote it and the user set it through some other path with lower precision, the backup captured a truncated value.

With the installer writing the correct Boot_ name from the start, `batocera-resolution currentMode` is bypassed entirely for the initial backup.

### Wayland dual-boot (v43) — videooutput Impact (Confirmed, from 2026-04-08 session)

On Wayland dual-boot, `batocera.conf` ships with `global.videooutput=eDP-1`. Without the installer writing `global.videooutput=$video_output_xrandr`, ES targets the laptop screen even when X11 is on DP-1. Writing at install time fixes this for both single-boot and dual-boot.

### Mode Switcher Backup Pre-population

The mode switcher's `check_mandatory_configs()` flags settings as missing if backup files are empty or absent. Pre-populating both HD and CRT backup dirs at install time means `check_mandatory_configs()` finds all files on first run and skips the full wizard. Only the HD output prompt remains (no backup file covers it from the installer since the installer doesn't know which display to use for HD mode — that's genuinely a user choice).

### Origin of These Issues

| Issue | First Noted |
|-------|-------------|
| Missing `global.videooutput` | `2026-04-08_crt-installer-missing-videooutput` |
| Truncated `global.videomode` | `2026-04-08_crt-mode-switcher-truncated-videomode` |
| First-run re-pick | `2026-04-06_crt-mode-switcher-empty-backups` |
| Manual post-install steps | Wiki (HowTo_Wired_Or_Wireless_Connection.md) |

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

