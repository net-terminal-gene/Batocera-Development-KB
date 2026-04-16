# Research — Mode Switcher Truncated global.videomode

## Mode ID Comparison (2026-04-08)

| Source | Value |
|--------|-------|
| `batocera-resolution listModes` | `769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz` |
| `batocera.conf` (after mode switch) | `global.videomode=769x576.50.00` |
| `video_mode.txt` backup | `global.videomode=769x576.50.00` |
| ES UI > Video Mode | Shows **"Auto"** (no match found) |

## `batocera-resolution currentMode` in X11/CRT Mode

Returns **empty** — this tool is DRM/Wayland-based and does not function in X11 mode. Similarly, `batocera-resolution currentOutput` and `listOutputs` both return empty in X11 mode.

## Save Logic in `02_hd_output_selection.sh` (lines 805–830)

Priority chain when saving `video_mode.txt`:

1. **CRT mode + `batocera-resolution currentMode` returns a value** → use it (line 808–810). Intended to sync with the truncated value that `emulatorlauncher` compares against. **Fails** because `currentMode` is empty in X11.
2. **`$boot_mode_id` resolved from `get_boot_mode_id()`** → would write `769x576.50.00060` (line 811–813). **Correct value, but guarded.**
3. **Existing `video_mode.txt` backup is non-empty** → preserve it (line 821–822). **Wins** because the file was previously written by `03_backup_restore.sh`.

## Where the Stale Value Originates

`03_backup_restore.sh` line 261 captures `global.videomode` from `batocera.conf` when creating the initial backup:

```bash
grep "^global.videomode" /userdata/system/batocera.conf > "${backup_dir}/video_mode.txt" 2>/dev/null || true
```

The installer never writes `global.videomode` to `batocera.conf`, but the mode switcher's `restore_video_settings()` does — using whatever was in the backup. On the very first cycle, the backup was written from `batocera.conf` which either had no value or a truncated one. Once written, the "preserve existing" guard on line 821 prevents correction.

## Log Evidence

```
[03:17:52]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00060'
[03:17:52]: Preserving existing CRT video_mode.txt from prior backup
```

The full-precision `769x576.50.00060` was correctly resolved but discarded in favor of the stale `769x576.50.00`.

## Why the "Preserve Existing" Guard Exists

The guard on line 821 was designed to avoid losing good CRT mode data when switching from HD mode (where `batocera-resolution currentMode` would return the HD mode, not the CRT mode). The assumption: if a backup already exists, it must be correct.

**This assumption breaks when:**
1. The initial backup was written by `03_backup_restore.sh` from a `batocera.conf` value that was never correctly set by the installer
2. `batocera-resolution currentMode` always returns empty in X11 mode, so Priority 1 never fires to correct the value

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

