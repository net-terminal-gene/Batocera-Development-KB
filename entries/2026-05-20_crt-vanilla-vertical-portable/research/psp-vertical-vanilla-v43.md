# Sony PlayStation Portable (PSP) — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default emulator (Batocera v43, locked here):** `libretro` + **`ppsspp`** (`configgen-defaults.yml`).
**Related:** [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md) (closest sibling: state-injection + two-tier rotation matrix), [PSX vertical](psx-vertical-vanilla-v43.md) (per-game custom viewport for portrait fill), [PS2 vertical](ps2-vertical-vanilla-v43.md) (bootstrap-state skip-menu pattern, but standalone PCSX2-Qt), [Saturn vertical](saturn-vertical-vanilla-v43.md) (state-injection without per-game rotation), autoconfig spec [psp-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/psp-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied PSP **ROMs** to `/userdata/roms/psp/` (`.iso`, `.cso`, `.pbp`).
4. No PSP BIOS file is required (PPSSPP is HLE for most titles).

Everything below adds PSP vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation.

---

## Why PSP is a new recipe class (sixth)

PSP combines pieces from Dreamcast and PSX, plus a v43-only input-remap layer Myzar never had:

| Layer | Dreamcast (Flycast) | PSX (pcsx_rearmed) | PSP (PPSSPP libretro) |
|-------|---------------------|--------------------|------------------------|
| Skip-menu autoload | `.state.auto` + RA keys | n/a | `.state.auto` + RA keys (TATE tier only) |
| System-wide rotation | `video_rotation=3` | `video_rotation=3` | `video_rotation=3` |
| Per-game rotation counter | `=0` for in-game-TATE titles | `=0` + custom viewport for Cave family | `=0` for native-TATE titles |
| Custom viewport | fill keys only | 480×640 portrait for Cave | **480×640** (TATE) or **544×480** / **816×480** (horizontal-on-vertical) |
| Input remap | none | none | **90° CW D-pad remap for TATE tier** (PPSSPP libretro rotates picture but not pad) |
| Horizontal-on-vertical | n/a | n/a | rotation stays `=3`, awkward unrotated controls accepted |

**Sixth recipe class:** **state-injection + two-tier rotation + per-game viewport + TATE input remap**.

Two title tiers on this 6-game roster:

1. **Native TATE (3 titles):** counter-rotate RA to `video_rotation=0`, custom viewport 480×640, D-pad remap 90° CW, Myzar `.state.auto` (works on v43 PPSSPP for these three).
2. **Horizontal-on-vertical (3 titles):** keep `video_rotation=3`, custom viewport only, no input remap. Pac-Man CE and Super Stardust boot through normal PPSSPP menus. Space Invaders Evolution: **do not seed Myzar `.state.auto`** (cross-version PPSSPP hang; see [Risks](#risks--gotchas)).

---

## All the configuration (cabinet-tested 2026-05-24)

### 1. `batocera.conf` — ten system-wide keys

```ini
# PSP vertical CRT (cabinet-tested 2026-05-24 on v43 + CRT Script)
psp.emulator=libretro
psp.core=ppsspp
psp.ratio=full
psp.videomode=960x480.60.00
psp.retroarch.video_rotation=3
psp.retroarch.video_force_aspect=false
psp.retroarch.crt_switch_resolution=0
psp.autosave=0
psp.retroarch.savestate_auto_load=true
psp.retroarch.savestate_auto_save=false
```

Set via:

```bash
batocera-settings-set psp.emulator libretro
batocera-settings-set psp.core ppsspp
batocera-settings-set psp.ratio full
batocera-settings-set psp.videomode 960x480.60.00
batocera-settings-set psp.retroarch.video_rotation 3
batocera-settings-set psp.retroarch.video_force_aspect false
batocera-settings-set psp.retroarch.crt_switch_resolution 0
batocera-settings-set psp.autosave 0
batocera-settings-set psp.retroarch.savestate_auto_load true
batocera-settings-set psp.retroarch.savestate_auto_save false
```

| Key | Effect |
|-----|--------|
| `psp.emulator=libretro` + `psp.core=ppsspp` | Lock libretro PPSSPP (Myzar uses the same pair). |
| `psp.ratio=full` + `psp.retroarch.video_force_aspect=false` | Fill geometry on the rotated super-res (same pattern as Dreamcast / PSX). |
| `psp.videomode=960x480.60.00` | PSP system videomode on this cabinet (from `batocera-resolution listModes`). |
| `psp.retroarch.video_rotation=3` | System-wide 270° CCW. **TATE-tier per-game cfgs override to `=0`.** Horizontal tier keeps `=3`. |
| `psp.retroarch.crt_switch_resolution=0` | Disable RA CRT switchres during PPSSPP (cabinet Switchres handles geometry). |
| `psp.autosave=0` + autoload-only pair | Decoupled autoload: RA loads curated `.state.auto` on launch, never overwrites on exit. |

**Warning:** EmulationStation **Per System Settings → PSP** can clobber keys (`ratio`, `videomode`, `autosave` observed missing after ES menu touch). Re-apply via `batocera-settings-set` if any vanish.

### 2. Core-wide `PPSSPP.cfg`

Path: `/userdata/system/configs/retroarch/config/PPSSPP/PPSSPP.cfg`

```ini
crt_switch_resolution = "0"
savestate_auto_load = "true"
video_refresh_rate = "59.940060"
video_rotation = "3"
video_shader_enable = "true"
```

This mirrors the system-wide rotation + autoload intent at the PPSSPP core layer. Per-game cfgs override rotation and autoload where needed.

### 3. TATE tier — three artifacts per title

**Titles:** Star Soldier, Beta Bloc, Neo Geo Heroes Ultimate Shooting.

Each needs:

#### 3a. Per-game `.cfg` (viewport + input remap)

Path: `/userdata/system/configs/retroarch/config/PPSSPP/<Title>.cfg`

```ini
aspect_ratio_index = "24"
custom_viewport_width = "480"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "0"
video_force_aspect = "true"
video_scale_integer = "false"
remap_save_on_exit = "false"
input_remap_binds_enable = "true"
input_player1_right_btn = "16"
input_player1_down_btn = "19"
input_player1_left_btn = "17"
input_player1_up_btn = "18"
input_player1_analog_dpad_mode = "1"
```

- `video_rotation = "0"` cancels system-wide `=3` so native TATE is not double-rotated.
- D-pad remap is **90° clockwise**: physical up → core right, right → down, down → left, left → up. Validated on Star Soldier.
- `remap_save_on_exit = "false"` prevents RA from persisting in-game remap saves that fight the locked cfg.

Lock: `chmod 444` on the file.

#### 3b. Per-game `.rmp` (mirror of the four rotation lines)

Path: `/userdata/system/configs/retroarch/config/remaps/PPSSPP/<Title>.rmp`

```ini
input_player1_right_btn = "16"
input_player1_down_btn = "19"
input_player1_left_btn = "17"
input_player1_up_btn = "18"
```

Lock: `chmod 444`.

**Do not save input remaps from inside RetroArch** for TATE titles. RA overwrites `.rmp` on exit if the operator saves remaps in-game (Star Soldier `.rmp` bloated to 1718 bytes during testing until restored).

#### 3c. Bootstrap `.state.auto` (+ `.png`)

Path: `/userdata/saves/psp/<Title>.state.auto`

For this cabinet, TATE-tier states were seeded from Myzar `10.23.6.214` (Batocera **v41**). They load correctly on v43 (`10.23.6.210`) for all three TATE titles. Live copies: `/userdata/saves/psp/` on `10.23.6.210`.

### 4. Horizontal tier — viewport-only `.cfg` (no remap, no bundled state)

**Titles:** Pac-Man Championship Edition, Super Stardust Portable, Space Invaders Evolution.

Path: `/userdata/system/configs/retroarch/config/PPSSPP/<Title>.cfg`

**Pac-Man CE and Super Stardust** (544×480):

```ini
aspect_ratio_index = "24"
custom_viewport_width = "544"
custom_viewport_height = "480"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "3"
video_force_aspect = "true"
video_scale_integer = "false"
```

**Space Invaders Evolution** (816×480, autoload explicitly off):

```ini
aspect_ratio_index = "24"
custom_viewport_width = "816"
custom_viewport_height = "480"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "3"
video_force_aspect = "true"
video_scale_integer = "false"
crt_switch_resolution = "0"
savestate_auto_load = "false"
```

- No `.rmp` files. Controls stay unrotated (landscape feel on a vertical monitor). Myzar accepted this for horizontal PSP titles.
- Pac-Man CE and Super Stardust: no `.state.auto` on Myzar either; normal PPSSPP boot is expected.
- Space Invaders: Myzar had a `.state.auto`, but seeding it on v43 **hangs RetroArch** (cannot exit; required `killall -9 emulationstation`). Removed; backup at `/userdata/saves/psp/_backup-myzar-incompatible/`. To add autoload later, capture a fresh `.state.auto` on **v43** after reaching gameplay.

Lock all horizontal cfgs: `chmod 444`.

---

## Per-title status (cabinet roster, 6 titles, 2026-05-24)

| Title | Tier | Viewport | State autoload | Cabinet result |
|-------|------|----------|----------------|----------------|
| Star Soldier | TATE | 480×640, rotation 0 | Myzar `.state.auto` | **PASS** — screen + controls + autoload |
| Beta Bloc | TATE | 480×640, rotation 0 | Myzar `.state.auto` | **PASS** |
| Neo Geo Heroes Ultimate Shooting | TATE | 480×640, rotation 0 | Myzar `.state.auto` | **PASS** |
| Pac-Man Championship Edition | horizontal | 544×480, rotation 3 | none | **PASS** |
| Super Stardust Portable | horizontal | 544×480, rotation 3 | none | **PASS** |
| Space Invaders Evolution | horizontal | 816×480, rotation 3 | **disabled** (Myzar state removed) | **PASS** after fix |

---

## Myzar reference vs v43 (what we kept / rejected)

| Item | Myzar (`10.23.6.214`, v41) | v43 cabinet |
|------|----------------------------|-------------|
| Emulator | `libretro` + `ppsspp` | same |
| System keys | `ratio=full`, `videomode=960x480.60.00` | same + tighter autoload decouple block |
| TATE per-game cfg | `video_rotation=0` only (20 bytes) | full custom viewport + input remap |
| Input remap | **none** (pad2key / evmapy absent) | **added** — required for playable TATE controls |
| Horizontal viewports | 544×480 or 816×480, rotation 3 | same dimensions |
| `.state.auto` | 4 titles on Myzar | 3 TATE titles work cross-version; Space Invaders **rejected** |

PPSSPP core binaries differ (Myzar v41 md5 `29e0cdc…` vs v43 md5 `86023185…`). Most Myzar `.state.auto` files still load on v43; Space Invaders is the exception that hung the frontend.

---

## Hard locks

- **Core lock: `ppsspp` libretro.** States and per-game cfgs live under `PPSSPP/` and `remaps/PPSSPP/`. Switching core breaks paths and save compatibility.
- **`psp.autosave=0` is essential.** Without it, configgen's convenience block can override the decoupled autoload-only keys.
- **TATE tier: chmod 444 on `.cfg` and `.rmp`.** Without locks, RA remap saves clobber the curated bindings.
- **TATE tier: never save remaps from inside RA** for these titles.
- **Space Invaders: do not deploy Myzar `.state.auto` on v43.** Use fresh v43-captured state if autoload is wanted later.
- **Cross-version state is not guaranteed.** Test each title after PPSSPP core upgrades; re-capture on-target if autoload hangs.

---

## Risks / gotchas

- **ES per-system PSP menu clobbers `batocera.conf` keys** (`ratio`, `videomode`, `autosave`). Re-apply the ten-key block after ES edits.
- **RetroArch overwrites `.rmp` on exit** if the operator saves remaps in-game. Keep rotation in `.cfg`, set `remap_save_on_exit=false`, lock both files.
- **Space Invaders + Myzar state = frozen RA.** Symptom: launch hangs, hotkey exit fails, `killall -9 emulationstation` required. Fix: remove `.state.auto`, set per-game `savestate_auto_load=false`.
- **Horizontal tier controls feel sideways.** Expected; Myzar did not remap these titles.
- **macOS `._*` AppleDouble files** can appear if states are rsync'd from a Mac. Harmless but delete if present (`._Space Invaders Evolution.state.auto` observed during deploy).

---

## QA checklist

1. **System-wide keys present:**
   ```bash
   grep ^psp /userdata/system/batocera.conf | sort
   ```
2. **TATE title triplet (example Star Soldier):**
   ```bash
   ls -la "/userdata/system/configs/retroarch/config/PPSSPP/Star Soldier.cfg"
   ls -la "/userdata/system/configs/retroarch/config/remaps/PPSSPP/Star Soldier.rmp"
   ls -la "/userdata/saves/psp/Star Soldier.state.auto"
   # expect -r--r--r-- on cfg and rmp
   ```
3. **Space Invaders has no autoload state:**
   ```bash
   ls "/userdata/saves/psp/Space Invaders Evolution.state.auto" 2>/dev/null && echo FAIL || echo OK
   grep savestate_auto_load "/userdata/system/configs/retroarch/config/PPSSPP/Space Invaders Evolution.cfg"
   # → savestate_auto_load = "false"
   ```
4. **Launch matrix:**
   - One TATE title → portrait fill, rotated D-pad, autoload to gameplay.
   - One horizontal title → landscape-on-vertical, no remap, normal exit works.
   - Space Invaders → boots through menus, exits cleanly.

---

## SSH note

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'grep ^psp /userdata/system/batocera.conf | sort'
~/bin/ssh-batocera.sh 10.23.6.210 'ls -la /userdata/system/configs/retroarch/config/PPSSPP/*.cfg'
~/bin/ssh-batocera.sh 10.23.6.210 'ls -la /userdata/saves/psp/*.state.auto'
```

For spaced filenames over rsync, tar on the source (`tar czf /tmp/sie-state.tgz "Space Invaders Evolution.state.auto" …`) and rsync the single tarball.

---

## Links

- Generator merge spec: [psp-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/psp-vertical-autoconfig.md)
- Dreamcast (two-tier rotation + state): [dreamcast-vertical-vanilla-v43.md](dreamcast-vertical-vanilla-v43.md)
- PSX (custom viewport pattern): [psx-vertical-vanilla-v43.md](psx-vertical-vanilla-v43.md)
