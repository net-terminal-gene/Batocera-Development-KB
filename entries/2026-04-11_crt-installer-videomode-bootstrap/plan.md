# CRT Installer: Bootstrap global.videooutput and Mode Switcher Backups

## Agent/Model Scope

Composer + ssh-batocera for live system verification.

## Supersedes

- `2026-04-08_crt-installer-missing-videooutput` — narrower fix (videooutput only, v43 only)
- `2026-04-08_crt-mode-switcher-truncated-videomode` — downstream bandaid (patch mode switcher preserve-guard)

Both are superseded because this approach fixes the problem at the source — in the installer.

## Baseline Testing (Stages 00–09)

A full baseline test was run 2026-04-13 using **CRT-Script-04-03** (original script, no changes) on v43 hardware. See `debug/10-baseline-complete.md` for full summary.

### Key findings from baseline

1. **`global.videomode` is NOT read in the X11 CRT boot path.** The display mode comes from `es.resolution`, which the mode switcher sets on first CRT→HD switch. Writing `global.videomode=Boot_...` to `batocera.conf` is unnecessary and was the likely cause of the "no picture" during early bootstrap testing.

2. **`global.videooutput=DP-1` IS needed.** Without it, the installer leaves `eDP-1` in `batocera.conf`. On first CRT→HD mode switch, the mode switcher saves `mode_metadata.txt VIDEO_OUTPUT=eDP-1` (cosmetic bug). More critically, on v43 Wayland dual-boot, `eDP-1` in `global.videooutput` causes ES to target the laptop screen on first CRT boot.

3. **Pre-seeding `crt_mode/video_settings/video_output.txt` with `DP-1` fixes the root of the first-run output bug.** The mode switcher uses `video_output.txt` (not `mode_metadata.txt`) for actual restore operations. If this file is pre-seeded at install, the first HD→CRT restore will use `DP-1` correctly even before the first manual CRT→HD switch creates the backup naturally.

4. **The mode switcher round-trip works correctly end-to-end with the original script.** CRT mode, CRT→HD, HD mode, HD→CRT: all stages display correctly. The only issues are cosmetic (eDP-1 in metadata) and UX (blank screen when DP-1 connected in Wayland).

---

## Problem (Revised)

After running the CRT Script installer, two things are missing from `batocera.conf`:

1. `global.videooutput` is not set to the CRT output — it retains whatever was there before (typically `eDP-1` on Steam Deck / v43 systems)
2. The mode switcher backup directories are empty — the first CRT→HD switch creates them from live system state, but until then there is nothing to restore from on an HD→CRT switch

This causes:
- **v43 Wayland dual-boot:** ES targets eDP-1 (laptop screen) instead of the CRT on first boot after install, before the mode switcher has been run
- **First mode switcher run (all versions):** `mode_metadata.txt VIDEO_OUTPUT=eDP-1` — the UI shows eDP-1 as the current CRT output, which is confusing and wrong

## Root Cause

The installer already knows the CRT output at the end of setup: `$video_output_xrandr`. It just never writes it to `batocera.conf` or to the mode switcher backup directories.

## Solution (Revised — output-only, no videomode)

At the end of the installer's `batocera.conf` write block, in this order:

**Step 1 — Capture HD output before overwriting:**
```bash
_hd_videooutput=$(batocera-settings-get global.videooutput 2>/dev/null || true)
mkdir -p "${MODE_BACKUP_BASE}/hd_mode/video_settings"
echo "${_hd_videooutput}" > "${MODE_BACKUP_BASE}/hd_mode/video_settings/video_output.txt"
```

**Step 2 — Write `global.videooutput` to `batocera.conf`:**
```bash
if [ -n "$video_output_xrandr" ]; then
    sed -i '/^global\.videooutput=/d' "$file_BatoceraConf"
    echo "global.videooutput=$video_output_xrandr" >> "$file_BatoceraConf"
fi
```

**Step 3 — Pre-seed CRT output backup:**
```bash
mkdir -p "${MODE_BACKUP_BASE}/crt_mode/video_settings"
if [ -n "$video_output_xrandr" ]; then
    echo "global.videooutput=$video_output_xrandr" \
        > "${MODE_BACKUP_BASE}/crt_mode/video_settings/video_output.txt"
fi
```

### What is NOT in scope (baseline confirmed not needed)

- Writing `global.videomode=Boot_...` — not read by X11 CRT boot path; `es.resolution` is what matters, and the mode switcher sets that correctly on first switch
- Pre-seeding `crt_mode/video_settings/video_mode.txt` — the mode switcher captures this from xrandr on the first CRT→HD switch; it works even with the truncated xrandr format

