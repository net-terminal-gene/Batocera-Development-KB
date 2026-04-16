# Research — Mode Switcher Empty Backups

## SSH Verification (2026-04-06)

System: Batocera v43, CRT mode active.

### Live System State

| Check | Result |
|-------|--------|
| `videomodes.conf` exists | YES (CRT mode confirmed) |
| `global.videomode` in `batocera.conf` | **NOT FOUND** |
| `global.videooutput` in `batocera.conf` | **NOT FOUND** |
| `batocera-resolution currentMode` | **Empty** |
| `batocera-resolution listOutputs` | **Empty** |
| `backup.file` (CRT install marker) | `2026.04.03,18.12.48` |

### Backup Directory State

```
mode_backups/
├── crt_mode/    ← directory exists (created 2026-04-03), contains 0 files
└── hd_mode/     ← directory exists (created 2026-04-03), contains 0 files
```

All four critical backup files are missing:
- `crt_mode/video_settings/video_mode.txt` — NOT FOUND
- `crt_mode/video_settings/video_output.txt` — NOT FOUND
- `hd_mode/video_settings/video_output.txt` — NOT FOUND
- `hd_mode/video_settings/video_mode.txt` — NOT FOUND

### videomodes.conf Boot_ Entries (Present)

```
641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz
769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz
1028x576.50.00061:Boot_576p 1.0:0:0 15KHz 50Hz
```

## Code Path Analysis

### `check_mandatory_configs()` (02_hd_output_selection.sh:580–611)

Sets `NEEDS_*_CONFIG=true` for any empty value. With all backup files missing and `batocera.conf` lacking `global.videomode`/`global.videooutput`, all three flags are set to `true`.

### `run_mode_switch_ui()` (02_hd_output_selection.sh:618–838)

Writes backup files at lines 780–830, but only after the user completes the full wizard (all three selections + summary confirmation). If the user cancels at any point, the files are **never written**.

### `batocera-resolution` Returning Empty

Both `currentMode` and `listOutputs` return empty strings. This tool is DRM/Wayland-based and does not function in X11 mode.

## First Complete Mode Switch Cycle (2026-04-06)

After completing the full wizard (CRT→HD→CRT round trip), backups populated correctly.

### Post-Wizard Log Evidence

```
[16:42:37]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[16:42:37]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

All three `NEEDS_*` flags were `false` on the second run — wizard skipped to summary.

### Backup File State After Full Cycle

| Backup | Files | Key Contents |
|--------|-------|--------------|
| `crt_mode/` | 25 | `video_output.txt`: DP-1, `video_mode.txt`: 769x576.50.00, full batocera.conf, overlay, syslinux, mame, retroarch |
| `hd_mode/` | 11 | `video_output.txt`: HDMI-2, batocera.conf, syslinux, es_settings, available modes/outputs |

**Conclusion:** Empty backups is confirmed as first-run behavior, not a bug.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

