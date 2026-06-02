# Debug — Mode Switcher RetroArch Persistence QA

## Prerequisites

1. CRT Script installed; mode switcher available.
2. PR #438 fix deployed:

   `/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh`

3. Start in **CRT mode**.
4. Pick one core for all tests: **Mega Drive** / **Genesis Plus GX** recommended (matches user report).

## How-to: full round-trip test

### Step 0 — Baseline paths

```bash
RA=/userdata/system/configs/retroarch
BK=/userdata/Batocera-CRT-Script-Backup/mode_backups
ls -la "$RA/config/remaps/" 2>/dev/null
ls -la "$BK/crt_mode/emulator_configs/retroarch/config/remaps/" 2>/dev/null
```

### Step 1 — Create test artifacts (CRT mode)

Do **at least three** of the following (not only remaps):

| ID | What to set | How | Verify on disk before switch |
|----|-------------|-----|------------------------------|
| A | Core remap | Launch MD game → RA Quick Menu → Controls → save **core** remap | `$RA/config/remaps/Genesis Plus GX/Genesis Plus GX.rmp` exists, non-empty |
| B | Per-core cfg | SSH: append `video_scale = "2.000000"` to `$RA/config/Genesis Plus GX/Genesis Plus GX.cfg` | `grep video_scale` shows line |
| C | Core option | RA → Quick Menu → Options → change visible option (e.g. FM) | `grep -i genesis $RA/cores/retroarch-core-options.cfg` changed |
| D | Marker file | `echo "qa-crt-1" > $RA/config/.mode_switch_qa_marker` | `cat` shows `qa-crt-1` |
| E | Per-game cfg | After launching one ROM once, edit `$RA/megadrive/<RomStem>.cfg` if present | File exists with your edit |

Record checksums:

```bash
md5sum "$RA/config/remaps/Genesis Plus GX/Genesis Plus GX.rmp" 2>/dev/null
md5sum "$RA/config/Genesis Plus GX/Genesis Plus GX.cfg" 2>/dev/null
cat "$RA/config/.mode_switch_qa_marker" 2>/dev/null
```

### Step 2 — First mode switch (CRT → HD)

1. Run mode switcher → switch to **HD** → confirm → reboot.
2. After boot (HD mode), **optional:** launch same game; note bindings/options (HD tree may lack CRT-only files).
3. SSH checks:

```bash
# HD live tree — remaps often empty here (separate HD snapshot); OK
find "$RA" -name '*.rmp' 2>/dev/null
test -f "$RA/config/.mode_switch_qa_marker" && echo "marker in HD tree" || echo "no marker in HD (expected if HD snapshot never had it)"

# Backup must NOT be nested (post-#438)
find "$BK/crt_mode/emulator_configs/retroarch" -path '*/retroarch/retroarch/*' 2>/dev/null | head
```

**Pass:** No `.../retroarch/retroarch/config/remaps/...` with remaps only inside inner folder.

### Step 3 — Second mode switch (HD → CRT)

1. Mode switcher → **CRT** → reboot.
2. SSH — compare to Step 1 checksums:

```bash
md5sum "$RA/config/remaps/Genesis Plus GX/Genesis Plus GX.rmp" 2>/dev/null
grep video_scale "$RA/config/Genesis Plus GX/Genesis Plus GX.cfg" 2>/dev/null
cat "$RA/config/.mode_switch_qa_marker" 2>/dev/null
```

3. Launch same Mega Drive game — confirm remap + any in-game effect of per-core cfg.

### Step 4 — Second round trip (regression for #438)

Repeat CRT → HD → CRT **without** re-editing files.

All Step 1 artifacts must still match after second return to CRT.

### Step 5 — Log tail

```bash
tail -40 /userdata/system/logs/BUILD_15KHz_Batocera.log | grep -iE 'retroarch|Flattened|Backed up|Restored'
```

Look for `Flattened nested` only if repairing old nested backup; fresh installs may not log it.

## Pass/fail matrix

| Test ID | Expected after CRT→HD→CRT | Notes |
|---------|---------------------------|-------|
| A Core `.rmp` | **Pass** with #438 | User-reported bug |
| B Per-core `.cfg` | **Pass** if file not clobbered by configgen before switch | Re-check file after playing game |
| C `retroarch-core-options.cfg` | **Pass** if option saved to file before switch | |
| D Marker file | **Pass** in CRT after return | |
| E Per-game `.cfg` | **Pass** if file existed in CRT backup | |
| HD remaps empty | **Expected** today | Not a failure |
| Nested backup | **Fail** if inner `retroarch/retroarch` has sole copy of remaps | #438 regression |

## Phase B preview test (shared remaps — not implemented)

When/if `config/remaps/` is excluded from swap:

1. Set core remap in CRT.
2. CRT → HD **without** losing `$RA/config/remaps/...` on live disk (remap still on disk in HD).
3. Launch game in HD — binding should match CRT remap.
4. CRT-specific overlay cfg may still differ per mode.

Document results in a new `debug/01-shared-remaps-trial.md` when code exists.

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `.rmp` missing after CRT return | Nested backup or #438 not deployed |
| `.cfg` / marker lost | Same backup bug, or first HD switch deleted tree with no CRT backup |
| Remap works once, fails on 2nd round trip | `cp` nesting without `rm -rf` before backup |
| Per-core cfg reverts but `.rmp` OK | configgen overwrote `.cfg` on game launch after restore |
| Nothing in RA menu persists | Testing `retroarchcustom.cfg` only — use file-based tests above |