## What This Closes

| Bug | How |
|-----|-----|
| ES on wrong display (v43 Wayland dual-boot, first boot) | `global.videooutput=DP-1` written at install |
| Mode switcher first-run shows `eDP-1` as CRT output in UI | `crt_mode/video_settings/video_output.txt` pre-seeded with `DP-1` |
| HD output lost on first CRT→HD switch | `hd_mode/video_settings/video_output.txt` pre-seeded with prior HD output |

## What Remains Out of Scope

| Issue | Why deferred |
|-------|--------------|
| Truncated videomode (`641x480.59.98` instead of `Boot_` name) | Confirmed functionally harmless; display works correctly with xrandr format value |
| `mode_metadata.txt VIDEO_OUTPUT=eDP-1` still shown | Metadata is informational only; `video_output.txt` is the operative file; fix belongs in mode switcher, not installer |
| xterm on extended DP-1 desktop (blank eDP-1 in Wayland) | Mode switcher UI bug; tracked in `2026-04-13_crt-mode-switcher-wayland-blank-screen` |

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v42.sh` | Insert A (~4301), Insert B (~4350), Insert C (~4370) |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Insert A (~5333), Insert B (~5380), Insert C (~5402) |

## Final Solution (3 inserts, validated)

**Insert A** — Capture HD state and derive CRT Boot_ key:
```bash
MODE_BACKUP_BASE="/userdata/Batocera-CRT-Script-Backup/mode_backups"
_hd_videomode=$(batocera-settings-get global.videomode 2>/dev/null || true)
_hd_videooutput=$(batocera-settings-get global.videooutput 2>/dev/null || true)
mkdir -p "${MODE_BACKUP_BASE}/hd_mode/video_settings"
echo "global.videomode=${_hd_videomode:-default}" > "${MODE_BACKUP_BASE}/hd_mode/video_settings/video_mode.txt"
echo "${_hd_videooutput}" > "${MODE_BACKUP_BASE}/hd_mode/video_settings/video_output.txt"
_crt_boot_line=$(grep "Boot_" /userdata/system/videomodes.conf 2>/dev/null \
    | grep "^${H_RES_EDID}x${V_RES_EDID}\." | head -1)
_crt_boot_mode="${_crt_boot_line%%:*}"   # extracts KEY (e.g. 641x480.60.00059)
```

**Insert B** — Write global.videomode/videooutput to batocera.conf and pre-seed CRT backup:
```bash
if [ -n "$_crt_boot_mode" ]; then
    sed -i '/^global\.videomode=/d' "$file_BatoceraConf"
    echo "global.videomode=$_crt_boot_mode" >> "$file_BatoceraConf"
fi
if [ -n "$video_output_xrandr" ]; then
    sed -i '/^global\.videooutput=/d' "$file_BatoceraConf"
    echo "global.videooutput=$video_output_xrandr" >> "$file_BatoceraConf"
fi
mkdir -p "${MODE_BACKUP_BASE}/crt_mode/video_settings"
if [ -n "$_crt_boot_mode" ]; then
    echo "global.videomode=$_crt_boot_mode" > "${MODE_BACKUP_BASE}/crt_mode/video_settings/video_mode.txt"
fi
if [ -n "$video_output_xrandr" ]; then
    echo "global.videooutput=$video_output_xrandr" > "${MODE_BACKUP_BASE}/crt_mode/video_settings/video_output.txt"
fi
```

**Insert C** — Fix es.resolution after installer writes wrong .00000 suffix:
```bash
if [ -n "$_crt_boot_mode" ]; then
    sed -i '/^es\.resolution=/d' "$file_BatoceraConf"
    echo "es.resolution=$_crt_boot_mode" >> "$file_BatoceraConf"
fi
```

Key discovery: `es.resolution` (not `global.videomode`) is what ES System Settings > Video Mode reads.
The installer writes `es.resolution=WxH.rate.00000` — the `00000` doesn't match any videomodes.conf key.
Insert C replaces it with the exact key (e.g. `641x480.60.00059`).

## Validation

- [x] After install: ES Video Mode shows Boot_ entry (not AUTO)
- [x] After install: `global.videooutput=DP-1` in batocera.conf
- [x] After install: `crt_mode/video_settings/video_output.txt` = `global.videooutput=DP-1`
- [x] After install: `hd_mode/video_settings/` pre-seeded
- [x] Mode Switcher CRT→HD: metadata `VIDEO_OUTPUT=DP-1` (eDP-1 bug fixed)
- [ ] Mode Switcher HD→CRT: full reboot and CRT verify
- [ ] Repeat on v42 hardware

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

