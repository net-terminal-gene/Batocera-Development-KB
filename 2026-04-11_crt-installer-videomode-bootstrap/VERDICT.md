# VERDICT — CRT Installer: Bootstrap global.videooutput, global.videomode, es.resolution

## Status: FIXED

## Summary

The CRT installer now writes `global.videooutput`, `global.videomode`, and `es.resolution` to `batocera.conf` at install time, and pre-seeds the mode switcher backup directories for both HD and CRT modes. After a full baseline test (stages 00–10) using the original unmodified script, the bootstrap changes were implemented and validated end-to-end (stages 11–14) on v43 hardware with an AMD GPU and ms929 EDID. ES Video Mode now shows the correct Boot_ entry immediately after first CRT boot. The mode_metadata eDP-1 first-run bug is fixed. CRT→HD mode switching works correctly.

## Plan vs Reality

The original plan called for writing `global.videomode=Boot_...` (the human-readable display name). Testing revealed the correct format is the videomodes.conf KEY (e.g. `641x480.60.00059`), not the name. Three rounds of debugging were required:

1. **Stage 11:** Bootstrap caused black screen — traced to broken transcoder power cable (hardware), NOT the software. Cleared as non-issue once hardware was fixed.
2. **Stage 12:** ES showed "AUTO" in Video Mode despite `global.videomode` being written — root cause was wrong side of the `:` in the extraction (`#*:` vs `%%:*`). Fixed.
3. **Stage 12–13:** ES still showed "AUTO" after key fix — root cause was `es.resolution`, not `global.videomode`, being the key the ES UI reads. Installer writes `es.resolution=WxH.rate.00000` (wrong suffix). Required Insert C to overwrite with the correct videomodes.conf key.

The original plan also included writing `global.videomode` to the CRT backup file. This was done, but the mode switcher overwrites it on first CRT→HD switch with the xrandr live value anyway. The backup pre-seed value for `global.videomode` is cosmetic/transitional.

## Root Causes (Original Problems)

1. Installer never wrote `global.videooutput` to `batocera.conf` — ES on v43 Wayland dual-boot targeted eDP-1 on first CRT boot
2. Mode switcher backup dirs empty at install — first run had to re-pick all 3 settings
3. `mode_metadata.txt VIDEO_OUTPUT=eDP-1` on first CRT→HD switch — mode switcher read stale `global.videooutput=eDP-1` from batocera.conf for metadata
4. ES Video Mode showed "AUTO" — installer wrote `es.resolution=WxH.rate.00000`; that key does not exist in `batocera-resolution listModes` (which uses the actual videomodes.conf sequence number, e.g. `.00059`)

## Unanticipated Bugs Found During Testing

- **Stage 11 black screen:** Hardware — broken power cable on VGA-to-Component transcoder. No software fix needed.
- **Wrong `%%:*` vs `#*:` extraction:** Shell parameter expansion direction was backwards, extracting the display name instead of the resolution key.
- **`video_output.txt` missing prefix:** Bootstrap wrote `DP-1` bare; mode switcher expects `global.videooutput=DP-1` as a full replacement line.
- **`es.resolution` is the ES UI key, not `global.videomode`:** Discovered by code research in `batocera.linux` configgen and live SSH testing. The `preset: videomodes` in ES reads `es.resolution` for the System Settings dropdown.
- **`pkill -f emulationstation` killed the openbox wrapper:** Used this to restart ES during debugging — it killed the whole X11 session. Use `kill <pid>` targeting only the emulationstation PID in future.

## Models Used

Sonnet 4.6 (Cursor Composer) — full session including live SSH debugging, code research, and KB documentation.

## Changes Applied

| File | Change |
|------|--------|
| `Batocera-CRT-Script-v42.sh` | **Insert A** (line ~4301): capture HD `global.videomode`/`global.videooutput`, write HD backup, derive `_crt_boot_mode` from videomodes.conf using `%%:*` |
| `Batocera-CRT-Script-v42.sh` | **Insert B** (line ~4350): write `global.videomode` and `global.videooutput` to `batocera.conf`; pre-seed `crt_mode/video_settings/` with correct key format and `global.videooutput=` prefix |
| `Batocera-CRT-Script-v42.sh` | **Insert C** (line ~4370): after installer writes `es.resolution=WxH.rate.00000`, replace with `es.resolution=$_crt_boot_mode` (correct videomodes.conf key) |
| `Batocera-CRT-Script-v43.sh` | Same as v42 — Insert A (line ~5333), Insert B (line ~5380), Insert C (line ~5402) |

## What Worked

- Grepping videomodes.conf for `Boot_` entries and extracting the key with `%%:*` is robust across all monitor profiles
- Pre-seeding `crt_mode/video_settings/video_output.txt` with `global.videooutput=DP-1` fixes the eDP-1 metadata bug on first run
- The `if [ -n "$_crt_boot_mode" ]` guard cleanly skips the write for profiles with no Boot_ entry (e.g. ms929 240p)

## What Didn't Work

- Writing `global.videomode=Boot_480i 1.0:0:0 15KHz 60Hz` (display name) — ES ignores it
- `pkill -f emulationstation` — killed too broadly; always kill by PID
- Assuming `global.videomode` was what ES Video Mode reads — it's `es.resolution`

## Validation Completed

- [x] After install: ES Video Mode shows "Boot_480i 1.0:0:0 15KHz 60Hz" (not AUTO)
- [x] After install: `global.videooutput=DP-1` in batocera.conf
- [x] After install: `crt_mode/video_settings/video_output.txt` = `global.videooutput=DP-1`
- [x] After install: `hd_mode/video_settings/` pre-seeded with eDP-1 and default
- [x] Mode Switcher CRT→HD: restores eDP-1 correctly, metadata `VIDEO_OUTPUT=DP-1`
- [ ] Mode Switcher HD→CRT: full reboot and CRT verify (next session)
- [ ] Repeat on v42 hardware
