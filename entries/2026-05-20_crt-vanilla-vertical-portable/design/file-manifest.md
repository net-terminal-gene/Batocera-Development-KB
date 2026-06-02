# File Manifest — Vanilla Vertical Build

Everything needed to rebuild vertical CRT **without** the Myzar/Mizar image. ROMs are reused as-is (`/userdata/roms/**`).

**Why:** Myzar does not support DisplayPort or DP-through-DAC for CRT; this hardware needs that path. Vanilla Batocera + CRT Script keeps vertical/TATE behavior while boot and `videooutput` stay under our control.

## A. One-time capture from current Batocera (run before swap image)

Run from Mac:

```bash
bash Batocera-Development-KB/entries/2026-05-20_crt-vanilla-vertical-portable/design/scripts/capture-vertical-bundle.sh
```

Output: `design/captured/vertical-bundle-YYYYMMDD.tar.gz` on Mac.

| Path on Batocera | Why |
|------------------|-----|
| `/userdata/system/batocera.conf` | All rotation, emulator, switchres keys |
| `/userdata/system/scripts/first_script.sh` | CRT/generic + TATE skip logic |
| `/userdata/system/scripts/first_script_right.sh` | Myzar ES exit + Windows rotation |
| `/userdata/system/scripts/*.bak*` | Rollback reference |
| `/userdata/system/configs/mame/*.cfg` | **1066** per-game rotate (large) |
| `/userdata/system/configs/mame/mame.ini` | Switchres / monitor |
| `/userdata/system/configs/mame/ui.ini` | MAME UI |
| `/userdata/system/configs/mame/ini/*.ini` | horizont/vertical TATE |
| `/userdata/system/logs/BUILD_15KHz_Batocera.log` | Installer menu audit trail |
| `/boot/batocera-boot.conf` | videooutput, es.resolution (reference only; **do not** apply DP hack lines on vanilla) |
| `/etc/switchres.ini` | CRT geometry |
| `/usr/share/batocera/configgen/scripts/rotation_fix.sh` | Stock + note if patched |

**ROMs:** rsync `/userdata/roms/` separately (same set) — not inside bundle script by default (size).

## B. Mac-side sources (already in repo / skills — copy to `design/portable/`)

| Source on Mac | Deploy to Batocera (after fresh CRT install) |
|---------------|-----------------------------------------------|
| `design/portable/first_script.sh` | `/userdata/system/scripts/first_script.sh` |
| `design/portable/first_script_right.sh` | `/userdata/system/scripts/first_script_right.sh` |
| `design/portable/patch_rotation_fix.py` | Run once on device (patches stock script) |
| `design/portable/apply-es-exit-rotation.sh` | Mac runner → SSH deploy both scripts + patch |
| `~/.cursor/skills/myzar-mame-rotate/scripts/gen_mame_rotate_cfg.py` | Regenerate MAME cfgs if not restoring tarball |
| `~/.cursor/skills/myzar-mame-rotate/scripts/validate_mame_rotate_cfg.py` | Validate cfg ↔ zip basenames |

## C. Batocera-CRT-Script (installer — not Myzar-specific)

| Mac path | Batocera path |
|----------|---------------|
| `Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/` (full tree) | `/userdata/system/Batocera-CRT-Script/` |
| Run `Batocera_ALLINONE/Batocera-CRT-Script-v42.sh` or `v43.sh` | On device via SSH or ES terminal |

Installer **generates** (do not copy from Myzar unless capture failed):

- `/userdata/system/scripts/first_script.sh` — overwritten; re-apply `design/portable/first_script.sh` after install
- `/userdata/system/batocera.conf` CRT block
- MAME `horizont.ini` / `vertical.ini`

## D. Files NOT to carry to vanilla vertical build

| File / pattern | Reason |
|----------------|--------|
| Myzar prebuilt squashfs / image | **Policy:** Myzar blocks DP/DP+DAC; cannot be the platform for this cabinet |
| `myzar-dp` syslinux snippets from Myzar-era experiments | Optional reference only; **re-derive** DP boot on vanilla via CRT installer + your GPU wiki, not Myzar image |
| `/userdata/system/scripts/~restore_*.sh` | Causes multi `setRotation` / 30s exit |
| `/userdata/system/scripts/*restore_rotation*` | Same |

## E. Optional per-system overrides

If capture includes custom keys, merge from captured `batocera.conf`:

- `psx.*`, `ps2.*`, `psp.*` — emulator, core, aspect, videomode
- `global.bezel*`, `*.switchres`
- Any `*.cfg` under `/userdata/system/configs/retroarch/` or standalone emulator dirs
- **PC Engine / PCE CD:** global `pcengine.videomode` / `pcenginecd.videomode` + `ratio` (see `entries/2026-05-20_crt-vanilla-vertical-portable/research/pcengine-vertical-vanilla-v43.md`)

Grep captured conf:

```bash
grep -E '^(psx|ps2|psp|display|mame|fbneo|global)\.' design/captured/*/batocera.conf
```

## F. Apply order on fresh Batocera v42/43

1. Flash official Batocera; boot once; set network/SSH.
2. Rsync ROMs to `/userdata/roms/` (unchanged tree).
3. Rsync **Batocera-CRT-Script** tree; run installer → document choices in `crt-installer-choices.md`.
4. Restore **MAME cfgs** from capture tarball OR run `gen_mame_rotate_cfg.py`.
5. Run `design/portable/apply-es-exit-rotation.sh` (overwrites `first_script*.sh`, patches `rotation_fix.sh`).
6. Merge any extra `batocera.conf` lines from capture (diff carefully).
7. Reboot; validation in `debug/README.md`.

## G. Myzar vs vanilla — capability matrix

| Feature | Myzar image | Vanilla + CRT script + portable bundle |
|---------|-------------|------------------------------------------|
| ES vertical (TATE) | Yes | Yes (`display.rotate` + installer) |
| Console rotate | Yes | Yes (CRT `first_script` + libretro/standalone tables) |
| MAME per-game 270 | Bulk cfgs | CRT autorol **or** bulk cfgs (your choice) |
| ES exit after MAME | `first_script_right` + patches | `design/portable/` (same) |
| DP-1 RDNA4 boot | Often required | **Skip** (different GPU/output) |
| ROM set | Same zips | **Same zips** — no change |
