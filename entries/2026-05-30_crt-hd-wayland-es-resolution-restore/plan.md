# HD Mode Wayland es.resolution Restore Fix

## Agent/Model Scope

Composer + ssh-batocera. CRT Script repo: `fix/crt-hd-wayland-es-resolution-restore` off `upstream/main`.

**Branch status (2026-06-01):** WIP committed locally as `ce2838c` (`fix(mode-switcher): sync HD es.resolution for Wayland boot`). Not pushed; not hardware-validated. Work paused — remaps fix branched separately off current `upstream/main` (`60a13c4`) to avoid mixing scopes in `03_backup_restore.sh`.

## Problem

CRT→HD mode switch (or HD reboot after switch) often lands on a **black screen** on DP-1 (ASUS VG34V ultrawide). CRT Mode (X11) on the same port works. User can recover manually via SSH (`wlr-randr`, ES restart) but the issue repeats every switch until config is hand-fixed.

Secondary confusion: user sets ES resolution to **1920x1080 Maximum** (`max-1920x1080`) in the menu, but reboot still boots at **3440x1440** because boot reads a different config file.

## Root Cause

**Wayland/HD-only failure chain** (not X11):

1. HD restore writes or leaves `es.resolution=default` in `batocera.conf` / `batocera-boot.conf` while `global.videomode` may differ or also be `default`.
2. On Wayland boot, `emulationstation-standalone` applies resolution from **`batocera-boot.conf`** only:
   ```sh
   bootresolution="$(batocera-settings-get-master -f "$BOOTCONF" es.resolution)"
   ```
3. `default` on ultrawide → **3440x1440 @ 165Hz** (monitor preferred).
4. DRM hotplug udev rule fires → `batocera-switch-screen-checker` restarts ES.
5. During restart, `wlr-randr` / `batocera-resolution listOutputs` returns empty → `Invalid output - DP-1` → black screen loop.

**HD backup inconsistency:**

| File | Observed bad state |
|------|-------------------|
| `hd_mode/video_settings/video_mode.txt` | `global.videomode=default` |
| `hd_mode/video_settings/es_resolution.txt` | missing or stale |
| `hd_mode/userdata_configs/batocera.conf` | may have explicit mode |
| Restore | uses `video_mode.txt` / `es_resolution.txt`; can restore `default` over good values |

**ES menu vs boot split:**

| Setting location | User change (1080 max) | Boot behavior |
|------------------|------------------------|---------------|
| `batocera.conf` `es.resolution` | Updated to `max-1920x1080` | Not used for initial Wayland boot |
| `batocera-boot.conf` `es.resolution` | Often stale (`3440x1440.59973` or `default`) | **Wins on reboot** |

**Backglass NONE (`global.videooutput2=none`):** logs `Invalid output - none` but is cleared by validation; **not** the black-screen cause. Optional cleanup: omit line when none.

## Solution

### Phase 1 — Mode switcher restore (primary)

In `03_backup_restore.sh` / `02_hd_output_selection.sh`:

1. On **HD backup**: always capture both `global.videomode` and `es.resolution` together from live system or `batocera-resolution currentMode`; never leave `default` if a concrete mode is known.
2. On **HD restore**: write **both** keys to `batocera.conf` and `batocera-boot.conf` (mirror existing CRT restore path for `es.resolution`).
3. If user selected `max-1920x1080` or explicit mode in mode-switcher UI, persist to `video_mode.txt` + `es_resolution.txt` + metadata `VIDEO_MODE`.
4. Before HD reboot after switch: touch `/tmp/no-hotplug` (Batocera checker skips one cycle) to reduce hotplug race on DP switcher setups.

### Phase 2 — Validation

- BC-250, DP-1, physical DP switch (HD side before reboot).
- CRT→HD switch with explicit 60Hz and with `max-1920x1080`.
- Confirm `display.log` shows `Setting resolution for 'DP-1' to '3440x1440.59973'` or `max-1920x1080`, not `default`.
- No hotplug death spiral after ES launch.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | HD backup/restore sync `es.resolution` + `global.videomode`; reject stale `default` when currentMode known |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` | UI save writes both keys; HD video mode picker updates backup sidecars |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher.sh` or restore path | Optional `/tmp/no-hotplug` before HD reboot |

## Validation

- [ ] HD backup after save: `video_mode.txt` and `es_resolution.txt` match live mode (not `default` unless intentional)
- [ ] `batocera-boot.conf` and `batocera.conf` both have same `es.resolution` after HD restore
- [ ] CRT→HD switch: picture on DP-1 without SSH recovery
- [ ] Reboot in HD: stays at chosen mode (1080 max or 1440@60), not 165Hz
- [ ] CRT→HD→CRT round-trip still restores CRT Boot_ mode
- [ ] `display.log` free of `Invalid output - DP-1` cascade after boot
