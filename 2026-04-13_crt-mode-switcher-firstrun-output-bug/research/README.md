# Research — CRT Mode Switcher: First-Run Pre-Selects eDP-1

## Findings

### Observed Behavior (2026-04-13)

- **Setup:** Fresh Batocera v43 flash → CRT-Script-04-03 Phase 1 + Phase 2 → reboot into CRT mode.
- **batocera.conf state at first Mode Switcher run:**
  - `global.videooutput = eDP-1` (never changed by installer)
  - `global.videomode = (empty)`
  - `es.resolution = 641x480.60.00000`
- **mode_backups:** Empty — no files created by installer.
- **Observed:** Mode Switcher pre-selects eDP-1 as CRT output on first run.

### Related Sessions

- `2026-04-11_crt-installer-videomode-bootstrap` — plans to pre-populate backup files including `crt_mode/video_settings/video_output.txt = DP-1`. If implemented, this bug would be eliminated via the backup file rather than requiring a mode switcher code fix.
- `2026-04-06_crt-mode-switcher-empty-backups` — documents the empty backup bug; this output pre-selection bug is a downstream consequence.
- `2026-04-08_crt-installer-missing-videooutput` — superseded by bootstrap session; same root (installer doesn't write DP-1).

### Root Cause Confirmed (2026-04-13, debug stage 06)

The mode switcher writes CRT output to **two places** using **different sources**:

| File | Source | Value | Correct? |
|------|--------|-------|----------|
| `crt_mode/video_settings/video_output.txt` | xrandr active output | `global.videooutput=DP-1` | YES |
| `crt_mode/mode_metadata.txt` → `VIDEO_OUTPUT=` | `batocera-settings-get global.videooutput` | `eDP-1` | NO |

The `mode_metadata.txt` is what the Mode Switcher **displays** to the user as the current CRT output on first run. Since `global.videooutput=eDP-1` was in batocera.conf (the Wayland/HD value — never changed by the installer), the metadata records eDP-1 as the CRT output. This is what the user sees as "eDP-1 was already picked for CRT Mode."

The actual restore file (`video_output.txt`) has the correct `DP-1` value (sourced from xrandr). So **the switch itself works correctly** — DP-1 is restored when switching HD→CRT — but the **display is wrong and misleading**.

### Fix Confirmed

Pre-populating `mode_backups/crt_mode/video_settings/video_output.txt = global.videooutput=DP-1` via the bootstrap installer (as planned in `2026-04-11_crt-installer-videomode-bootstrap`) will NOT fix this bug directly, because `mode_metadata.txt` is written from `batocera-settings-get global.videooutput` at switch time — not from the backup file. Two possible fixes:

1. **Fix the metadata source:** Change `mode_metadata.txt` `VIDEO_OUTPUT=` to read from xrandr (same source as `video_output.txt`) instead of `batocera-settings-get global.videooutput`.
2. **Write `global.videooutput=DP-1` to batocera.conf at install time (bootstrap Step 4):** Then `batocera-settings-get global.videooutput` returns `DP-1` and `mode_metadata.txt` records the correct value. This also makes the standalone display script skip the invalid-output fallback (minor improvement).

Option 2 is cleaner and aligns with the bootstrap plan. Option 1 is a targeted mode-switcher-only fix.

### Key Code Location

`Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` — handles backup read/write and first-run detection. The `VIDEO_OUTPUT=` line in `mode_metadata.txt` is written using `batocera-settings-get global.videooutput` rather than the xrandr-derived value. This is the specific line to fix.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

